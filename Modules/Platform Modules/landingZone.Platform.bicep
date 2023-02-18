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
param landingZoneDefaultnsgName string
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

var hubVnetNameArray = split(hubVnetID,'/')
var hubVnetName = hubVnetNameArray[8]
var landingZoneSubnetsDefinitions = [

  {
    name: landingZoneDefaultSubnetName
    properties: {
      addressPrefix: landingZoneDefaultSubnetPrefix
      networkSecurityGroup : {
        id: landigZoneNSG.outputs.nsgID
      }
      routeTable: {
        id: landingZoneUDR.outputs.id
      }
    }
  }

]

// Create Resource Groups

resource lzRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: landingZoneModVnetRG
  location: location
}

