/*Deploys a route table with default route to the AzureFirewall/NVA.Fi the name parameter is not supplied a randomely generated name will be used
if nothing is passed in for additionalRoutesObject it will build a default 0.0.0.0 route with the nvaIP
for gateway subnets you can pass in additional routes

e.g.[
{
 name: 'routeb'
  properties: {
    addressPrefix: '10.1.2.0/24'
    nextHopTupe: 'VirtualAppliance'
    nextHopIPAddress: '10.1.3.4
  }
}
]
*/

param routeTableName string = 'UDR-${uniqueString(resourceGroup().id)}'
param nvaIP string
param additionalRoutesObject array = [
  
]
param disableBgpRoutePropagation bool = true

resource route 'Microsoft.Network/routeTables@2022-07-01' = {
  name: routeTableName
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: ((empty(additionalRoutesObject)) ? [
      {
        name: 'DefaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: nvaIP
        }
      }
      
    ]:additionalRoutesObject)
  }
}

output id string = route.id
output routes array = route.properties.routes
