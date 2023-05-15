param locations array = [
 'westeurope'
 'eastus2'
 'eastasia'
]

@secure()
param sqlServerAdministratorLogin string
@secure()
param sqlServerAdministratorLoginPassword string

module database '../Modules/DatabasePrtc.module.bicep' = [for location in locations: {
   name: 'database-${location}'
   params: {
    location: location
    sqlServerAdministratorlogin: sqlServerAdministratorLogin
    sqlServerAdministroLoginPassword: sqlServerAdministratorLoginPassword
   }
  
}]
