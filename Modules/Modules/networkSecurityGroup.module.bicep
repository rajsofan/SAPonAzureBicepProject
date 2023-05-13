/*Deploys a network Security group with default rules. An Existiing subnet ID parameter must be provided

@parameters
   networkSecurityGroupName: String
   SecurityRules: Array[] .e.g:
         {
          name: 'allow-rdp;
          properties: {
            priroty:1000
            sourceAddressPrefix: '*'
            protocol: 'TCP'
            destinationPortRange: '3389'
            access: 'Allow'
            direction: 'Inbound'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
          }
         }

*/

param networkSecurityGroupNmae string
param location string
//param securityRules array = []

var osSecurityRules = {

  Linux: [
    {
      name: 'SSH'
      properties: {
        description: 'Allow SSH Subnet'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '22'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 100
        direction: 'Inbound'
      }
    }
  ]
}
resource NetworkSecGrp 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSecurityGroupNmae
  location: location
  properties: { 
     securityRules: [
     {name: 'SSH'
      properties: {
        description: 'Allow SSH Subnet'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '22'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 100
        direction: 'Inbound' 
      }
    }
     ]
  }
}


output nsgID string = NetworkSecGrp.id
