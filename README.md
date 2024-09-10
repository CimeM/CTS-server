# CTS-server

Connectivity Test Server (CTS) is used to perform a connectivity check for globally distributed backends.

Example use:
Front end applications perform the check on backends deployed in different regions and connect to the one that performs the best (fastest response time).

Features:
    - GitHub CI and CD pipelines
    - merging to main branch automatically deploys the server
    - Google Cloud as target platform for deployments
    - dockerized application

## Build the application

The application can be build using docker:

``` bash
cd cts_server
docker build -t ctsimage . 
```

## How to run the application

Run the application using docker

``` bash
cd cts_server
docker run -itd --rm -p 8000:80 --name ctscontainer ctsimage
```

## How to test the application

Test the application locally

``` bash
curl -s -o /dev/null -w "%{http_code}" localhost:8000/ping
```

Perform automated functionality test:

``` bash
cd cts_server
bash ./functional-test.sh
```

## How to deploy the application

You will need:
    - service account with permissions JSON file stored in auth/serviceaccount.json
    - installed gcloud CLI,
    - kubectl, helm, curl
    - google cloud project name (set it to variables)
    - contianer registry on google cloud

### 1. Deploy ingrastructure (kuberentes cluster)

``` bash
cd infrastructure
bash ./deploy-cluster.sh
```

### 2. Build and push contianer image

``` bash
cd cts_server
bash ./build-push.sh
```

### 3. Deploy with helm

``` bash
cd helmchart/CTS
helm upgrade --install \
    --force -n fun7 --create-namespace \
    --set image.name="gcr.io/$PROJECT_ID/cts_server:latest" \
    ctsserver \
    .
```

### 4. Perform the test on the cluster

The ingress usually takes a few minutes -> retriving the ingres' public IP takes some time

```bash
# get the INGRESS_IP
kubectl get ingress -n fun7  ctsserver -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# take care of domain resolution 
cat "INGRESS_IP fun7cts1.com" > /etc/hosts #requires sudo
# perform test
curl -s  fun7cts1.com/ping 
# Output: {"status":"OK"}
```

## Cleanup

Remove the cluster

```bash
cd infrastructure
bash ./cleanup.sh
```

## Suggestions for infrastructure setup to be resilient to failures of compute nodes and scale automatically in case of increased CPU

- enable autoscaling of cluster nodes (min, desired, max)
- HA clusters - deploy minimum 3 nodes per cluster
- nodes are distributed in multiple zones in the region
- introduce limits and requests for the pods
- monitoring and capacity planing (if possible)
- isolate problematic pods/deployments with taints and tolerations
- enable cached responses to api requests
- limit the rate of requests (ex: 50 every minute per user)
- enable failover responses to requests
- enable offload to different region (if possible)
- adopt faster technologies (like redis) that keep the data in RAM
- investigate why compute nodes fail (eliminate bugs)
- design the frontend to include delays in strategic places
- stress test the infrastructure and applications
