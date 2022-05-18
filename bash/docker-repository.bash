# https://docs.docker.com/registry/insecure/
# https://docs.docker.com/registry/deploying/#get-a-certificate
# Using TLS, but I just use openssl, edit 127.0.0.1 as registry.test.com in /etc/hosts
# Used on isolated testing.

# On Docker Registry server
mkdir -p certs

openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
  -addext "subjectAltName = DNS:registry.test.com" \
  -x509 -days 365 -out certs/domain.crt
  
  
sudo docker run -d \
  --restart=always \
  --name registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 443:443 \
  registry:2
  
# On Docker Client server
$ sudo cat /etc/docker/daemon.json
{
  "insecure-registries" : ["Docker Registry server IP Addr"]
}

$ sudo service docker restart

# push image
$ sudo docker pull ubuntu:20.04
$ sudo docker tag ubuntu:20.04 IP/ubuntu-20
$ sudo docker push IP/ubuntu-20

# pull image
$ sudo docker pull IP/ubuntu-20
