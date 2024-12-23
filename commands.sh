# ----------------- Step 0 ----------------- 
# Set udacity as aws profile
export AWS_PROFILE=uda

# ----------------- Step 1 ----------------- 
# Create an EKS Cluster
eksctl create cluster --name my-cluster \
    --region us-east-1 \
    --nodegroup-name my-nodes \
    --node-type t3.small \
    --nodes 1 \
    --nodes-min 1 \
    --nodes-max 2

# Update the Kubeconfig
aws eks --region us-east-1 update-kubeconfig --name my-cluster

# Delete the EKS Cluster
eksctl delete cluster --name my-cluster --region us-east-1

# drain a nodegroup 
eksctl drain nodegroup --cluster=my-cluster --name=my-nodes

# Scaling Managed Nodegroups
eksctl scale nodegroup \
    --name=my-nodes \
    --cluster=my-cluster \
    --nodes=0 \
    --nodes-min=0 \
    --nodes-max=1

# ----------------- Step 2 ----------------- 
# Config DB
kubectl apply -f pvc.yaml
kubectl apply -f pv.yaml
kubectl apply -f postgresql-deployment.yaml

# Get pods
kubectl get pods
# Exec to a specific pod
kubectl exec -it postgresql-77d75d45d5-kn79t -- bash
# Inside the pod, connect to posgres
psql -U myuser -d mydatabase
# List databases
\l
# Create service
kubectl apply -f postgresql-service.yaml
# List the services
kubectl get svc
# Set up port-forwarding to `postgresql-service`
kubectl port-forward service/postgresql-service 5433:5432 &

# Test pods working
curl ae48e661f61d64a7e89bdcbbc6845ce0-1882157535.us-east-1.elb.amazonaws.com:5153/api/reports/daily_usage