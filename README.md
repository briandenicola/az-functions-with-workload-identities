# Overview

A demo repository of using Azure Functions in a Docker container using AKS Workload Identities for binding authentications. There is one outstanding issue - [9266](https://github.com/Azure/azure-functions-host/issues/9266) before Workload Identities is fully supported with Azure Functions and that is with the Function Host.  Please track [9266](https://github.com/Azure/azure-functions-host/issues/9266) for additional information.

This repository will write data to an Azure Event Hub and use Azure Functions to send that data into Azure SQL.

This repository uses [Task](https://taskfile.dev/installation/) to help with the automation.  Use `task --list` to see the complete list of options

## Technical Details and Configurations
Azure Functions has had the ability to run inside a Docker container for several years. Historically,  Functions has used connection strings to authenticate to its dependency resources (Azure Storage) or its bindings (like Azure SQL or Azure Event Hubs).  In 2022,  Azure Functions running in Azure brought Managed Identity support for Triggers and Bindings then eventually to the Functions Host. This repository brings those concepts to Kubernetes 

Azure Functions will leverage  [Azure Workload Identities](https://github.com/Azure/azure-workload-identity) for password-less authentication. Workload Identities federates a Azure Managed Identity with a Kubernetes  Service Account under which context a pod runs inside AKS.  This Federation allows the projection of a Service Account Token from AKS to services in Azure without requiring a password.

### Azure Function Host 
One or more Azure Functions runs on top of an Azure Function Host. The Function Host provides the foundational elements that a function needs to run.  It uses Azure Storage (Blobs and Queues) to persistent configuration values.  The Azure Blob setting is defined with the `AzureWebJobsStorage` Environmental variable.  The `__` nomenclature groups Environmental Variables as a collection and is used throughout [Azure Functions Identity based configuration](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference?tabs=blob#configure-an-identity-based-connection)

The Azure Managed Identity must be granted the following RBAC roles on the Azure Storage:
* "Storage Account Contributor"
* "Storage Blob Data Contributor"
* "Storage Queue Data Contributor"



Example Configuration:
```
  AzureWebJobsStorage__credential: workloadidentity
  AzureWebJobsStorage__clientId: fc813289-26f6-465d-a288-3ef982e39157  #This is the Client ID of the Azure Managed Identity. Client IDs are not secret values
  AzureWebJobsStorage__queueServiceUri: "https://azurefunctionsdemo.queue.core.windows.net" 
  AzureWebJobsStorage__tableServiceUri: "https://azurefunctionsdemo.table.core.windows.net"
  AzureWebJobsStorage__blobServiceUri: https://azurefunctionsdemo.blob.core.windows.net"

  AZURE_TENANT_ID: fc813289-26f6-465d-a288-3ef982e39157
  AZURE_CLIENT_ID: 75f25ae8-e026-4939-94e7-1714dbbc0c16
  AZURE_FEDERATED_TOKEN_FILE: /var/run/secrets/azure/tokens/azure-identity-token
```

> **_NOTE:_**: In this repositor, the proper Roles are assigned using Terraform and these configs are defined in the Helm `chart/values.yaml` file that will be populated with values from the Terraform state file.

### Azure Triggers and Bindings
Each service that Azure Functions interacts with either by a Trigger or Input/Output requires additional authentication. Each service has their own role definitions and connection string format. They do all follow the `__` nomenclature to group a collection of common Environmental Variables.

Example SQL Server Connection:
```
  SQL_CONNECTION__credential: managedidentity
  SQL_CONNECTION__clientId: fc813289-26f6-465d-a288-3ef982e39157 
  SQL_CONNECTION: Server=sampleazure-sql.database.windows.net;Database=results;Encrypt=true;Authentication=Active Directory Managed Identity
  
```

Example Event Hub Connection:
```
  EVENTHUB_CONNECTION__credential: managedidentity
  EVENTHUB_CONNECTION__clientId: fc813289-26f6-465d-a288-3ef982e39157 
  EVENTHUB_CONNECTION__fullyQualifiedNamespace: sampleazure-hub.servicebus.windows.net
```

> **_NOTE:_**: In this repositor, these configs are defined in the Helm `chart/values.yaml` file that will be populated with values from the Terraform state file.

# Infrastructure
## Resources Created
| |  |
--------------- | --------------- 
| Log Analytics Workspace | Azure Container Registry (Private Endpoint) |
| Azure Event Hub (Private endpoint) | Azure SQL (Private Endpoint) |
| Azure Kubernetes Service | Azure Storage (Private Endpoint) |
| Managed User identities | AKS Cluster Identity | 
| | AKS Kubelet Identity | 
| | App Identity |

## Infrastructure Stand-up 
1. Run the following: `az login; task up`
> **_NOTE:_**: Task up will create the environment, build/push the Azure Function code, and deploy via Helm to the AKS cluster

### Sample run:
```bash
$ az login 
$ task up
task: [up] terraform -chdir=./infrastructure init
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
task: [apply] terraform -chdir=./infrastructure apply -auto-approve
Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

ACR_NAME = "goldfish3410acr"
AKS_CLUSTER_NAME = "goldfish-3410-aks"
AKS_RESOURCE_GROUP = "goldfish-3410_rg"
APP_IDENTITY_NAME = "goldfish-3410-aks-functions-demo-identity"
APP_NAME = "goldfish-3410"
NAMESPACE = "functions-demo"
ARM_TENANT_ID = "16b3c013-d300-468d-ac64-7eda0820b6d3"
ARM_WORKLOAD_APP_ID = "15e1d216-73dd-499f-b54e-ad3cbf8ca4d4"
EVENTHUB_NAMESPACE_NAME = "goldfish-3410-eventhub"
SQL_CONNECTION = "Server=goldfish-3410-sql.database.windows.net;Database=results;Encrypt=true;Authentication=Active Directory Managed Identity"
WEBJOB_STORAGE_ACCOUNT_NAME = "goldfish3410sa"
task: [creds] az aks get-credentials -g goldfish-3410_rg -n goldfish-3410-aks --overwrite-existing
The behavior of this command has been altered by the following extension: aks-preview
Merged "goldfish-3410-aks" as current context in /home/admin/.kube/config
task: [creds] sed -i s/devicecode/azurecli/g ~/.kube/config
task: [build] az acr login --name goldfish3410acr
task: [build] az acr build --image goldfish3410acr.azurecr.io/functions-demo:62ec958f --registry goldfish3410acr --file Dockerfile .
....
Run ID: cd9 was successful after 1m25s
task: [deploy] helm upgrade -i function-demo --set ACR_NAME="goldfish3410acr" --set COMMIT_VERSION=62ec958f --set APP_IDENTITY_NAME=goldfish-3410-aks-functions-demo-identity --set ARM_WORKLOAD_APP_ID=15e1d216-73dd-499f-b54e-ad3cbf8ca4d4 --set ARM_TENANT_ID=16b3c013-d300-468d-ac64-7eda0820b6d3 --set EVENTHUB_NAMESPACE_NAME="goldfish-3410-eventhub" --set WEBJOB_STORAGE_ACCOUNT_NAME="goldfish3410sa" --set SQL_CONNECTION="Server=goldfish-3410-sql.database.windows.net;Database=results;Encrypt=true;Authentication=Active Directory Managed Identity" ./chart
Release "function-demo" has been upgraded. Happy Helming!
NAME: function-demo
LAST DEPLOYED: Mon Aug 14 12:52:34 2023
NAMESPACE: default
STATUS: deployed
REVISION: 9
TEST SUITE: None
task: [deploy] kubectl --namespace functions-demo get pods
NAME                              READY   STATUS    RESTARTS   AGE
eventprocessor-5465799c7b-rq2ph   1/1     Running   0          23m
```

## Manual Post-Configuration
1.  Assign ${MSI_IDENTITY_NAME} to the VM Scale Set of the AKS nodepool where the Azure Functions runs
> **_NOTE:_**: This should be a temporary step while the above issue is being fully addressed

## SQL Seup
## Steps
1. Log into the Azure SQL Database using SQL Management Studio 
1. Run the following after replacing ${MSI_IDENTITY_NAME} with proper identity name
```bash
CREATE USER [${MSI_IDENTITY_NAME}] FROM EXTERNAL PROVIDER
ALTER ROLE db_datareader ADD MEMBER [${MSI_IDENTITY_NAME}]
ALTER ROLE db_datawriter ADD MEMBER [${MSI_IDENTITY_NAME}]
CREATE TABLE dbo.requests ( [Id] UNIQUEIDENTIFIER DEFAULT NEWID()  PRIMARY KEY, [Message] VARCHAR(250) NOT NULL);
```

## Notes
* The cluster name and managed identity name will be known after terraform creates the resources in Azure.
* The managed identity name should be in the form of __${aks_name}-${var.namespace}-identity__
    * For example: goldfish-2295-aks-functions-demo-identity

# Validate 
1. Run the following: `task run`

### Sample run:
```bash
$ task run
task: [run] dotnet run -n goldfish-3410-eventhub
A batch of 5 events has been published.
```

### Validate
1. Check that the 5 entries were added to the requests table 
```
SELECT * FROM dbo.requests 
```

# Destroy
1. Run the following: `task down`

### Sample run:
```bash
$ task down
task: [down] cd infrastructure ; rm -rf .terraform.lock.hcl .terraform terraform.tfstate terraform.tfstate.backup .terraform.tfstate.lock.info
task: [down] az group delete -n goldfish-3410_rg --yes || true
```