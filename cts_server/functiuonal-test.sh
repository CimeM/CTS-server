#!bin/sh
set -uex;

source variables.sh

# build the container
docker build -t "$IMAGE_NAME" . --no-cache
echo "starting the server"

cleanup() {
  echo "Cleaning up..."
  docker stop $CONTAINER_NAME
}
# execute this no matter the outcome
trap cleanup EXIT

# run the server
docker run -itd --rm -p 8000:80 --name $CONTAINER_NAME $IMAGE_NAME

# waiting for the continer to be ready
sleep 2

# retrive RESPONSE and HTML_CODE
RESPONSE=$(curl -s "$TEST_URL")
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$TEST_URL")

# evaluate the result
if [ "$HTTP_CODE" -eq 200 ] && echo "$RESPONSE" | grep -q "OK"; then
    echo "Test passed: Status code is 200 and response body is correct"
else
    echo "Test failed"
    echo "Status code: $HTTP_CODE"
    echo "Response body: $RESPONSE"
fi

