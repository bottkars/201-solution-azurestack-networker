# 201-solution-azurestack-networker

This Template Deploys and Configures DELL|EMC Nrtworker Virtual Edition onto Azurestack

Prework and Requirements:
  -  Have Custom Script for Linux extensions Available on AzureStackHub
  -  Upload Networker NVE VHD for Azure* to Blob in Subscription

## Expand and upload the Image

```bash
7z e AZURE-NVE-19.4.0.84.vhd.7z
``` 

Use Azure CLI or AzureStack Portal to upload the image to a blob container:


```bash
ACCOUNT_NAME=opsmanagerimage
DESTINATION="Networker/19.4"
az storage blob upload-batch --account-name ${ACCOUNT_NAME} -d images --destination-path ${DESTINATION} --source ./ --pattern "AZURE-NVE-19.4.0.84.vhd"
```
## Patch the base VHD  (19.4 or newer)
edit Patch /usr/local/avamar/bin/setnet.lib
```bash
detectHyperV() {
    isHV=n
    isAZ=n
    grep -A 2 "scsi" /proc/scsi/scsi | grep -qi "msft"
    if [ $? -eq 0 ]; then
        # Its HyperV
        important "Hyper-V environment detected"
        isHV="y"
        hypervisorDetected=2

        # see if its also Azure
        MDATA=`curl -s $AZUREMETADATAURL`
        if [ $? -eq 0 ]; then
            # May be Azure since we got metadata from curl
            JUNK=`echo $MDATA | egrep '^[{].+ID.+UD.+[}]'`
            if [ $? -eq 0 ]; then
              # Azure since we got proper metadata from curl
              isAZ=y
              important "Azure environment detected"
              hypervisorDetected=3
            else
## insert here for AzureStack            
              important "AzureStack environment detected"
              isAZ=y
              hypervisorDetected=3
## End insert, 
# comment next line              
#           warn "Got '$MDATA' from 'curl -s $AZUREMETADATAURL' but not recognized as Azure so ignoring"
            fi
        fi
    fi
}
```


AZ CLI Deployment Example:

```azurecli-interactive
az group create --name nve_from_cli --location local
```
Validate
```azurecli-interactive
az deployment group validate  \
--template-uri https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.json \
--parameters https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.parameters.json \
--resource-group nve_from_cli
```

```azurecli-interactive
az group create --name nve_from_cli --location local
az deployment group create  \
--template-uri https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.json \
--parameters https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.parameters.json \
--resource-group nve_from_cli
```

## Locally

Validate
```azurecli-interactive
az deployment group validate  \
--template-file ${HOME}/workspace/201-solution-azurestack-networker/azuredeploy.json \
--parameters ${HOME}/workspace/201-solution-azurestack-networker/azuredeploy.parameters.json \
--resource-group nve_from_cli
```

```azurecli-interactive
az group create --name nve_from_cli --location local
az deployment group create  \
--template-uri https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.json \
--parameters https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.parameters.json \
--resource-group nve_from_cli
```


Custom Values
```azurecli-interactive
az group create --name nve2_from_cli --location local
az deployment group create  \
--template-file ${HOME}/workspace/201-solution-azurestack-networker/azuredeploy.json \
--parameters ${HOME}/workspace/201-solution-azurestack-networker/azuredeploy.parameters.json \
--parameters nveExternalHostname=nveazs2.local.cloudapp.azurestack.external \
--parameters nveName=nveazs2 \
--resource-group nve2_from_cli
```
delete

```azurecli-interactive
az group delete --name nve_from_cli  -y
```

## GitOps from direnv
validate
```bash
az group create --name ${AZS_RESOURCE_GROUP} \
  --location ${AZS_LOCATION}
az deployment group validate  \
--template-uri https://raw.githubusercontent.com/bottkars/201-solution-azurestack-powerprotect/main/azuredeploy.json \
--parameters https://raw.githubusercontent.com/bottkars/201-solution-azurestack-powerprotect/main/azuredeploy.parameters.json \
--parameters ppdmPasswordOrKey="${SSH_KEYDATA}" \
--parameters ppdmName=${AZS_HOSTNAME:?variable is empty} \
--parameters ppdmImageURI=${AZS_IMAGE_URI:?variable is empty} \
--parameters ppdmVersion=${AZS_IMAGE:?variable is empty} \
--parameters diagnosticsStorageAccountExistingResourceGroup=${AZS_diagnosticsStorageAccountExistingResourceGroup:?variable is empty} \
--parameters diagnosticsStorageAccountName=${AZS_diagnosticsStorageAccountName:?variable is empty} \
--parameters vnetName=${AZS_vnetName:?variable is empty} \
--parameters vnetSubnetName=${AZS_vnetSubnetName:?variable is empty} \
--resource-group ${AZS_RESOURCE_GROUP:?variable is empty}
```

deploy
```bash
az group create --name ${AZS_RESOURCE_GROUP} \
  --location ${AZS_LOCATION}
az deployment group create  \
--template-uri https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/main/azuredeploy.json \
--parameters https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/main/azuredeploy.parameters.json \
--parameters ppdmPasswordOrKey="${SSH_KEYDATA}" \
--parameters ppdmName=${AZS_HOSTNAME:?variable is empty} \
--parameters ppdmImageURI=${AZS_IMAGE_URI:?variable is empty} \
--parameters ppdmVersion=${AZS_IMAGE:?variable is empty} \
--parameters diagnosticsStorageAccountExistingResourceGroup=${AZS_diagnosticsStorageAccountExistingResourceGroup:?variable is empty} \
--parameters diagnosticsStorageAccountName=${AZS_diagnosticsStorageAccountName:?variable is empty} \
--parameters vnetName=${AZS_vnetName:?variable is empty} \
--parameters vnetSubnetName=${AZS_vnetSubnetName:?variable is empty} \
--resource-gr

## Copying an Azure Image

azcopy copy /Volumes/minio/dps-products/networker/19.3/AZURE-NVE-19.3.0.16.vhd https://opsmanagerimage.blob.local.azurestack.external/images/Networkrr/19.3/AZURE-NVE-19.3.0.16.vhd$SASTOKEN
