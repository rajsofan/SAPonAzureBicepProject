

//Deployment Scope

targetScope = 'subscription'


@description('Name of the Resource Group')
param SAPS4HANARGName string
@description('location of all Resources')
param location string
@description('Tags to apply to the Resource Group')
//param tags object

//Parameters Vnet

param LAWworkspaceID string
param SA string
param 






//-------------------------------------------------
//Create the Resource Group
//-------------------------------------------------

resource SAPs4hanaRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  
  name: SAPS4HANARGName
  location: location
  //tags: tags
}

module S4ApplicationVnet '../Modules/vnet.module.bicep' = {
  scope: resourceGroup(SAPs4hanaRG.name)
  name: 'SAPApplication-Vnet01'
  params: {
    LAWworkspaceID: 
    vnetName: 
  }
}
