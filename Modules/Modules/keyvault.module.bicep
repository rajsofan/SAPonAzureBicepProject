//Creates a Keyvault


//------------------------------------------------------------------------------------
// Paramter Section
//------------------------------------------------------------------------------------
param keyvaultName string = 'sapvmvault'
param location string = resourceGroup().location
param objectID string = 'a438937b-0dbf-436b-84a2-3cb6c8a5d389'


//------------------------------------------------------------------------------------
//  Resource Sections
//------------------------------------------------------------------------------------


resource secretsvault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyvaultName
  location: location
  properties: {
    createMode: 'default'
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    accessPolicies: [
       {
        objectId: objectID
        permissions: {
           secrets: [
             'get'
             'list'
             'set'
           ]
        }
        tenantId: subscription().tenantId
       }
    ]
   
    sku: {
      family: 'A'
      name:  'standard'
    }
    tenantId: subscription().tenantId
  }
}


param vmUserName string
@secure()
param vmPassword string

resource vmserets 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: secretsvault
  name: 'vmUsername'
  properties: {
     value: vmUserName
  }

}
