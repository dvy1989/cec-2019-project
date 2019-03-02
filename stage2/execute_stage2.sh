#!/bin/bash

# Step A

echo -e "\e[32mStep A started. Note: it is assumed, that docker has been already installed\e[0m"

echo -e "\e[32mSince at this step it is required to write docker-compose.yml this script does nothing (yml file was created manually). File's content:\e[0m"

cat docker-compose.yml

echo -e "\e[32mStep A completed\e[0m"

echo
echo
echo



# Step B

echo -e "\e[32mStep B started\e[0m"

read -p "Specify a number of HTTP server containers to run: " n

echo "You have chosen to run $n servers"

sed -ri "s/^(\s*)(replicas\s*:\s*3\s*$)/\1replicas: $n/" docker-compose.yml

docker swarm init

docker stack deploy -c docker-compose.yml project-stage-2

echo "Checking that service is deployed correctly: "

sleep 15

docker service ls

echo -e "\e[31mStack is deployed. You can now evaluate that everything is correct. You can also run banchmark here. When you are ready press Enter to stop the step...\e[0m"

read input

read -p "Step completed. Remove Docker stack now? ('y' to confirm or anything else to decline): " confirm

sed -ri "s/^(\s*)(replicas\s*:\s*$n\s*$)/\1replicas: 3/" docker-compose.yml
echo "docker-compose.yml is restored"

if [ "$confirm" = "y" ]; then
	docker stack rm project-stage-2
	docker swarm leave --force
    echo -e "\e[32mStack removed. Setp B and script completed\e[0m"
else
    echo -e "\e[32mScript completed bur stack is not removed. If you want to re-run the script then execute the following commands:\e[0m"
    echo -e "\e[31mdocker stack rm project-stage-2"     
    echo -e "docker swarm leave --force\e[0m"
	echo -e "\e[32mStep D and script completed\e[0m"
fi