#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.
set -x  # Print commands and their arguments as they are executed.

source variables.sh

# authenticate
gcloud auth activate-service-account --key-file="$PATH_TO_YOUR_KEY_FILE"

#set project
gcloud config set project "$PROJECT_ID"

gcloud auth configure-docker

# build the container
docker build -t "gcr.io/$PROJECT_ID/$IMAGE_NAME:latest" . #--no-cache

docker push "gcr.io/$PROJECT_ID/$IMAGE_NAME:latest"