@description('The name of the function app that you wish to create.')
param appName string = 'fnapp${uniqueString(resourceGroup().id)}'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Unique name for the key vault.')
param keyVaultName string = 'keyvault1${uniqueString(resourceGroup().id)}'

@description('Unique name for the storage account.')
param storageAccountName string = 'azfunctions${uniqueString(resourceGroup().id)}'

var functionAppName = appName
var aspName = appName

module functionApp 'functionApp.bicep' = {
  name: functionAppName
  params: {
    aspName: aspName
    functionAppName: functionAppName
    keyVaultName: keyVaultName
    location: location
  }
}

param storageAccountNames array = [
  storageAccountName
  'second${uniqueString(resourceGroup().id)}'
]

module storageAccounts 'storage.bicep' = [for name in storageAccountNames: {
  name: name
  params: {
    location: location
    storageAccountName: name
    storageAccountType: storageAccountType
  }
}]

module keyVault 'keyvault.bicep' = {
  name: keyVaultName
  params: {
    functionPrincipalId: functionApp.outputs.principalId
    keyVaultName: keyVaultName
    location: location
    storageAccountName: storageAccountName
  }
  dependsOn:[
    storageAccounts
  ]
}
