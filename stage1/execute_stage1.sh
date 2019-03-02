#!/bin/bash

# Step A

echo -e "\e[32mStep A started. Note: it is assumed, that docker has been already installed\e[0m"

# It is assumed, that docker is installed

# Get docker version

docker --version

# Run docker "hello, world" example

docker run hello-world

echo -e "\e[32mStep A completed\e[0m"

echo
echo
echo


# Step B

echo -e "\e[32mStep B started\e[0m"

# Create a docker image for Redis server

docker build --tag redis-server-container ./redis-server-container

# Run docker container with Redis

docker run -d --name redis-server -p 6379:6379 -v /var/cec:/data redis-server-container

# Check that docker container started correctly

# But before give some time to load database

echo "Waiting for rdb-file to load..."
sleep 20

docker exec -i -t redis-server redis-cli dbsize

echo -e "\e[32mStep B completed\e[0m"

echo
echo
echo


# Step C

echo -e "\e[32mStep C started\e[0m"

# Stop container created at previous step

docker stop redis-server

# Drop that container

docker rm redis-server

# Create a network for containers
# This will be a bridge network so no additional options specified

docker network create project-network

# Restart redis-container with respect to created network

docker run -d --name redis-server -p 6379:6379 -v /var/cec:/data --net project-network redis-server-container

# Create HTTP server container image

docker build --tag http-server-container ./http-server-container

# Run HTTP server container

docker run -d --name http-server -p 80:80 --net project-network http-server-container

echo -e "\e[31mYou can now evaluate a correctness of Step C solution. HTTP server runs at port 80. When you are ready, please, press Enter to proceed to the next step...\e[0m"

read input

echo "Please, wait while containers are being stopped"

# Stop and remove HTTP server (Redis will be used at the next step)

docker stop http-server
docker rm http-server

echo -e "\e[32mStep C completed\e[0m"

echo
echo
echo


# Step D

echo -e "\e[32mStep D started\e[0m"

# Build and run load balancer container

docker build --tag load-balancer-container ./load-balancer-container

docker run -d --name load-balancer -p 80:80 --net project-network load-balancer-container

read -p "Specify a number of HTTP server containers to run: " n

# Run n HTTP servers

echo "You have chosen to use $n servers"

http_server_list=$(seq 1 $n)

for i in $http_server_list
do
    container_name=http-server-${i}
    exposed_port=$((8080+$i))
    docker run -d --name ${container_name} -p ${exposed_port}:80 --net project-network -e http_server_address=${container_name}:${exposed_port} --cpus=".05" http-server-container
done

echo -e "\e[31mYou can now evaluate a correctness of Step D solution and run benchmark. When you are ready, please, press Enter to stop the script...\e[0m"

read input

echo "Please, wait while containers are being stopped..."

docker stop redis-server load-balancer

for i in $http_server_list
do
    docker stop http-server-${i}
done

read -p "Step completed. Remove containers now? ('y' to confirm or anything else to decline): " confirm

if [ "$confirm" = "y" ]; then
    docker rm redis-server load-balancer
    for i in $http_server_list
    do
        docker rm http-server-${i}
    done
    docker network rm project-network
    echo -e "\e[32mContainers removed. Script completed\e[0m"
else
    echo -e "\e[32mScript completed bur containers and network were not removed. If you want to re-run the script then execute the following script:\e[0m"
    echo -e "\e[31mdocker rm redis-server"
    echo "docker rm load-balancer"
    for i in $http_server_list
    do
        echo "docker rm http-server-${i}"
    done
    echo -e "docker network remove project-network\e[0m"
	echo -e "\e[32mStep D and script completed\e[0m"
fi