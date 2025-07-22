#!/bin/bash

set -e

CLUSTER=$1
IMAGE_TAG=$2

DOCKER_USERNAME="${DOCKER_USERNAME:-yourdockerusername}"
IMAGE="$DOCKER_USERNAME/static-website:$IMAGE_TAG"

echo "Deploying to $CLUSTER with image tag: $IMAGE_TAG"

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

echo "Waiting for rollout to complete (timeout 120s)..."
if kubectl rollout status deployment/multi-cloud-app --namespace default --timeout=120s; then
  echo "✅ Deployment rolled out successfully."
else
  echo "❌ Rollout did not complete in time. Debugging..."
  echo "Describing deployment:"
  kubectl describe deployment multi-cloud-app --namespace default

  echo "Describing pods:"
  kubectl get pods --namespace default
  kubectl describe pods --namespace default

  echo "Fetching logs from pods:"
  for pod in $(kubectl get pods --namespace default -o jsonpath='{.items[*].metadata.name}'); do
    echo "Logs for pod $pod:"
    kubectl logs $pod --namespace default || true
  done

  exit 1
fi
