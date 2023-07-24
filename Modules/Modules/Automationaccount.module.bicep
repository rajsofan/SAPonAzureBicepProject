/*This Module creates an Internal loadbalancer which applies to Sprcifically SAP applications*/

//parameter section

@secure()
param automationAccountName string
param location string
//resource section

resource sapAutomationAcct 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: automationAccountName
  location: location
   properties: {
     publicNetworkAccess: true
      sku: {
        name:  'Free'
      }
   } 
}
