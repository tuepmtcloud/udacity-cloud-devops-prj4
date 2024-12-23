# Coworking Space Service Extension
The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

For this project, you are a DevOps engineer who will be collaborating with a team that is building an API for business analysts. The API provides business analysts basic analytics data on user activity in the service. The application they provide you functions as expected locally and you are expected to help build a pipeline to deploy it in Kubernetes.

## Getting Started

### Dependencies
#### Local Environment
1. Python Environment - run Python 3.6+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster
4. `helm` - apply Helm Charts to a Kubernetes cluster
5. `eksctl` - create an EKS cluster

#### Remote Resources
1. AWS CodeBuild - build Docker images remotely
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS - run applications in k8s
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code


### Deploying an analytics as a Microservice to Kubernetes using AWS:
#### 1. Create a repository using AWS Elastic Container Registry (ERC)
#### 2. Create build project using AWS CodeBuild
* Attach the Elastic Container Registry role permisstions to CodeBuildBasePolicy: [BatchCheckLayerAvailability, BatchGetImage, GetAuthorizationToken, GetDownloadUrlForLayer, CompleteLayerUpload, InitiateLayerUpload, PutImage, UploadLayerPart]
* Add Environment variables: [AWS_ACCOUNT_ID, AWS_DEFAULT_REGION, IMAGE_REPO_NAME, IMAGE_TAG]
* Set GitHub repository have file buildspec.yml and Dockerfile

#### 3. Create an EKS Cluster using eksctl CLI tool
* Using eksctl to create an EKS Cluster
bash
eksctl create cluster --name my-cluster \
    --region us-east-1 \
    --nodegroup-name my-nodes \
    --node-type t3.small \
    --nodes 1 \
    --nodes-min 1 \
    --nodes-max 2


* Update the Kubeconfig
bash
aws eks --region us-east-1 update-kubeconfig --name my-cluster


* Attach the CloudWatchAgentServerPolicy IAM policy to your worker nodes
bash
aws iam attach-role-policy \
--role-name eksctl-my-cluster-nodegroup-my-nod-NodeInstanceRole-givSkkoZTWAD \
--policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  


* Use AWS CLI to install the Amazon CloudWatch Observability EKS add-on
bash
aws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name my-cluster


#### 4. Configure a Database
Set up a Postgres database using a Helm Chart.

1. Set up Bitnami Repo
bash
helm repo add udacity-bitnami https://charts.bitnami.com/bitnami
helm repo update


2. Install PostgreSQL Helm Chart

helm install my-postgresql udacity-bitnami/postgresql --set primary.persistence.enabled=false


This should set up a Postgre deployment at `my-postgresql.default.svc.cluster.local` in your Kubernetes cluster. You can verify it by running `kubectl svc`

* By default, it will create a username `postgres`. The password can be retrieved with the following command:
bash
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default my-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

echo $POSTGRES_PASSWORD


* Connecting Via Port Forwarding
bash
kubectl port-forward service/postgresql-service 5433:5432 &

3. Run Seed Files
We will need to run the seed files in `db/` in order to create the tables and populate them with data.

4. Export password of database in base64 and replace value of DB_PASSWORD in configmap.yaml 

#### 5. Deploy configmap.yaml and coworking.yaml
bash
cd .\deployment\
kubectl apply -f configmap.yaml
kubectl apply -f .\coworking.yaml 
 

For troubleshooting, logs from the container or application running as a Kubernetes pod are sent to a log group that can be accessed through AWS CloudWatch under Log Groups.