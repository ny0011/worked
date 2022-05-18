# execute Docker Cilent with systemd
$ sudo systemctl enable docker.service
$ sudo systemctl enable containerd.service

# docker build & run
$ sudo docker build -t t .
$ sudo docker run -v "/home/user/docker/ubuntu/cmd:/cmd" -d --privileged  -p 10000:80 -p 19000:9000 t
