#!/bin/bash

CLUSTER_TYPE=$1  # eks or aks

if [ -z "$CLUSTER_TYPE" ]; then
  echo "Usage: ./deploy.sh <eks|aks>"
  exit 1
fi

# Compose the Docker image name automatically from env/Secrets
DOCKER_IMAGE_TAG="${DOCKER_USERNAME}/static-website:latest"

echo "Cluster Type: $CLUSTER_TYPE"
echo "Using Docker Image: $DOCKER_IMAGE_TAG"

# Configure kubectl based on cluster type
if [ "$CLUSTER_TYPE" == "eks" ]; then
    echo "Configuring kubectl for AWS EKS cluster: $EKS_CLUSTER_NAME"
    aws eks update-kubeconfig --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION"

elif [ "$CLUSTER_TYPE" == "aks" ]; then
    echo "Configuring kubectl for Azure AKS cluster: $AKS_CLUSTER_NAME"
    az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID"
    az aks get-credentials --resource-group "$AZURE_RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME"

else
    echo "❌ Unsupported cluster type. Use eks or aks."
    exit 1
fi

echo "Preparing manifests with Docker image: $DOCKER_IMAGE_TAG"

TEMP_MANIFEST_DIR=$(mktemp -d)
cp src/* "$TEMP_MANIFEST_DIR"/

# Replace the image placeholder
sed -i "s|__DOCKER_IMAGE_PLACEHOLDER__|$DOCKER_IMAGE_TAG|g" "$TEMP_MANIFEST_DIR"/deployment.yaml

kubectl apply -f "$TEMP_MANIFEST_DIR"/deployment.yaml
kubectl apply -f "$TEMP_MANIFEST_DIR"/service.yaml

rm -rf "$TEMP_MANIFEST_DIR"

echo "✅ Deployment to $CLUSTER_TYPE completed with image: $DOCKER_IMAGE_TAG"
