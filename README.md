# Rundeck PRO Docker Examples


## Build and Run

* `cd` to `<edition>-<os>`

* build the image: 

```
docker build -t rundeck-<edition>-<os> rundeck
```

* run Rundeck PRO: 

```
docker run -d --name rundeck-<edition>  -p 4440:4440 \
         -e RUNDECK_URL=http://localhost:4440 \
	  -e DATABASE_URL="jdbc:mysql://mysql/rundeckdb?autoReconnect=true" \
	  -e DATABASE_DRIVER="com.mysql.jdbc.Driver" \
	  -e DATABASE_USER="rundeckuser" \
	  -e DATABASE_PASS="password" \

```