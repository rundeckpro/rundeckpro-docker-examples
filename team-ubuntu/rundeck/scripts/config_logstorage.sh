#!/bin/bash
#/ Update the framework.properties to define the logstorage
#/ LOGSTORATE_URL
#/ LOGSTORATE_ACCESSKEY
#/ LOGSTORATE_SECRETKEY
#/ LOGSTORATE_BUCKET

echo "Writing log storage configuration"

if [[ ! -z "$LOGSTORATE_BUCKET"  ]];
then

if ! grep -q "framework.plugin.ExecutionFileStorage" /etc/rundeck/framework.properties
then
cat >>/etc/rundeck/framework.properties <<END
#AWSAccessKeyId and AWSSecretKey can be specified in the file
framework.plugin.ExecutionFileStorage.com.rundeck.rundeckpro.amazon-s3.AWSAccessKeyId=$LOGSTORATE_ACCESSKEY
framework.plugin.ExecutionFileStorage.com.rundeck.rundeckpro.amazon-s3.AWSSecretKey=$LOGSTORATE_SECRETKEY

#name of the bucket
framework.plugin.ExecutionFileStorage.com.rundeck.rundeckpro.amazon-s3.bucket=$LOGSTORATE_BUCKET

#path to store the logs
framework.plugin.ExecutionFileStorage.com.rundeck.rundeckpro.amazon-s3.path=logs/\${job.project}/\${job.execid}.log
END

if [[ ! -z "$LOGSTORATE_URL"  ]];
then

cat >>/etc/rundeck/framework.properties <<END
framework.plugin.ExecutionFileStorage.com.rundeck.rundeckpro.amazon-s3.endpoint=$LOGSTORATE_URL
framework.plugin.ExecutionFileStorage.com.rundeck.rundeckpro.amazon-s3.pathStyle=true
END
fi

cat - >>/etc/rundeck/rundeck-config.properties <<END
rundeck.execution.logs.fileStoragePlugin=com.rundeck.rundeckpro.amazon-s3
rundeck.execution.logs.fileStorage.retrievalRetryDelay=2
END

fi

fi

