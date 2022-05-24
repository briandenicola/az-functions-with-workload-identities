# Overview

A demo repository of using Azure Functions in a Docker container using AKS Workload Identities for binding authentications

# Infrastructure Setup
```bash
cd pod-identities/infrastructure
terraform init
terraform apply
./scripts/pod-identity.sh --cluster-name ${aks_cluster_name} -n default -i ${managed_identity_name}
```

# Deploy API
```bash
cd src
docker build -t ${existing_docker_repo}/keygenerator/eventprocessor:1.0 .
docker push ${existing_docker_repo}/keygenerator/eventprocessor:1.0
cd deploy
helm upgrade -i eventprocessor  \
 --set "ACR_NAME=${existing_docker_repo}" \ 
 --set "MSI_CLIENTID=${managed_identity_clientid}" \
 --set "MSI_SELECTOR=${managed_identity_name}" \
 --set "COMMIT_VERSION=1.0" \
 --set "EH_CONNECTION_STRING=${event_hub_namespace_name}.servicebus.windows.net" \
 --set "WEBJOB_STORAGE_ACCOUNT_NAME=${storage_account_name}" \
 .
```

# Test
```bash
az login 
dotnet run -n ${app-name}-eventhub