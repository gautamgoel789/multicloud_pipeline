#!/bin/bash

set -e

CLUSTER=$1
IMAGE_TAG=$2

DOCKER_USERNAME="${DOCKER_USERNAME:-yourdockerusername}"  # fallback if env not set
IMAGE="$DOCKER_USERNAME/static-website:$IMAGE_TAG"

echo "Deploying to $CLUSTER with image tag: $IMAGE_TAG"

# Set kubeconfig for the right cluster
if [ "$CLUSTER" == "eks" ]; then
  echo "Configuring kubeconfig for EKS..."
  aws eks update-kubeconfig --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION"
elif [ "$CLUSTER" == "aks" ]; then
  echo "Configuring kubeconfig for AKS..."
  az aks get-credentials --resource-group "$AZURE_RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME"
else
  echo "Unknown cluster type: $CLUSTER"
  exit 1
fi

echo "Updating Kubernetes deployment with image: $IMAGE"

kubectl set image deployment/multi-cloud-app web="$IMAGE" --namespace default

echo "Deployment updated successfully."
kubectl rollout status deployment/multi-cloud-app --namespace default
