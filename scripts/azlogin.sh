#!/usr/bin/env bash

# azure login
az login --service-principal -u ${ARM_CLIENT_ID}  -p ${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID}

# set subscription
az account set --subscription ${ARM_SUBSCRIPTION_ID}