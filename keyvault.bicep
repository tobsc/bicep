param keyVaultName string
param location string
param functionPrincipalId string
param storageAccountName string

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        objectId: functionPrincipalId
        permissions: {
          secrets:[
            'Get'
            'List'
          ]
        }
        tenantId: tenant().tenantId
      }
    ]
    tenantId: tenant().tenantId
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource keyvault_tableConnection 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'TableStorageConnectionString'
  parent: keyvault
  properties: {
    attributes: {
      enabled: true
      exp: 1713598445
    }
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
}
