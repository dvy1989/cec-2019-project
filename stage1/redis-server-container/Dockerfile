# Create a docker image based on Redis image by docker
# Instructions: https://hub.docker.com/_/redis
FROM redis:latest

# Expose default Redis port
EXPOSE 6379

# Specify docker volume name (path to the volume will be provided when container will be run)
# Name "data" seems to be required by instructions
VOLUME /data

# Copy custom Redis configuration to be used
COPY redis.conf /usr/local/etc/redis/redis.conf

# Run server with provided configuration
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]