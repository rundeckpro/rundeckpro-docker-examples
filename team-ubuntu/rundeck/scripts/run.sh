#!/bin/bash
run_helpers() {
  local -r helper=$1
  local -a scripts=( ${@:2} )

  for script in "${scripts[@]}"
  do
      [[ ! -f "$script" ]] && {
          echo >&2 "WARN: $helper script not found. skipping: '$script'"
          continue
      }
      echo "### applying $helper script: $script"
      . "$script"
  done
}


# call the DB settings
run_helpers "prestart" "scripts/config_database.sh"


# RUN TEST PRESTART SCRIPT
if [[ -n "$CONFIG_SCRIPT_PRESTART" ]]
then

  config_scripts=( ${CONFIG_SCRIPT_PRESTART//,/ } )

  run_helpers "prestart" "${config_scripts[@]}"
else
  echo "### Prestart config not set. skipping..."
fi

#overwrite the serverURL of rundeck
sed -i 's,grails.serverURL\=.*,grails.serverURL\='${RUNDECK_URL}',g' /etc/rundeck/rundeck-config.properties


service rundeckd start

# Keep alive
tail -F -n100 \
 /var/log/rundeck/service.log \
 /var/log/rundeck/rundeck.executions.log \
 /var/log/rundeck/rundeck.jobs.log \
 /var/log/rundeck/rundeck.log \
 /var/log/rundeck/rundeck.options.log \
 /var/log/rundeck/rundeck.storage.log

