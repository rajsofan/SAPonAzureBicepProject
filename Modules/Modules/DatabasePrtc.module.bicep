param location string
@secure()
param sqlServerAdministratorlogin string
@secure()
param sqlServerAdministroLoginPassword string

param sqlDatabaseSku object = {
  name:'Standard'
  tier: 'Standard'
}

var sqlServerName = 'teddy${location}${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'teddybear'

resource sqlServer 'Microsoft.Sql/servers@2022-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
     administratorLogin: sqlServerAdministratorlogin
     administratorLoginPassword:sqlServerAdministroLoginPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  name: sqlDatabaseName
  location: location
  parent:sqlServer
  sku: sqlDatabaseSku
}


@allowed([
  'Dev'
  'Prod'
])
param environmentName string = 'Dev'

param auditstorageAccountSkuName string = 'Standard_LRS'

var auditingEnabled = environmentName == 'Prod'
var auditStorageAccountName = take('bearaudits${location}${uniqueString(resourceGroup().id)}',24)


resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (auditingEnabled){
  name: auditStorageAccountName
  location: location
  sku: {
    name: auditstorageAccountSkuName
  }
  kind: 'StorageV2' 
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2022-08-01-preview' = if(auditingEnabled){
  name: 'default'
  parent:sqlServer
  properties: {
    state: 'Enabled'
    storageEndpoint: environmentName == 'Prod' ? auditStorageAccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: environmentName == 'Prod' ? listKeys(auditStorageAccount.id,auditStorageAccount.apiVersion).keys[0].value : ''
  }
}
