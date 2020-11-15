Description:

This project configures JENKIN automatically on a Mac Book or Linux Box (you have to configure your storage location / shared storage for docker in a docker)
It auto deploys jenkin with One Project QLedger as an example, and you can access it via http://localhost:8080 on your system (Laptop)

Pre-Requisites:

Download Docker on platform of your choice ( Max and Linux)

IF ON MAC:

https://github.com/alpine-docker/socat
For jenkins to use docker
$ docker pull alpine/socat
$ docker run -d --restart=always \
    -p 127.0.0.1:2375:2375 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    alpine/socat \
    tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock

2. Setup storage drive  in workspace folder

3. Log in to server http://localhost:8080

By default no password is shown for convenience


