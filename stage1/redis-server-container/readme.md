# Redis container

This container's image can be created with the following command from folder **_Project/redis-server-container_**:

```bash
docker build --tag redis-server-container .
```

Now container can be started by running:

```bash
docker run -d -p 6379:6379 --name redis-server --net project-network -v /var/cec:/rdb-repository redis-server-container
```

Option **_-d_** means, that container will be running in detached mode. This means, that container will run in the background. 
Since Redis server tends to wait for user input this is a reasonable choice. Parameter **_--name_** is required to distinguish containers from 
others. **_-p_** stands for publishing ports which makes them available to containers outside the same network. Since EXPOSE describes only one port option **_-P_**
can be used with the same effect.

Parameter **_--net_** is important here since both Redis and HTTP server should run in the same Docker network to be accessible for each other.

To test, that container works properly, one could run the following command:

```bash
docker exec -i -t redis-server /bin/bash
```

Then a terminal for docker environment should be opened. Run there command:

```bash
redis-cli
```

This will open Redis command line interface. Running a command **_dbsize_** should give result 11881376, if everything was done correctly.


