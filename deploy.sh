# Build Docker images for the client, server, and worker components of the application. 
# Each component is built with two tags: 'latest' and a specific SHA identifier.
# -t specifies the tag of the image.
# -f specifies the Dockerfile to use for the build.
# The last argument is the build context.
docker build -t adam97n/multi-client-k8s:latest -t adam97n/multi-client-k8s:$SHA -f ./client/Dockerfile ./client
docker build -t adam97n/multi-server-k8s:latest -t adam97n/multi-server-k8s:$SHA -f ./server/Dockerfile ./server
docker build -t adam97n/multi-worker-k8s:latest -t adam97n/multi-worker-k8s:$SHA -f ./worker/Dockerfile ./worker

# Push the 'latest' tags of the images to Docker Hub.
# This makes the images accessible for deployment.
docker push adam97n/multi-client-k8s:latest
docker push adam97n/multi-server-k8s:latest
docker push adam97n/multi-worker-k8s:latest

# Push the SHA-specific tags of the images to Docker Hub.
# This allows for version-specific deployments, aiding in rollback and tracking.
docker push adam97n/multi-client-k8s:$SHA
docker push adam97n/multi-server-k8s:$SHA
docker push adam97n/multi-worker-k8s:$SHA

# Apply Kubernetes configurations found in the 'k8s' directory.
kubectl apply -f k8s

# Update the deployed images in the Kubernetes cluster to the new SHA-specific versions.
# This ensures that the running applications are using the specified versions.
# `kubectl set image` updates the image used by the specified deployment/container.
kubectl set image deployments/server-deployment server=adam97n/multi-server-k8s:$SHA
kubectl set image deployments/client-deployment client=adam97n/multi-client-k8s:$SHA
kubectl set image deployments/worker-deployment worker=adam97n/multi-worker-k8s:$SHA