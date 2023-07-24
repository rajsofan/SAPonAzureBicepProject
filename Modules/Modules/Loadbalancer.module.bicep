/*This Module creates an Internal loadbalancer which applies to Sprcifically SAP applications*/


//Parameter Section

param loadBalancerName string
param location string
param VnetName string
param subnetName string
var loadbalancerFrontName = '${loadBalancerName}-frontend'
var loadbalancerBackendName = '${loadBalancerName}-backend'
var lbrulname = '${loadBalancerName}-lbrule'
var lbprobename = '${loadBalancerName}-healthprobe'
var subnetref = resourceId('Microsoft.Network/virtualNetworks/subnets', VnetName,subnetName)

var skuname = 'Standard'
var skutier = 'Regional'

//Resource Section

resource sapInternalLB 'Microsoft.Network/loadBalancers@2022-11-01' = {
  name: loadBalancerName
  location: location
  sku: {
   name: skuname
   tier: skutier
  }
   properties: {
     frontendIPConfigurations: [
       {
         name: loadbalancerFrontName
         properties: {
           privateIPAllocationMethod: 'Dynamic'
           subnet:  {
             id: subnetref
           }
            
         }
       }
     ]
     backendAddressPools: [
       {
         name: loadbalancerBackendName
       }
     ]
      // loadBalancingRules: [
      //    {
      //       name: lbrulname
      //       properties: {
      //          frontendIPConfiguration: {
      //            id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations',loadBalancerName,'loadBalancerFrontEnd')

      //         }
      //         //   backendAddressPools:[
      //         //      {
      //         //        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools',loadBalancerName, 'loadBalancerBackEnd')
      //         //      }
      //         //     ]
      //         //     probe: {
      //         //        id:resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, lbprobename)
      //         //     }
      //           frontendPort: 0
      //           backendPort: 0
      //           enableFloatingIP: false
      //           protocol: 'All'
      //           loadDistribution: 'Default'
      //           idleTimeoutInMinutes: 10    
      //       }
      //    }
      // ]
   }
}
