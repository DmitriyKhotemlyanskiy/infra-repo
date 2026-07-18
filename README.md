# infra-repo

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

