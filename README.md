# Rundeck PRO Docker Examples


**Requirements and Assumptions**
* This container will use port 4440
* You will need to define a server URL for Rundeck PRO
* An external RDB like mariadb, mysql, etc.
* Set up a log storage like minio or S3 (Optional for Team Edition, Require for Cluster) 
* You need to choose which edition and OS you want use 


**Procedure**
1. Clone the this repo
1. Install the License: Put your license on `<edition>-<os>/data` with the name `rundeckpro-license.key`. 
If you don’t have a license available at this time you can upload it via the GUI later.
1. Build the image
1. Run Rundeck PRO Edition



## Team Environment 

### Requirements

* An external Database

### Build the image: 

```
docker build -t rundeck-team-<os> team-<os>
```

### Basic Environment variables:

* RUNDECK_URL : Endpoint URL to access to rundeck
* RUNDECK_NODE: (Optional) by default it will take the hostname
* DATABASE_URL : Database URL string connection
* DATABASE_DRIVER : Database Driver
* DATABASE_USER: Database User
* DATABASE_PASS : Database Password


### Run Rundeck PRO Team: 

```
docker run -d --name rundeck-team  -p 4440:4440 \
           -e RUNDECK_URL=http://localhost:4440 \
	   -e DATABASE_URL="jdbc:mysql://mysql/rundeckdb?autoReconnect=true" \
	   -e DATABASE_DRIVER="com.mysql.jdbc.Driver" \
	   -e DATABASE_USER="rundeckuser" \
	   -e DATABASE_PASS="password" \
	   rundeck-team-<os>

```

# Custer Environment

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
$ docker build -t rundeck-cluster-<os> cluster-<os>
```

## Run the containers

### Basic Example with two nodes

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
             rundeck-cluster-<os> 


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
             rundeck-cluster-<os> 
          	  
```


### Using Remote Execution and Auto-Takeover with two nodes

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
           rundeck-cluster-<os> 
          
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
           rundeck-cluster-<os> 
	    
```

## Load Balancer Example

Here is an example about how use a loadbalancer HAProxy with Rundeck PRO Cluster

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


