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
$ docker build -t rundeck-cluster-ubuntu rundeck

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



```
```