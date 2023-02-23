/*
Deploys a single Vnet with one or more subnets.If no parameters are provided a default address space is taken and outputs the Vnet ID and
 array containing all the subnets 
 */

param addressPrefix string = '10.0.0.0/16'

param ddosProtection bool = false
param ddosProtectionPlanId string = ''
param privateEndpointNetworkPolicies string = 'disabled'
param subnetPropertyObject array = [
  
  {
    name: 'default'
    properties: {
      addressPrefix: '10.0.1.0/24'
    }
  }
]
param dnsServers array = []
param vnetName string
param isDiagEnabled bool = false
param LAWworkspaceID string


var withDdos = {
  enableDdosProtection: ddosProtection
  ddosProtectionPlan: {
    id:ddosProtectionPlanId
  }
  addressSpace: {
    addressPrefixes: [
      addressPrefix
    ]
  }
  dhcpOptions: {
    dnsServers: dnsServers
  }
  subnets: subnetPropertyObject
}

var withoutDdos = {
   addressSpace: {
    addressPrefixes: [
      addressPrefix
    ]
   }
   dhcpOptions: {
    dnsServers: dnsServers
   }
   subnets: subnetPropertyObject
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: ddosProtection ? withDdos : withoutDdos
}

resource service 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (isDiagEnabled) {
  name: 'setbypolicy'
  scope: vnet
  properties: {
    workspaceId: LAWworkspaceID
    logs: [
      {
       category: 'VMProtectionAlerts'
       enabled: true 
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
  
}

output vnetID string = vnet.id
output vnetName string = vnet.name
output subnet array = vnet.properties.subnets
