# infra-repo
The project follows a strict branching and GitOps deployment strategy to ensure code quality and stability:

1. **Development (`dev` branch):** 
   - Developers push their backend and frontend code updates to the `dev` branch.
2. **Code Review (Pull Request):** 
   - Once features are ready, a **Pull Request (PR)** is opened from `dev` to `main`.
   - The Team Lead reviews the code, and automated CI checks run.
3. **Production Merge (`main` branch):** 
   - After approval, the PR is merged into the `main` branch (Production).
4. **Automated Delivery (ArgoCD):** 
   - Merging into `main` triggers the CI pipeline (GitHub Actions) to build new images and update manifests.
   - **ArgoCD** detects the changes in the `main` branch (or infrastructure repo) and automatically synchronizes the Kubernetes cluster with the new application versions.



       +------------------+
       |   Developer      |
       +--------+---------+
                | git push (to dev -> PR -> main)
                v
       +------------------+      1. Build & Push Image
       |  GitHub Actions  | ------------------------+
       |  (CI Pipeline)   |                         |
       +------------------+                         v
                |                          +--------------------+
                | 2. Update Image Tag      |  Container Registry|
                |                          |    Docker Hub      |
                v                          +--------------------+
       +------------------+                         |
       |  Infrastructure  | <-----------------------+
       |   Git Repo       |
       +--------+---------+
                |
                | 3. GitOps Sync (Pull)
                v
       +-------------------------------------------------------+
       |                        ArgoCD                         |
       |  +-------------------------------------------------+  |
       |  |                  Root App                       |  |
       |  |         ("App of Apps" orchestrator)            |  |
       |  +---------+-----------------------------+---------+  |
       |            |                             |            |
       |            v (Manages)                   v (Manages)  |
       |  +------------------+          +-------------------+  |
       |  |  Frontend App    |          |   Backend App     |  |
       |  +------------------+          +-------------------+  |
       +-------------------------------------------------------+
                                |
                                | 4. Reconcile / Deploy
                                v
       +-------------------------------------------------------+
       |                  Kubernetes Cluster                   |
       |   +------------------+      +----------------------+  |
       |   | Backend Pod (Go) | ---> | MongoDB (Database)   |  |
       |   +--------+---------+      +----------------------+  |
       |            |                           ^              |
       |            v                           |              |
       |   [ Frontend Pod ]         +-----------+-----------+  |
       |                            | mongo-express Pod     |  |
       |                            | (Admin UI via LB)     |  |
       |                            +-----------------------+  |
       +-------------------------------------------------------+


## 🐙 ArgoCD GitOps & "App of Apps" Pattern

To adhere to enterprise-grade Kubernetes best practices, the project implements the **ArgoCD "App of Apps"** architectural pattern:
- **Root Application:** A single top-level ArgoCD application (`root-app`) monitors the infrastructure repository. 
- **Managed Children:** It automatically provisions, monitors, and synchronizes both the **Frontend** and **Backend** child applications. 
- **Self-Healing & Health Check:** The root application continuously reconciles the cluster state, ensuring that if any component (frontend or backend) drifts or fails, ArgoCD automatically brings it back to the desired healthy state defined in Git.


- **Note:**


    ******If you use MacOS just run:******
        sudo chmod +x deploy_all.sh && ./deploy_all.sh
    And All project will start automatically on your local machine.
    You will ask for enter admin password and the script will open 3 terminal windows for port forwarding and creating access for all WEB UIs.

    ******If you use Linux machine:******
# First run: 
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

# 5. After all ports and services will up:
 Open 3 terminal windows and run these commands (separately in each terminal):
        1. $>:kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
            $>:kubectl port-forward svc/argocd-server -n argocd 8080:443
        2. $>:kubectl port-forward svc/mongo-express-service -n dev-project 8081:8081
        3. $>:sudo kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 80:80 443:443

******Congratulations!!!******

Now you may open web browser and enter to:
Argocd: https://localhost:8080/
Mongo Express: http://localhost:8081/
Frontend App : http://app.test/



######### For local using on your host machine ##############

Step 1:
(Deploying MongoDB and Mongo-Express on Kubernetes using Minikube, 
including secret, configmap, volumes):

!!!!First, check you are in minikube cluster!!!
---------------------------------------------------
#Check which contexts is availavle: -->

    @:kubectl config get-contexts

#Switch to minikube context: -->

    @:kubectl config use-context minikube
---------------------------------------------------
Copy and paste to your terminal this command (be shure you are into 
.../infra-repo/kubernetes/ in your terminal) -->

    @:kubectl apply \
        -f secrets/mongoDB-secret.yaml \
        -f configMap/mongo-configmap.yaml \
        -f volumes/mongo-persistent-volume-claim.yaml \
        -f deployments/mongo-deploy.yaml \
        -f services/mongo-service.yaml \
        -f deployments/mongo-express-deploy.yaml \
        -f services/mongo-express-service.yaml
---------------------------------------------------
Note: The 'dev-project' namespace will be created automatically.

After all services, pods, and volumes are launched.
Establish a connection for the backend application (open in new terminal). -->

    @:kubectl port-forward pod/<podname> 27017:27017 -n dev-project

---------------------------------------------------

Make tunnel for minikube (open in new terminal): -->

    @:minikube tunnel

Note: You will be asked for sudo user password.
Ensert it for making the tunnel.

---------------------------------------------------

Step 2:
(Starting backend application):

Open terminal from /backend-repo/src/ and run next commands:

    @:go mod init backend
    @:go mod tidy
    @:go get github.com/gin-gonic/gin
    @:go get go.mongodb.org/mongo-driver/mongo
    @:go run main.go

---------------------------------------------------

Server will be started on port :8085

Note: If you want to check endpoints from Postman
    http://localhost:8085/

### API Endpoints
    GET:"/api/hotels"
    POST:"/api/reservations"
    GET:"/api/reservations/lookup"
    DELETE:"/api/reservations/:id"

For more information see README in backend-repo

---------------------------------------------------

Step 3:
(Starting frontend application):

Open terminal from /frontend-repo/src/ and run next command:

    @:python3 -m http.server 3000

---------------------------------------------------

Server will be started on port :3000

Open browser http://localhost:3000

!!!!!Congratulations!!!!!

---------------------------------------------------


Note: (Mongo Express) You may open browser http://localhost:8081 and see
    that Mongo Express application is running.
    Insert username and password from infra-repo/kubernetes/secrets 
    and check that devops_booking DB is exists.


######### For using into Minikube k8s cluster ##############

Step 1:
    (Verifying all components):

!!!!First, check you are in minikube cluster!!!
---------------------------------------------------
#Check which contexts is availavle: -->

    @:kubectl config get-contexts

#Switch to minikube context: -->

    @:kubectl config use-context minikube

#Check if Ingress controller is enabled:

    @:minikube addons list

#For enabling Ingress addon use:

    @:minikube addons enable ingress

---------------------------------------------------
Copy and paste to your terminal this command (be shure you are into 
.../infra-repo/kubernetes/ in your terminal) -->

    @:kubectl apply \
        -f secrets/ \
        -f configMap/ \
        -f volumes/ \
        -f deployments/ \
        -f services/ \
        -f ingress/


Step 1: Connect with zero credentials to MongoDB
Run this command to drop straight into the database without passing any username or password:

Bash
kubectl exec -it mongo-stateful-set-0 -n dev-project -- mongosh --host 127.0.0.1

(You should see a successful connection prompt, ignoring authentication!)

Step 2: Initialize the Replica Set
While inside that shell, copy-paste and execute your initialization block:

JavaScript

cfg = rs.conf();
cfg.members[0].host = "mongo-stateful-set-0.mongodb-headless.dev-project.svc.cluster.local:27017";
cfg.members[1].host = "mongo-stateful-set-1.mongodb-headless.dev-project.svc.cluster.local:27017";
cfg.members[2].host = "mongo-stateful-set-2.mongodb-headless.dev-project.svc.cluster.local:27017";
rs.reconfig(cfg, { force: true });

Press enter. Wait about 10–15 seconds for the prompt to change from STARTUP2 to PRIMARY.

Step 3: Explicitly Create the Root User
Because your MONGO_INITDB_ROOT_USERNAME might have been skipped due to the strict early --auth flag, let's manually register your root user right now on the primary node. Run this code inside the same window:

JavaScript
use admin
db.createUser({
  user: "username",
  pwd: "password",
  roles: [ { role: "root", db: "admin" } ]
})
(You should see Ok: 1 or a confirmation message).

Type exit to leave the shell.


mongodb://admin:passw@mongo-stateful-set-0.mongo-service.dev-project.svc.cluster.local:27017/admin?replicaSet=rs0&authSource=admin

