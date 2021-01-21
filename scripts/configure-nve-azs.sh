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


until [ -f /var/lib/waagent/CustomData ]
do
     sleep 5
done
settings=$(base64 -d /var/lib/waagent/CustomData)
NVE_PASSWORD=$(get_setting NVE_PASSWORD)
NVE_COMMON_PASSWORD=$(get_setting NVE_COMMON_PASSWORD)
NVE_TIMEZONE=$(get_setting NVE_TIMEZONE)
NVE_EXTERNAL_FQDN=$(get_setting NVE_EXTERNAL_FQDN)
EXTERNAL_HOSTNAME=$(get_setting EXTERNAL_HOSTNAME)
NVE_ADD_DATADOMAIN_CONFIG=$(get_setting NVE_ADD_DATADOMAIN_CONFIG)
NVE_DATADOMAIN_HOST=$(get_setting NVE_DATADOMAIN_HOST)
NVE_DDBOOST_USER=$(get_setting NVE_DDBOOST_USER)
NVE_DDBOOST_USER_PWD=$(get_setting NVE_DDBOOST_USER_PWD)
NVE_DATADOMAIN_SYSADMIN=$(get_setting NVE_DATADOMAIN_SYSADMIN)
NVE_DATADOMAIN_SYSADMIN_PWD=$(get_setting NVE_DATADOMAIN_SYSADMIN_PWD)

WORKFLOW=NveConfig
echo "waiting for Networker $WORKFLOW  to be available"
### get the SW Version
until [[ ! -z $NVE_CONFIG ]]
do
NVE_CONFIG=$(/opt/emc-tools/bin/avi-cli --user root --password "${NVE_PASSWORD}" \
 --listrepository ${NVE_PASSWORD} \
 | grep ${WORKFLOW} | awk  '{print $1}' )
sleep 5
printf "."
done


echo "waiting for nve-config to become ready"
until [[ $(/opt/emc-tools/bin/avi-cli --user root --password "${NVE_PASSWORD}" \
 --listhistory ${NVE_PASSWORD} | grep NveConfig | awk  '{print $5}') == "ready" ]]
do
printf "."
sleep 5
done
echo "nve-config ready"
NVE_CONFIG=$(/opt/emc-tools/bin/avi-cli --user root --password "${NVE_PASSWORD}" \
 --listhistory ${NVE_PASSWORD} | grep NveConfig | awk  '{print $1}')
# will add dd later
# if [[ -z  ${NVE_DD} ]]
# then
/opt/emc-tools/bin/avi-cli --user root --password "${NVE_PASSWORD}" --install ${NVE_CONFIG//.avp}  \
    --input timezone_name="${NVE_TIMEZONE}" \
    --input root_password_os=${NVE_COMMON_PASSWORD} \
    --input admin_password_os=${NVE_COMMON_PASSWORD} \
    --input tomcat_keystore_password=${NVE_COMMON_PASSWORD} \
    --input authc_admin_password=${NVE_COMMON_PASSWORD} \
    --input add_datadomain_config=false \
    --input new_ddboost_user=false \
    --input snmp_string=public \
    --input datadomain_host=${NVE_DATADOMAIN_HOST} \
    --input ddboost_user=${NVE_DDBOOST_USER} \
    --input ddboost_user_pwd=${NVE_DDBOOST_USER_PWD} \
    --input ddboost_user_pwd_cf=${NVE_DDBOOST_USER_PWD} \
    --input datadomain_sysadmin=${NVE_DATADOMAIN_SYSADMIN} \
    --input datadomain_sysadmin_pwd=${NVE_DATADOMAIN_SYSADMIN_PWD} \
    --input storage_path=nveboost \
    ${NVE_PASSWORD}
# else

# fi


echo "finished deployment"