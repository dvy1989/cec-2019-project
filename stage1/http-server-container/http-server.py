import logging
import os

import flask
import redis
import requests

logging.basicConfig(filename="http-server.log", level=logging.INFO)

app = flask.Flask(__name__)
# redis-server here is possible because both redis and http server containers run in the same docker network
redis_db = redis.Redis(host="redis-server", db=0, socket_connect_timeout=2, socket_timeout=2)


def register_at_load_balancer():
    try:
        http_server_address = os.getenv("http_server_address")
        if http_server_address is None:
            logging.info("This server is not supposed to be used with load balancer")
            return
        requests.get("http://load-balancer/register", params={"http_server_address": http_server_address})
    except Exception as e:
        logging.exception("Some error in connecting to load balancer", e)


def calculate_factorial(value):
    result = 1
    for i in range(1, value):
        result = result * i
    return "Infinity"


@app.route("/")
def index_page():
    try:
        # Get a random key from Redis
        random_key = redis_db.randomkey()
        number = int(redis_db.get(random_key))
        factorial = calculate_factorial(number)
        return flask.render_template("success.html", text=os.getenv("http_server_address"), number=number, factorial=factorial)
    except Exception as e:
        return flask.render_template("error.html", error=str(e))


@app.route("/ping")
def ping():
    return flask.Response(status=200)


if __name__ == "__main__":
    register_at_load_balancer()
    # Must be 0.0.0.0 to make it available for connection
    app.run(host="0.0.0.0", port=80)
