@description('Same Location of resource group for all resources in the same deployment.')
param location string = resourceGroup().location

@description('Name for the Account. The account name must be unique within the subscription')
param netAppAccountName string = 'anfacc${uniqueString(resourceGroup().id)}'

@description('Name for the capacity pool. The capacity pool name must be unique for each NetApp account.')
param netAppPoolName string = 'pool${uniqueString(resourceGroup().id)}'

@description('Size of the capacity pool. The minimum  size is 4 TiB.')
@minValue(4398046511104)
@maxValue(549755813888000)
param poolSizeBytes int = 4398046511104

@description('Name for the NFS Volume. A volume name must be unique within each capacity pool. It must be at aleast three characters long and you can use any alphanumeric characters.')
param netAppVolumeName string = 'volume${uniqueString(resourceGroup().id)}'

@description('Amount of logical storage that is allocated to the volume.')
@minValue(107374182400)
@maxValue(109951162777600)
param volSizeBytes int = 107374182400

@description('Name of the Virtual Network (VNet) from which you want to access the volume. The VNet must have a subnet delegated to Azure NetApp Files.')
param virtualNetworkName string = 'anfvnet${uniqueString(resourceGroup().id)}'

@description('Virtual Network address range.')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Root Access to the volume.')
param allowedClients string = '0.0.0.0/0'

@description('Subnet name that you want to use for the volume. The subnet must be delegated to Azure NetApp Files.')
param subnetName string = 'anfsubnet${uniqueString(resourceGroup().id)}'

@description('Subnet address range.')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('Target performance for the capacity pool. Service level: Ultra, Premium, or Standard.')
@allowed([
  'Premium'
  'Ultra'
  'Standard'
])
param serviceLevel string = 'Standard'

@description('NFS version (NFSv3 or NFSv4.1) for the volume.')
@allowed([
  'NFSv3'
  'NFSv4.1'
])
param protocolTypes string = 'NFSv3'

@description('Read only flag.')
@allowed([
  false
  true
])
param unixReadOnly bool = false

@description('Read/write flag.')
@allowed([
  false
  true
])
param unixReadWrite bool = true

@description('Snapshot directory visible flag.')
@allowed([
  false
  true
])
param snapshotDirectoryVisible bool = false

var capacityPoolName = '${netAppAccountName}/${netAppPoolName}'
var volumeName = '${netAppAccountName}/${netAppPoolName}/${netAppVolumeName}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          delegations: [
            {
              name: 'NetAppDelegation'
              properties: {
                serviceName: 'Microsoft.NetApp/volumes'
              }
            }
          ]
        }
      }
    ]
  }
}

resource netAppAccount 'Microsoft.NetApp/netAppAccounts@2020-06-01' = {
  name: netAppAccountName
  location: location
  properties: {
  }
}

resource capacityPool 'Microsoft.NetApp/netAppAccounts/capacityPools@2020-06-01' = {
  name: capacityPoolName
  location: location
  properties: {
    serviceLevel: serviceLevel
    size: poolSizeBytes
  }
  dependsOn: [
    netAppAccount
  ]
}

resource volume 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2020-06-01' = {
  name: volumeName
  location: location
  properties: {
    serviceLevel: serviceLevel
    creationToken: netAppVolumeName
    usageThreshold: volSizeBytes
    exportPolicy: {
      rules: [
        {
          ruleIndex: 1
          unixReadOnly: unixReadOnly
          unixReadWrite: unixReadWrite
          cifs: false
          nfsv3: ((protocolTypes == 'NFSv3') ? bool('true') : bool('false'))
          nfsv41: ((protocolTypes == 'NFSv4.1') ? bool('true') : bool('false'))
          allowedClients: allowedClients
        }
      ]
    }
    protocolTypes: [
      protocolTypes
    ]
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
    snapshotDirectoryVisible: snapshotDirectoryVisible
  }
  dependsOn: [
    resourceId('Microsoft.NetApp/netAppAccounts/capacityPools', netAppAccountName, netAppPoolName)
    virtualNetwork
  ]
}