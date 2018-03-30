# Rundeck PRO Docker Examples


## Build and Run

* `cd` to `<edition>-<os>`

* build the image: 

```
docker build -t rundeck-<edition>-<os> .
```

* run Rundeck PRO: 

```
docker run -d --name rundeck-<edition>  -p 4440:4440 \
          -e RUNDECK_URL=http://localhost:4440 \
	  -e DATABASE_URL="jdbc:mysql://mysql/rundeckdb?autoReconnect=true" \
	  -e DATABASE_DRIVER="com.mysql.jdbc.Driver" \
	  -e DATABASE_USER="rundeckuser" \
	  -e DATABASE_PASS="password" \
	  rundeck-<edition>-<os>

```


## Environment variables:

* RUNDECK_URL : Endpoint URL to access to rundeck
* RUNDECK_NODE: (Optional) by default it will take the hostname
* DATABASE_URL : Database URL string connection
* DATABASE_DRIVER : Database Driver
* DATABASE_USER: Database User
* DATABASE_PASS : Database Password

