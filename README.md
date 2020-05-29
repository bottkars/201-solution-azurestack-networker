# 201-solution-azurestack-networker

This Template Deploys and Configures DEL|EMC Avamar Virtual Edition onto Azurestack

Prework and Requirements:
  -  Have Custom Script for Linux extensions Available on AzureStackHub
  -  Upload Networker NVE VHD for Azure* to Blob in Subscription




AZ CLI Deployment Example:

```azurecli-interactive
az group create --name nve_from_cli --location local
```

```azurecli-interactive
az deployment group validate  \
--template-uri https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.json \
--parameters https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.parameters.json \
--resource-group nve_from_cli
```

```azurecli-interactive
az deployment group create  \
--template-uri https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.json \
--parameters https://raw.githubusercontent.com/bottkars/201-solution-azurestack-networker/master/azuredeploy.parameters.json \
--resource-group nve_from_cli
```

delete

```azurecli-interactive
az group delete --name nve_from_cli  -y
```
