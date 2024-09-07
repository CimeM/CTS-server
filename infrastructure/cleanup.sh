#!/bin/bash

source variables.sh

# authenticate
gcloud auth activate-service-account --key-file="$PATH_TO_YOUR_KEY_FILE"

# cleanup 
gcloud container clusters delete "$CLUSTER_NAME" \
    --location "$REGION"


chelm upgrade --install ../helmcharts/CTS/. ctsserver