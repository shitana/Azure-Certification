# prep-az-400
## Manage Azure Identities and Governance
### Azure Administration
* Cloud is made by Ressources (any entity managed by Azure)
* They are logically grouped into a **Resource Group**
* Resources group are logically grouped into Azure Substription
* A cost is related to a subscription 
![alt text](<img/Capture d’écran 2025-05-09 064211.jpg>)

* Microsofsst ENTRA ID:  handle trust relation between Tenant and Ressorces and Subscription , a subscription is related to only one Tenant ?

#### Azure Resource Manager (ARM) Templates
* it is a way to perform IaC 
* For every resource created in Azure, it based on a template ARM created automatically.
![alt text](<img/Capture d’écran 2025-05-09 072412.jpg>)

* ARM Tempalte is json file 

```JSON
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "languageVersion": "",
  "contentVersion": "",
  "apiProfile": "",
  "definitions": { },
  "parameters": { },
  "variables": { },
  "functions": [ ],
  "resources": [ ], /* or "resources": { } with languageVersion 2.0 */
  "outputs": { }
}
```