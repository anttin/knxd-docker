# knxd-docker

This repository is for building a Docker container of [knxd](https://github.com/knxd/knxd/).

## Docker Image

* The image uses [ubuntu](https://hub.docker.com/_/ubuntu) 22.04 as base image
* The tag matches the tag of the [knxd repository](https://github.com/knxd/knxd/tags).
* Image is available from Docker Hub in `linux/amd64`, `linux/arm64` and `linux/arm/v7` architectures.

## Installation

1. Install Docker / Kubernetes / your choice of a container platform.
1. Download: `docker pull anttin/knxd`
1. Prepare [config file for knxd](https://github.com/knxd/knxd/blob/master/doc/inifile.rst)
1. Run the container with Docker / docker-compose / kubernetes / etc. using your config file

## Usage

You may give optional parameters for the knxd executable as the run arguments (cmd), for example, an alternative path to knxd.ini or any other knxd command line option.

### Docker run example

```shell
docker run -d -p 0.0.0.0:6720:6720 -v /local/path/to/knxd.ini:/etc/knxd.ini anttin/knxd
```

### docker-compose example

```yaml
version: '3.4'
services:
  knxd:
    image: anttin/knxd
    container_name: knxd
    volumes:
      - /local/path/to/knxd.ini:/etc/knxd.ini
    ports:
      - 6720:6720
    restart: always
    network_mode: host
```

### kubernetes example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: knxd-config
data:
  config: |
    [main]
    addr = 1.1.210
    client-addrs = 1.1.210:5
    connections = server,B.ipt
    systemd = systemd

    [B.ipt]
    driver = ipt
    ; ipt device ip
    ip-address = 10.11.12.13
    dest-port = 3671
    nat = true
    ; container host ip
    nat-ip = 10.9.8.7
    data-port = 10001

    [server]
    server = knxd_tcp

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: knxd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: knxd
  template:
    metadata:
      labels:
        app: knxd
    spec:
      containers:
      - name: knxd
        image: anttin/knxd:latest
        args: ["/knxd/knxd.ini"]
        ports:
          - containerPort: 6720
        volumeMounts:
          - name: vol-knxd
            mountPath: /knxd
      volumes:
      - name: vol-knxd
        configMap:
          name: knxd-config
          items:
            - key: config
              path: knxd.ini
---
apiVersion: v1
kind: Service
metadata:
  name: knxd
spec:
  type: NodePort
  ports:
  - port: 6720
    targetPort: 6720
  selector:
    app: knxd
```

## Building the image

The images are available at [Docker Hub](https://hub.docker.com/r/anttin/knxd).

To build it locally:

```shell
docker build -t anttin/knxd github.com/anttin/knxd-docker
```
