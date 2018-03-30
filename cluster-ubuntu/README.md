# Rundeck Custer Environment

## Requirements

* An external Database
* A Log Storage S3 compatible (eg: minIO)
* A Load Balancer

## Environment variables:

(Required) Log Storage Environments 
* LOGSTORATE_BUCKET: S3 Bucket
* LOGSTORATE_ACCESSKEY: S3 Access Key
* LOGSTORATE_SECRETKEY: S3 Secret Key
* LOGSTORATE_URL: (Optional) S3 URL, eg: http://minio:9000

(Optional) Autorecover and Remote Policies 
* RUNDECK_AUTORECOVER_ENABLE : Use "true" to enable autorecover
* RUNDECK_REMOTE_POLICY_ENABLE : Use "true to enable remote policy"
* RUNDECK_REMOTE_DEFAULT_POLICY : Set default policy value, eg: Any
* RUNDECK_REMOTE_DEFAULT_ALLOWED : Set the default allowed servers
* RUNDECK_REMOTE_DEFAULT_ALLOWED_TAGS : Set the default allowed tags
* RUNDECK_REMOTE_DEFAULT_PREFERRED_TAGS : Set the preferred allowed tags



## Start a cluster environment

### Build the image
```
$ cd cluster-ubuntu
$ docker build -t rundeck-cluster-ubuntu .

```

## Run the containers

### Basic Example

```

$ docker run -d --name rundeck-cluster1  -p 4440 \
          -e RUNDECK_URL=http://loadbalancer \
          -e DATABASE_URL="jdbc:mysql://mysql/rundeckdb?autoReconnect=true" \
          -e DATABASE_DRIVER="com.mysql.jdbc.Driver" \
          -e DATABASE_USER="rundeckuser" \
          -e DATABASE_PASS="password" \
          -e LOGSTORATE_BUCKET="rundeck" \
          -e LOGSTORATE_ACCESSKEY="accesskey" \
          -e LOGSTORATE_SECRETKEY="secretkey" \
          -e LOGSTORATE_URL="http://minio:9000/" \
          rundeck-cluster-ubuntu 


$ docker run -d --name rundeck-cluster2  -p 4440 \
          -e RUNDECK_URL=http://loadbalancer \
          -e DATABASE_URL="jdbc:mysql://mysql/rundeckdb?autoReconnect=true" \
          -e DATABASE_DRIVER="com.mysql.jdbc.Driver" \
          -e DATABASE_USER="rundeckuser" \
          -e DATABASE_PASS="password" \
          -e LOGSTORATE_BUCKET="rundeck" \
          -e LOGSTORATE_ACCESSKEY="accesskey" \
          -e LOGSTORATE_SECRETKEY="secretkey" \
          -e LOGSTORATE_URL="http://minio:9000/" \
          rundeck-cluster-ubuntu 
          	  
```


### Using Remote Execution and Auto-Takeover

In this case the execution will be performed by the container rundeck-cluster2
```

docker run -d --name rundeck-cluster1  -p 4440 \
          -e RUNDECK_URL=http://loadbalancer \
          -e DATABASE_URL="jdbc:mysql://mysql/rundeckdb?autoReconnect=true" \
          -e DATABASE_DRIVER="com.mysql.jdbc.Driver" \
          -e DATABASE_USER="rundeckuser" \
          -e DATABASE_PASS="password" \
          -e LOGSTORATE_BUCKET="rundeck" \
          -e LOGSTORATE_ACCESSKEY="accesskey" \
          -e LOGSTORATE_SECRETKEY="secretkey" \
          -e LOGSTORATE_URL="http://minio:9000/" \
          -e RUNDECK_SERVER_LABEL="front" \
          -e RUNDECK_AUTORECOVER_ENABLE="true" \
          -e RUNDECK_REMOTE_POLICY_ENABLE="true" \
          -e RUNDECK_REMOTE_DEFAULT_POLICY="Any" \
          -e RUNDECK_REMOTE_DEFAULT_ALLOWED_TAGS="worker" \
          -e RUNDECK_REMOTE_DEFAULT_PREFERRED_TAGS="worker" \
          rundeck-cluster-ubuntu 
          
docker run -d --name rundeck-cluster2  -p 4440 \
          -e RUNDECK_URL=http://loadbalancer \
          -e DATABASE_URL="jdbc:mysql://mysql/rundeckdb?autoReconnect=true" \
          -e DATABASE_DRIVER="com.mysql.jdbc.Driver" \
          -e DATABASE_USER="rundeckuser" \
          -e DATABASE_PASS="password" \
          -e LOGSTORATE_BUCKET="rundeck" \
          -e LOGSTORATE_ACCESSKEY="accesskey" \
          -e LOGSTORATE_SECRETKEY="secretkey" \
          -e LOGSTORATE_URL="http://minio:9000/" \
          -e RUNDECK_SERVER_LABEL="worker" \
          -e RUNDECK_AUTORECOVER_ENABLE="true" \
          -e RUNDECK_REMOTE_POLICY_ENABLE="true" \
          -e RUNDECK_REMOTE_DEFAULT_POLICY="Any" \
          -e RUNDECK_REMOTE_DEFAULT_ALLOWED_TAGS="worker" \
          -e RUNDECK_REMOTE_DEFAULT_PREFERRED_TAGS="worker" \
          rundeck-cluster-ubuntu 
	    
```

## Load Balancer Example

Here is an example about how use a loadbalancer HAProxy with rundeck

### Create a Docker File

```
$ mkdir loadbalancer
$ cd loadbalancer
$ touch Dockerfile
$ vi Dockerfile

FROM haproxy:1.7
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

```

### Create haproxy.cfg

Here you will configure the load balancer

```
global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  log-send-hostname
  maxconn 4096
  pidfile /var/run/haproxy.pid
  daemon

defaults
  balance roundrobin
  log global
  mode http
  option redispatch
  option httplog
  option dontlognull
  option forwardfor

frontend default_port_80
  bind :80
  reqadd X-Forwarded-Proto:\ http
  maxconn 4096
  default_backend rundeck_service

backend rundeck_service
    balance roundrobin
    cookie JSESSIONID prefix nocache
    server rundeck-cluster1 rundeck-cluster1:4440 check cookie rundeck-cluster1
    server rundeck-cluster2 rundeck-cluster2:4440 check cookie rundeck-cluster2

```

### Build the image
```
docker build -t lb-haproxy .
```

### Run the load balancer

```
docker run -d --name loadbalancer -p 80:80 \
       --link rundeck-cluster1 \
       --link rundeck-cluster2 \
       lb-haproxy
```

In this example you will access rundeck on `http://localhost:80`.
The parameter RUNDECK_URL on the rundeck container needs to be set on that value.