#!/usr/bin/env bash

# azure login
az login --service-principal -u ${ARM_CLIENT_ID}  -p ${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID}

# set subscription
az account set --subscription ${ARM_SUBSCRIPTION_ID}

# get aks credentials and save them to kubeconfig file in the current directory
az aks get-credentials --public-fqdn --name myaks --resource-group MyResourceGroup -a -f

# set context
export KUBECONFIG=kubeconfig
kubectl config set-context myaks --namespace default
kubectl config use-context myaks

exit 0
