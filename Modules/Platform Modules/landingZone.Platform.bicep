/*DEploys the engine landing zone platform module*/

//Deployment Scope

targetScope = 'subscription'

//global parameters

param isVwan bool
param deployVPNGW bool
param isDiagEnabled bool
param laWorkspaceID string
param hubVnetID string
param nvaIP string
param hubRouteTableName string

//LZ params

param landingZoneModVnetRG string
param landingZoneRsvRG string
param location string
param landingZoneVnetName string
param landingZoneVnetPrefix string
param landingZoneDefaultSubnetName string
param landingZoneDefaultSubnetPrefix string
param routeTableName string
param landingZoneDefaultNsgName string
param dnsServers array

param deployLandingZineRsv bool
param landingZoneRsvName string
param landingZoneRsvStorageType string
param landingZoneEsvEnableCrossRegionRestore bool
param vmBackupInclusionTag string
param isPrimaryDeployment bool
param deployDefenderForCloudPlans bool
param defenderResourceTypes array = [
  
'VirtualMachines'
'SqlServers'
'AppServices'
'StroageAccounts'
'SqlServerVirtualMachines'
'Containers'
'KeyVaults'
'DNS'
'Arm'
'OpenSourceRelationalDatabases'

]

param ascOwnerEmail string


// Create Resource Groups

resource lzRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: landingZoneModVnetRG
  location: location
}




//Deploy the virtual network for SAP Application

module SAPApplicationVnet '../vnet.module.bicep' = {
  scope: resourceGroup(lzRG.name)
  name: landingZoneVnetName
  params: {
    LAWworkspaceID: laWorkspaceID
    vnetName: landingZoneVnetName
  }
}





//Deploy UDR for Landing Zone


//Deploy NSG for Landing Zone


//peering
//deploy hub<-> vent connection from landing zone

/*module landingZonetoHUBVentConnection '../vnetPeering.module.bicep' = if ( !isVwan) {
 name: 'DP-ENGINE-LZ-LOCALVNETPEERING'
 scope: resourceGroup(lzRG.name)
  params: {
    localVnetName: '${last(split(landingZoneVnet.outputs.vnetID, '/'))}'
    remoteVnetName: hubVnetName
    remoteVnetID: hubVnetID
    useRemoteGateways: (deployVPNGW) ? true : false
  }
  
}
*/


/* module hubtoLandingZoneVnetConnection '../vnetPeering.module.bicep' = if ( !isVwan) {
   name: 'DP-ENGINE-LZ-HUBVNETPEERING'
   scope: resourceGroup(hubVnetNameArray[2],hubVnetNameArray[4])
   params: {
    localVnetName: hubVnetName
    remoteVnetName: '${last(split(landingZoneVnet.outputs.vnetID , '/'))}'
    allowGatewayTransit: (deployVPNGW) ? true : false
    remoteVnetID: hubVnetID

   }
   

}
*/

//output vnetID string = landingZoneVnet.outputs.vnetID
//output udrID string = landingZoneUDR.outputs.id
//output nsgID string = landingZoneNSG.outputs.nsgID
