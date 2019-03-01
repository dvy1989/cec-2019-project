import logging
import queue

import flask
import requests

app = flask.Flask(__name__)

HTTP_SERVERS = queue.Queue()

logging.basicConfig(filename="load-balancer.log", level=logging.INFO)


def server_is_available(http_server_hostname):
    try:
        logging.info("Pinging http://%s/ping" % http_server_hostname)
        response = requests.get("http://%s/ping" % http_server_hostname)
        logging.info("http://%s/ping is available and responds with code %s" % (http_server_hostname, response.status_code))
        return response.status_code == 200
    except Exception as e:
        logging.exception("Server is not available %s", exc_info=e)
        return False


@app.route("/")
def index_page():
    try:
        while HTTP_SERVERS.qsize() > 0:
            http_server_hostname, http_service_port = HTTP_SERVERS.get_nowait()
            if server_is_available(http_server_hostname):
                redirect_url = "%s:%s" % (flask.request.base_url[:-1], http_service_port)
                logging.info("Redirecting to http://%s" % redirect_url)
                response = flask.redirect(redirect_url)
                HTTP_SERVERS.put((http_server_hostname, http_service_port))
                return response
        return flask.render_template("error.html", error="no servers available")
    except queue.Empty:
        return flask.render_template("error.html", error="no servers available")


@app.route("/register")
def register_http_server():
    try:
        http_server_address = flask.request.args["http_server_address"]
        http_server_hostname, http_server_port = http_server_address.split(":")
        logging.info("Server http://%s started" % http_server_address)
        HTTP_SERVERS.put((http_server_hostname, http_server_port))
        logging.info("Server %s registered" % http_server_address)
        return flask.Response("Server registered", status=200, mimetype="application/json")
    except Exception as e:
        logging.exception(msg="Failed to register server", exc_info=e)
        return flask.Response("Error in registering a server", status=500, mimetype="application/json")


if __name__ == "__main__":
    # Must be 0.0.0.0 to make it available for connection
    app.run(host="0.0.0.0", port=80)
