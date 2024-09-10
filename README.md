# CTS-server

Connectivity Test Server (CTS) is used to perform a connectivity check for globally distributed backends.

Example use:
Front end applications perform the check on backends deployed in different regions and connect to the one that performs hte best.

Features:
    - CI and CD pipelines
    - merging to main branch automatically deploys the server
    - Google Cloud as target platform for deployments.

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
docker run -itd --rm -p 8000:8000 --name ctscontainer ctsimage
```

## How to test the application

Test the application locally

``` bash
curl -s -o /dev/null -w "%{http_code}" localhost:8000/ping
```

Perform automated functionality test:

``` bash
cd cts_server
bash ./functiuonal-test.sh
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
