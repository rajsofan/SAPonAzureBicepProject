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

param networkSecurityGroupNmae string = 'NSG-${uniqueString(resourceGroup().id)}'
param isDiagEnabled bool = false
param LAWworkspaceID string

param securityRules array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSecurityGroupNmae
  location: resourceGroup().location
  properties: {
    securityRules: securityRules
  }
}

resource service 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(isDiagEnabled){
  name: 'setbypolicy'
  scope: nsg
  properties: {
    workspaceId: LAWworkspaceID
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }

}

output nsgID string = nsg.id
