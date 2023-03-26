

//Deployment Scope

//targetScope = 'subscription'


@description('Name of the Resource Group')
param SAPS4HANARGName string = 'RG-UKS-ENGINE-LZ1-NETWORK-01'
@description('location of all Resources')
param location string = 'uksouth'
//@description('Tags to apply to the Resource Group')
/*var tagValues = {
  createdBy:'Raj'
  environmentd:'Dev'
  BillingCenter: 'Azlab'

}
*/
//Parameters Vnet

//param 
@description('Name of the Vnet')

param SAPS4VNET string = 'SAPS4Vnet'

@description('Name of the subnet')

param Subnetname1 string = 'ApplicationSubnet'
param Subnetname2 string = 'FrontEndSubnet'
param Subnetname3 string = 'DatabaseSubnet'

//Parameters NSG
@description('Name of the NSG')
var ApplicationNSG = 'nsg1'

//param public ip

param dnsnameprefix string = toLower('${'azlab-vm2'}-${uniqueString(resourceGroup().id, 'azlab-vm2')}')




//-------------------------------------------------
//Create the Resource Group
//-------------------------------------------------

//resource SAPs4hanaRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  
  //name: SAPS4HANARGName
  //location: location
  //tags: tags
//}



resource SAPVnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
   name: SAPS4VNET
   location: location
   properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }

}

//Resource Block for creating the Vnet and the Subnets

resource SAPS4Subnets1 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: SAPVnet
  name: Subnetname1
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
       id: nsg1.id
    }
   
       }
        
    }
  
  resource SAPS4Subnet2 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
   parent: SAPVnet
   dependsOn: [
    SAPS4Subnets1
   ]
   name: Subnetname2
   properties: {
     addressPrefix: '10.0.2.0/24'
     networkSecurityGroup: {
       id: nsg1.id
     }
       
     }        
        
      }

   resource SAPS4Subnet3 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
   parent: SAPVnet
   dependsOn: [
    SAPS4Subnet2
   ]
   name: Subnetname3
  
   properties: {
    addressPrefix: '10.0.3.0/24'
    networkSecurityGroup: {
      id: nsg1.id
    }
     
             
      }
                  
       }


 //Resource Block for creating the nsg

 resource nsg1 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: ApplicationNSG
  location: location
  properties: {
     securityRules: [
       {
         name: 'AppSecurityRule'
         properties: {
          access:  'Allow'
          direction:  'Inbound'
          protocol:  '*'
          priority: 100
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
           

         }
       }
     ]
  }
  

 }

 resource vm1nic 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: 'azlabnic'
  location: location
  dependsOn: [
     SAPVnet
  ]
  properties: {
     ipConfigurations: [
       {
         name: 'ipconfig1'
         properties: {
           subnet: {
             id: resourceId('Microsoft.Network/VirtualNetworks/subnets', SAPS4VNET, 'ApplicationSubnet')
           }
            privateIPAllocationMethod: 'Dynamic'
      
         }
        
       }
      
     ]
  }
 }

 resource VM1 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'azlab-vm1'
  location: location
  properties: {
     networkProfile: {
       networkInterfaces: [
         {
           id: vm1nic.id
         }
       ]
      }
       hardwareProfile: {
         vmSize: 'Standard_B1ms'
       }
       storageProfile: {
         osDisk: {
          createOption:  'FromImage'
           managedDisk: {
             storageAccountType: 'Standard_LRS'
           }

         }
         imageReference: {
             publisher: 'canonical'
             offer: 'UbuntuServer'
             sku: '18_04-lts-gen2'
             version: 'latest'
         }
       }
        osProfile: {
            computerName: 'azlabvm1lnx'  
            adminUsername: 'Adminuser'
            adminPassword: 'Welcome@12345678'
             
               
        }
        
  }
 }

resource azlabvmnic2 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: 'azlabnic2'
  dependsOn: [
    SAPVnet
  ]
  location: location
  properties: {
     ipConfigurations: [
       {
         name: 'ipconfig2'
         properties: {
          publicIPAddress: {
            id: publicip1.id
          }
           privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', SAPS4VNET, 'ApplicationSubnet') 
          }
         }
        
       }
      
     ]
  }
}

resource publicip1 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'pub-ip1'
  location: location
  sku: {
     name: 'Basic'
     tier: 'Regional'
  }
  properties: {
     publicIPAllocationMethod: 'Dynamic'
     dnsSettings: {
       domainNameLabel: 'azlabvmpubip'
     }
  }
}


resource VM2 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'azlab-vm2'
  location: location 
  properties: {
     hardwareProfile: {
      vmSize: 'Standard_B2ms'
     }
     osProfile: {
      computerName: 'azlabvm1'
      adminUsername: 'adminuser'
      adminPassword: 'Welcome@12345678'
     }
     storageProfile: {
       imageReference: {
         publisher: 'MicrosoftWindowsServer'
         offer: 'WindowsServer'
         sku: '2022-datacenter-azure-edition'
         version: 'latest'
       }

     }
     
     networkProfile: {
      
      networkInterfaces: [
        {
          id: azlabvmnic2.id
        }

      ]
      
     }
      diagnosticsProfile: {
        bootDiagnostics: {
           enabled: false
        }
      }
  }
}

resource automationacct 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: 'azlab-automationaccount'
  location: location
  identity: {
     type: 'SystemAssigned'

  } 
   properties: {
     sku: {
      name:  'Free'
      
     }
   }
}

 output vnetid string = SAPVnet.id
