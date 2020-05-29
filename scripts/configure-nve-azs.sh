#!/bin/bash
exec &> >(tee -a /root/install.log)
exec 2>&1
set -e
function retryop()
{
  retry=0
  max_retries=$2
  interval=$3
  while [ ${retry} -lt ${max_retries} ]; do
    echo "Operation: $1, Retry #${retry}"
    eval $1
    if [ $? -eq 0 ]; then
      echo "Successful"
      break
    else
      let retry=retry+1
      echo "Sleep $interval seconds, then retry..."
      sleep $interval
    fi
  done
  if [ ${retry} -eq ${max_retries} ]; then
    echo "Operation failed: $1"
    exit 1
  fi
}
echo "Installing jq"
curl -s -O -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 755 jq-linux64
chmod +X  jq-linux64
mv jq-linux64 /usr/local/bin/jq
export PATH=/opt/emc-tools/bin:$PATH

function get_setting() {
  key=$1
  local value=$(echo $settings | jq ".$key" -r)
  echo "${value}" ## ( use "${VAR}" to retain spaces, KB)
}


until [ -f /var/lib/waagent/CustomDataClear ]
do
     sleep 5
done
custom_data_file="/var/lib/waagent/CustomDataClear"
settings=$(cat ${custom_data_file})
NVE_PASSWORD=$(get_setting NVE_PASSWORD)
NVE_COMMON_PASSWORD=$(get_setting NVE_COMMON_PASSWORD)
NVE_TIMEZONE=$(get_setting NVE_TIMEZONE)
NVE_EXTERNAL_FQDN=$(get_setting NVE_EXTERNAL_FQDN)
EXTERNAL_HOSTNAME=$(get_setting EXTERNAL_HOSTNAME)


WORKFLOW=NveConfig
echo "waiting for AVAMAR $WORKFLOW  to be available"
### get the SW Version
until [[ ! -z $NVE_CONFIG ]]
do
NVE_CONFIG=$(/opt/emc-tools/bin/avi-cli --user root --password "${NVE_PASSWORD}" \
 --listrepository ${NVE_PASSWORD} \
 | grep ${WORKFLOW} | awk  '{print $1}' )
sleep 5
printf "."
done


echo "waiting for ave-config to become ready"
until [[ $(/opt/emc-tools/bin/avi-cli --user root --password "${NVE_PASSWORD}" \
 --listhistory ${NVE_PASSWORD} | grep nve-config | awk  '{print $5}') == "ready" ]]
do
printf "."
sleep 5
done
echo "ave-config ready"

if [[ -z  ${NVE_EXTERNAL_FQDN} ]]
then
/opt/emc-tools/bin/avi-cli --user root --password "${NVE_PASSWORD}" --install ave-config  \
    --input timezone_name="${NVE_TIMEZONE}" \
    --input common_password=${NVE_COMMON_PASSWORD} \
    --input use_common_password=true \
    --input repl_password=${NVE_COMMON_PASSWORD} \
    --input rootpass=${NVE_COMMON_PASSWORD} \
    --input mcpass=${NVE_COMMON_PASSWORD} \
    --input viewuserpass=${NVE_COMMON_PASSWORD} \
    --input admin_password_os=${NVE_COMMON_PASSWORD} \
    --input root_password_os=${NVE_COMMON_PASSWORD} \
    ${NVE_PASSWORD}
else
/opt/emc-tools/bin/avi-cli --user root --password "${NVE_PASSWORD}" --install ave-config  \
    --input timezone_name="${NVE_TIMEZONE}" \
    --input common_password=${NVE_COMMON_PASSWORD} \
    --input use_common_password=true \
    --input repl_password=${NVE_COMMON_PASSWORD} \
    --input rootpass=${NVE_COMMON_PASSWORD} \
    --input mcpass=${NVE_COMMON_PASSWORD} \
    --input viewuserpass=${NVE_COMMON_PASSWORD} \
    --input admin_password_os=${NVE_COMMON_PASSWORD} \
    --input root_password_os=${NVE_COMMON_PASSWORD} \
    --input rmi_address=${NVE_EXTERNAL_FQDN} \
    ${NVE_PASSWORD}
fi


echo "finished deployment"