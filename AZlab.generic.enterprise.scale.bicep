/* Engine platform
*/

//Engine version
param engineVersion string

//Deployment scope
targetScope = 'managementGroup'

//Global Engine Parameters

param managmentSubcriptionID string
param connectivitySubscriptionID string
param identitySubscriptionID string
param rootManagmentGroup string
param primaryLocation string
param secondaryLocation string
param isPrimaryDeployment bool
param globalTags object = {
  
  'Engine-Version' : engineVersion
  'Engine-EnvironmentType': 'Production'
  'Engine-DeployDate': utcNow('d')
}
