/* Creates a vnet peering between two vnets

@parameters
  LocalVnetname: String
  remoteVnetName: String
  remoteVnetID: String Existing ID for remote hub Vnet

*/
param localVnetName string
param remoteVnetName string
param remoteVnetID string
param allowFortwardedTraffic bool = true
param allowGatewayTransit bool = false
param allowVirtualNetworkAccess bool = true
param useRemoteGateways bool = false

resource peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${localVnetName}/${localVnetName}-to-${remoteVnetName}'
  properties: {
     allowForwardedTraffic: allowFortwardedTraffic
     allowGatewayTransit: allowGatewayTransit
     allowVirtualNetworkAccess: allowGatewayTransit
     useRemoteGateways: useRemoteGateways
     remoteVirtualNetwork: {
       id: remoteVnetID
     }
  }


}
