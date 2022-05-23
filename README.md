# Overview

A demo repository of using Azure Functions in a Docker container using AKS Workload Identities for binding authentications

# Infrastructure Setup
```bash
cd pod-identities/infrastructure
terraform init
terraform apply
./scripts/pod-identity.sh --cluster-name ${aks_cluster_name} -n default -i ${managed_identity_name}
```

## Deploy API
```bash
cd src
docker build -t ${existing_docker_repo}/keygenerator/eventprocessor:1.0 .
docker push ${existing_docker_repo}/keygenerator/eventprocessor:1.0
cd deploy
* Update values.yaml
helm upgrade -i eventprocessor .
```