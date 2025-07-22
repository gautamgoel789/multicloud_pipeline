#!/bin/bash

echo "🔒 Running Kubernetes Security and Resource Checks..."

echo "🔍 Checking all running Pods across namespaces:"
kubectl get pods --all-namespaces -o wide

echo "🔍 Checking all Services across namespaces:"
kubectl get svc --all-namespaces

echo "🔍 Checking Roles and RoleBindings:"
kubectl get roles --all-namespaces
kubectl get rolebindings --all-namespaces

echo "🔍 Checking ClusterRoles and ClusterRoleBindings:"
kubectl get clusterroles
kubectl get clusterrolebindings

echo "🔍 Checking Network Policies:"
kubectl get networkpolicies --all-namespaces

echo "✅ Security checks completed."

