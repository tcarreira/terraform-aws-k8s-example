# Terraform AWS Kubernetes Example

**Do NOT use this in a production environment.**

This is a "simple" project that gives a sample on how to achieve a running public service from scratch, using terraform.

This will provision everything, from aws networking (vpc, security groups, etc...) to public load balancers with HTTPS and monitoring
(you only need to provide as AWS account with enough permissions)

There is also a Development Mode that skips all AWS provisioning and uses minikube instead.


# How to Run

## Cloud (production kind of)

```bash
cd infrastructure
# <configure aws login (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) >
vi terraform.tfvars # check what variables in 0.variables.tf (POSTGRES_PASSWORD has no default)
terraform init
terraform apply # will take a while (~15-20min)

# run this in order to use kubectl with this EKS cluster
aws eks update-kubeconfig --name terraform-eks

``` 

## Test/Development/Local (minikube)

```bash
cd infrastructure/dev-minikube

minikube start --driver docker # choose whatever driver suits you
minikube addons enable dashboard 
minikube addons enable ingress-dns
minikube addons enable ingress
minikube tunnel

# add/replace commentapi.dev to /etc/hosts
grep -E "^[^#].*commentapi.dev" /etc/hosts &>/dev/null && sudo sed -i "s@^[^#].*commentapi\.dev.*@$(minikube ip) commentapi.dev@g" /etc/hosts || echo -e "\n$(minikube ip) commentapi.dev" | sudo tee -a /etc/hosts &>/dev/null

terraform init
terraform apply --auto-approve # may take a while (~10min)

kubectl port-forward -n monitoring service/grafana 8080:80 # Grafana is not publicly exposed. With this command, access http://localhost:8080
``` 

If you need to start all over again:

```bash
minikube delete
rm terraform.tfstate*
``` 


# Architecture (what this code does)

- Everything managed with Terraform
  - Backend using S3 (allowing to manage the cluster within a team)
  - Separate terraform project to provision the S3 bucket 
- Kubernetes Cluster using AWS EKS
  - Networking
    - VPC
    - Subnets
    - Internet Gateways
    - Routing tables
  - Kubernetes Cluster
    - EKS Cluster
    - Worker Nodes
    - IAM roles + policies
    - Security groups (+ allow control cluster form my IP)
- Application deployed at kubernetes cluster
  - Database
    - RDS Postgres database
    - Could be tested easily with a Postgres deployed on k8s cluster (but it is not suitable for production (without extra stuff))
  - Application
    - Kubernetes application namespace
    - Deployment using Docker image (sensitive data via k8s secrets)
      - A simple CRUD REST API was used (for no special reason): [tcarreira/commentapi](https://hub.docker.com/repository/docker/tcarreira/commentapi) (from https://github.com/tcarreira/commentapi)
    - Exposed with AWS Load Balancer (from k8s LoadBalancer service)
    - HTTPS with SSL certificate from AWS ACM
- Monitoring using Prometheus + Grafana
  - Kubernetes monitoring namespace
  - Using k8s serviceaccount and cluster role
  - Deployment using prometheus and Grafana official Docker images
  - Grafana provisioning using Prometheus data source
  - Read applicational metrics from application (/metrics with promhttp)
- CI / CD 
  - Using Github Actions (on the application repo)
    - Build
    - Tests (unit + integration using a provisioned test database)
    - Publish master to Docker Hub repository (tagged with git ref)


# Some food for thought

## Major concerns

- Everything as code, as much as feasible
- High Availability
- CI/CD
- End-to-end provisioning: cloud (aws), kubernetes cluster (EKS), application with High Availability (pull image from Docker Hub), monitoring (Prometheus+Grafana) 

## Future improvements

- [ ] Better code + more features
- [ ] CI/CD
  - [ ] Environments (Development, Pre-production, Production)
  - [ ] auto deploy (upgrade @ k8s deployment)
    - [ ] define strategies
- [ ] Kubernetes
  - [ ] Fully managed cluster (no EKS)
  - [ ] Use ingress for more custom routing
- [ ] Observability
  - [ ] Create (and self provision) custom Grafana dashboards
  - [ ] Logs (EFK cluster)
  - [ ] Alarms (alarm manager)

## Other

This project was developed in 1 week, without previous technical knowledge on EKS, Terraform and Kubernetes.  
40h of work is not enough to learn all of this properly. 

Suggestions and contributions are welcomed (kubernetes only, as I'm not going to spend extra credits with AWS :D). 
PR if you have some interesting idea.

