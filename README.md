# infra-repo
Initialize

######### For using locally on your host machine ##############

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
