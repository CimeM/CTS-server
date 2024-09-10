#!/bin/bash

source variables.sh

# authenticate
gcloud auth activate-service-account --key-file="$PATH_TO_YOUR_KEY_FILE"

# destroy the cluster
gcloud container clusters delete "$CLUSTER_NAME" \
    --location "$REGION"