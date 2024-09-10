#!/bin/bash

source variables.sh

# authenticate
gcloud auth activate-service-account --key-file="$PATH_TO_YOUR_KEY_FILE"

#set project
gcloud config set project "$PROJECT_ID"

# create a GKE cluster
gcloud container clusters create-auto "$CLUSTER_NAME" \
     --location "$REGION" --verbosity=debug
# get authentication credentials for the cluster
gcloud container clusters get-credentials "$CLUSTER_NAME" \
    --location "$REGION"

helm upgrade --install \
    --force -n "$NAMESPACE" --create-namespace \
    --set image.name="gcr.io/$PROJECT_ID/cts_server:latest" \
    ctsserver ../helmchart/CTS/.