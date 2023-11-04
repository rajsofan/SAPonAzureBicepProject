param publicIPAddresses string = 's4dpubip'
param location string = resourceGroup().location

resource publicIPAddresses_s4dpubip_name_resource 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: publicIPAddresses
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}


output PubIpID string = publicIPAddresses_s4dpubip_name_resource.id
