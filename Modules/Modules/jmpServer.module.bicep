/*
Single VM
 */

//VM Parameters

param jmpVmName string
param location string
param jmpVmSize string
param virtualMachineUserName string
@secure()
param virtualMachinePassword string
param operatingSystemType string = 'SLES 12'
param availabilitySetName string
param availabilitySetPlatformDefaultDomainCount int = 2
param availabilitySetPlatformUpdateDomainCount int = 5
param vnetResourceGroup string
param vNetName string
param subnetName string
param virtualMachineCount int = 2


var images = {
  'Windows Server 2012 Datacenter': {
    sku: '2012-Datacenter'
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    OSType: 'Windows'
  }
  'Windows Server 2012 R2 Datacenter': {
    sku: '2012-R2-Datacenter'
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    OSType: 'Windows'
  }
  'Windows Server 2016 Datacenter': {
    sku: '2016-Datacenter'
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    OSType: 'Windows'
  }
  'SLES 12': {
    sku: '12-SP4'
    offer: 'SLES-SAP'
    publisher: 'SUSE'
    OSType: 'Linux'
  }
  'RHEL 7': {
    sku: '7.5'
    offer: 'RHEL-SAP'
    publisher: 'RedHat'
    OSType: 'Linux'
  }
  'Oracle Linux 7': {
    sku: '7.5'
    offer: 'Oracle-Linux'
    publisher: 'Oracle'
    OSType: 'Linux'
  }
}

/*@allowed([
  'sshPublicKey'
  'password'
])
//param authenticationtype string = 'password'
*/
@description('The type of the operating system you want to deploy.')
/*@allowed([
  'Windows Server 2012 Datacenter'
  'Windows Server 2012 R2 Datacenter'
  'Windows Server 2016 Datacenter'
  'SLES 12'
  'RHEL 7'
  'Oracle Linux 7'
])
//param osType string = 'SLES 12'
*/
param dataDisk array = []
var subnetRef = resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, subnetName)

//Availability Set

resource AvailabilitySetName 'Microsoft.Compute/availabilitySets@2023-03-01' = {
  name: availabilitySetName
  sku: {
    name: 'Aligned'
  }
  location: location
  properties: {
    platformFaultDomainCount: availabilitySetPlatformDefaultDomainCount
    platformUpdateDomainCount: availabilitySetPlatformUpdateDomainCount

  }
}

param pubIPAddressID string

//Vm Resource Section

resource SAPVMNic 'Microsoft.Network/networkInterfaces@2022-11-01' = [for i in range(0, virtualMachineCount): {
  name: '${jmpVmName}-${i + 1}-nic1'
  location: location
  dependsOn: [
    AvailabilitySetName
  ]
  properties: {
    
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
          publicIPAddress: {
             id: pubIPAddressID
          }
        }
        
      }
    ]
  
  }
}]

resource jmpVM 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, virtualMachineCount): {
  name: '${jmpVmName}-${i + 1}'

  dependsOn: [
    SAPVMNic
  ]
  location: location
  properties: {
    hardwareProfile: {
      vmSize: jmpVmSize

    }

    osProfile: {
      adminUsername: virtualMachineUserName
      adminPassword: virtualMachinePassword
      computerName: '${jmpVmName}-${i + 1}'
      linuxConfiguration: {
        disablePasswordAuthentication: false

      }

    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${jmpVmName}-${i + 1}-nic1')
        }
      ]
    }
    availabilitySet: {
      id: AvailabilitySetName.id
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
    storageProfile: {

      osDisk: {
        name: '${jmpVmName}-${i + 1}-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      imageReference: {
        publisher: images[operatingSystemType].publisher
        offer: images[operatingSystemType].offer
        sku: images[operatingSystemType].sku
        version: 'latest'
      }
      dataDisks: dataDisk

    }
  }
}]

output availabilitySetID string = AvailabilitySetName.id
