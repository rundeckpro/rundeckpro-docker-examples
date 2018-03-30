#!/bin/bash
#/ Update the rundeck-config.properties to define the dataSource settings
#/ DATABASE_URL
#/ DATABASE_DRIVER
#/ DATABASE_USER
#/ DATABASE_PASS
#/ DATABASE_DIALECT

echo "Configuring datasource settings"

if [[ ! -z "$DATABASE_URL" ]];
then

#check if the  $DATABASE_DRIVER was added
if ! grep -q /etc/rundeck/rundeck-config.properties; then


cat >>/etc/rundeck/rundeck-config.properties <<END
dataSource.driverClassName=$DATABASE_DRIVER
dataSource.url = $DATABASE_URL
dataSource.username=$DATABASE_USER
dataSource.password=$DATABASE_PASS

rundeck.projectsStorageType=db

rundeck.storage.provider.1.type=db
rundeck.storage.provider.1.path=keys

END
if [[ -n "$DATABASE_DIALECT" ]] ;
then
cat >>/etc/rundeck/rundeck-config.properties <<END
dataSource.dialect = $DATABASE_DIALECT
END
fi

fi
fi


