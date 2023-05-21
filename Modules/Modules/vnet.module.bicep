/*
Deploys a single Vnet with one or more subnets.If no parameters are provided a default address space is taken and outputs the Vnet ID and
 array containing all the subnets 
 */
param location string
param addressPrefix string = '10.0.0.0/16'
param subnetNames array = [
  'Application'
  'Database' 
  'Anf'
  'Managment'
]
param nsgId string
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
     addressSpace:{
       addressPrefixes: [
         addressPrefix
       ]
     }
      subnets: [for (subnetName, i) in subnetNames: {
        name:subnetName
        properties: {
          addressPrefix: '10.0.${i}.0/24'
          networkSecurityGroup: {
             id:nsgId
          }
        }
      }]
  }
}



output vnetID string = vnet.id
output vnetName string = vnet.name
output subnet array = vnet.properties.subnets
