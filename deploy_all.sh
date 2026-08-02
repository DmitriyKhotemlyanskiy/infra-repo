#!/bin/bash
echo "🚀 Start deploying the project..."

echo "Creating app.test in /etc/hosts"
sudo chmod +x addip.sh && sudo ./addip.sh

# 1. Create namespace
kubectl create namespace argocd
kubectl create namespace dev-project

# 2. Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Wait for ArgoCD server is up..."
kubectl wait --namespace argocd --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s

# 3. Connect to private repo
kubectl apply -f /argocd/argo-config/

# 4. Start the ArgoCD
kubectl apply -f /argocd/applications/
kubectl apply -f /argocd/root-app.yaml


echo "✅ The project is running by ArgoCD!"

ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo -e "For sign in ArgoCD \nusername: admin\npassword: ${ARGOCD_PASSWORD}\n"

echo "🚀 Opening port-forward terminals..."

# Use AppleScript for opening terminal windows macOS
osascript <<EOF
tell application "Terminal"
    -- 1. ArgoCD Port-Forward
    do script "echo '--- ArgoCD Port-Forward (8080) ---'; kubectl port-forward svc/argocd-server -n argocd 8080:443"
    
    -- 2. Mongo-Express Port-Forward
    do script "echo '--- Mongo-Express Port-Forward (8081) ---'; kubectl port-forward svc/mongo-express-clusterip -n dev-project 8081:8081"
    
    -- 3. Ingress Nginx Port-Forward
    do script "echo '--- Ingress Nginx Port-Forward (80/443) ---'; sudo kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 80:80 443:443"
end tell
EOF

echo "✨ All port-forwards have been launched in separate terminal windows!"