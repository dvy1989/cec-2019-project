# HTTP server container

This container's image can be created with the following command from folder **_Project/stage1/http-server-container_**:

```bash
docker build --tag http-server-container .
```

Now container can be started by running:

```bash
docker run -d -p 80:80 --name http-server --net project-network http-server-container
```

You could read more about options used here in **_../redis-server-containers/readme.md_**. They have the same meaning as for Redis container.

