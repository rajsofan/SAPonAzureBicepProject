//Deployment Scope

targetScope = 'subscription'
//Global Parameters
@description('Specify the SAP System Identifier number for your landscape')
@maxLength(3)
param SAPSID string = 'S4D'
@description('Specify the Environment type of the deployment')
@allowed([ 'Dev'
  'Prod'
  'SBX'
  'QAS' ])
param Environment string = 'Dev'
param SAPSolutionName string = 'S4HANA'
param resourceTags object = {
  Environment: Environment
  CreatedBy: 'Bicep'
  Location: location
}


param VirtualMachineUserName string
@secure()
param VirtualMachinePassword string

@description('location of all Resources')
param location string = 'uksouth'

//Resource group Parameters
@description('Name of the Resource Group')
param SAPS4HANARGName string = 'RG-${SAPSolutionName}-${SAPSID}-${Environment}'
//Create the resource group

resource SAPResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: SAPS4HANARGName
  tags: resourceTags
  location: location
}

//NSG Parameters

param NSGName string = 'nsg-${SAPSID}-${Environment}'

//Create the NSG

module SAPNSGRules '../Modules/networkSecurityGroup.module.bicep' = {
  scope: resourceGroup(SAPResourceGroup.name)
  name: NSGName
  params: {
    location: location
    networkSecurityGroupNmae: NSGName

  }
}

//Vnet Parameters
param vnetName string = 'vnet-${SAPSID}${Environment}'
//var items = [for i in range(1, 5): 'items${i}']
//Vnet and Subnet resource Deploy
module SAPVnet '../Modules/vnet.module.bicep' = {
  dependsOn: [
    SAPResourceGroup
  ]
  scope: resourceGroup(SAPS4HANARGName)
  name: vnetName
  params: {
    vnetName: vnetName
    location: location
    nsgId: SAPNSGRules.outputs.nsgID
  }
}

module SAPVm '../Modules/SAPvm.module.bicep' = {
  scope: SAPResourceGroup
  dependsOn: [
    SAPVnet
  ]

  name: 'VM-${SAPSolutionName}-${SAPSID}'
  params: {
    availabilitySetName: 'avset-${SAPSolutionName}-${SAPSID}'
    location: location
    SAPVmName: 'VM-${SAPSolutionName}-${SAPSID}'
    subnetName: 'Application'
    virtualMachineUserName: VirtualMachineUserName
    vNetName: vnetName
    vnetResourceGroup: SAPS4HANARGName
    virtualMachinePassword: VirtualMachinePassword
    virtualMachineCount: 2
    
  }
}

// Parameters for public IP

param pubIpName string = 'pubip-${Environment}-${SAPSID}'

//Create Public IP for ssh

module publicip '../Modules/publicip.module.bicep' = {
  dependsOn: [
     SAPResourceGroup
  ]
  scope: resourceGroup(SAPS4HANARGName)
  name: pubIpName
  params: {
    location: location
    publicIPAddresses: pubIpName
  }
  

}


//Keyvault parameters
param sapKvName string = 'sapkvm${uniqueString(utcNow())}'
module sapkvm '../Modules/keyvault.module.bicep' = {
  scope: resourceGroup(SAPS4HANARGName)
  dependsOn: [
    SAPResourceGroup
  ]
  name: sapKvName
  params: {
    vmPassword: VirtualMachinePassword
    vmUserName: VirtualMachineUserName
    keyvaultName: sapKvName
    location:location
    
  }
}


//Jumpserver paramters
param jumpserverVMName string = 'sapdeploy${Environment}${SAPSID}'
param avsetNameJmpSrvr string = 'avset${Environment}${SAPSID}'
param jmpVmSize string = 'Standard_B2s'
module jumpservervm '../Modules/jmpServer.module.bicep' = {
  dependsOn: [
    publicip
    SAPVnet
  ]
  scope: resourceGroup(SAPS4HANARGName)
  name: jumpserverVMName
  params: {
    availabilitySetName: avsetNameJmpSrvr
    jmpVmName: jumpserverVMName
    location: location
    subnetName: 'Managment'
    virtualMachinePassword: VirtualMachinePassword
    virtualMachineUserName: VirtualMachineUserName
    vNetName: vnetName
    vnetResourceGroup: SAPS4HANARGName
    pubIPAddressID:publicip.outputs.PubIpID
    virtualMachineCount:1
    jmpVmSize:jmpVmSize
  }
}



