# 201-solution-azurestack-networker

This Template Deploys and Configures DEL|EMC Avamar Virtual Edition onto Azurestack

Prework and Requirements:
  -  Have Custom Script for Linux extensions Available on AzureStackHub
  -  Upload Networker NVE VHD for Azure* to Blob in Subscription




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
--parameters nveExternalHostname=nve2azs.local.cloudapp.azurestack.external \
--parameters nveName=nve2azs \
--resource-group nve2_from_cli
```
delete

```azurecli-interactive
az group delete --name nve_from_cli  -y
```



## Copying an Azure Image

azcopy copy /Volumes/minio/dps-products/networker/19.3/AZURE-NVE-19.3.0.16.vhd https://opsmanagerimage.blob.local.azurestack.external/images/Networkrr/19.3/AZURE-NVE-19.3.0.16.vhd$SASTOKEN