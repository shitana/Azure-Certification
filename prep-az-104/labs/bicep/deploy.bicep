param appLocation string = resourceGroup().location
param webAppName string
param planSku string = 'S1'
param phpVersion string = 'PHP|8.2'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'AwesomeAppServicePlan'
  location: appLocation
  kind: 'linux'
  sku: {
    name: planSku
    tier: 'Standard'
  }
  properties: {
    reserved: true
  }
}

resource webAppPortal 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: appLocation
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: phpVersion
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
