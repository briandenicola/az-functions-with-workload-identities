# Overview

A demo repository of using Azure Functions in a Docker container using AKS Workload Identities for binding authentications.

It will create write data from an Azure Event Hub into Azure SQL.

This repository uses [Task]() to help with the automation.  Use `task --list` to see the complete list of options

## Technical Details and Configurations
__TBD__


# Infrastructure Setup
## Resources Created
| |  |
--------------- | --------------- 
| Log Analytics Workspace | Azure Container Registry (Private Endpoint) |
| Azure Event Hub (Private endpoint) | Azure SQL (Private Endpoint) |
| Azure Kubernetes Service | Azure Storage (Private Endpoint) |
| Managed User identities | AKS Cluster Identity | 
| | AKS Kubelet Identity | 
| | App Identity |

## Steps
```bash
az login 
task up
```
> **_NOTE:_**: Task up will create the environment, build/push the Azure Function code, and deploy via Helm to the AKS cluster

# SQL Seup
## Steps
1. Log into the Azure SQL Database using SQL Management Studio 
1. Run the following after replacing ${MSI_IDENTITY_NAME} with proper identity name
```bash
CREATE USER [${MSI_IDENTITY_NAME}] FROM EXTERNAL PROVIDER
ALTER ROLE db_datareader ADD MEMBER [${MSI_IDENTITY_NAME}]
ALTER ROLE db_datawriter ADD MEMBER [${MSI_IDENTITY_NAME}]
CREATE TABLE dbo.requests ( [Id] UNIQUEIDENTIFIER PRIMARY KEY, [Message] VARCHAR(250) NOT NULL);
```

## Notes
* The cluster name and managed identity name will be known after terraform creates the resources in Azure.
* The managed identity name should be in the form of __${aks_name}-${var.namespace}-identity__
    * For example: jackal-59934-aks-default-identity


# Validate 
1. Run the following
```bash
task run
```
1. Check that the 5 entries were added to the requests table 
```
SELECT * FROM dbo.requests 
```

# Destory
```bash
task down
```