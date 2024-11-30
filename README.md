# AWS Load Balancer Controller Setup Guide

This guide provides step-by-step instructions to set up and verify the AWS Load Balancer Controller in your Amazon EKS cluster.

---

## Prerequisites

- Verify if the `AmazonEKSLoadBalancerControllerRole` exists in the IAM Console.  
  If it exists, skip to [Step 2](#step-2-install-aws-load-balancer-controller).

---

## Step 1: Create IAM Role Using `eksctl`

1. **Download the IAM Policy**  
    For AWS Commercial Regions:
    ```bash
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
    ```

2. **Create an IAM Policy**  
    ```bash
    aws iam create-policy \
       --policy-name AWSLoadBalancerControllerIAMPolicy \
       --policy-document file://iam_policy.json
    ```

3. **Create an IAM Role and Associate It with Your Cluster**
Replace my-cluster with your EKS cluster name and 111122223333 with your AWS account ID:
    ```bash
    eksctl create iamserviceaccount \
        --cluster=my-cluster \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
        --approve
    ```

## Step 2: Install AWS Load Balancer Controller

1. **Add the EKS Helm Chart Repository**
    ```bash
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update eks
    ```
2. **Install the AWS Load Balancer Controller**

    Replace *my-cluster* with your EKS cluster name:

    ```bash
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=my-cluster \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region=region-code \
    --set vpcId=vpc-xxxxxxxx
    ```
3. **View Available Versions**
    ```bash
    helm search repo eks/aws-load-balancer-controller --versions
    ```

## Step 3. Verify Installation
Verify the deployment:
    
```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```
Expected output:
```bash
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           84s
```

## ARGOCD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. It provides a declarative way to define application delivery: Continuous Deployment, Progressive Delivery, Blue Green Deployments, Automated Rollbacks, etc.

## ArgoCD Installation

### Prerequisites

Download the ArgoCD CLI from the [ArgoCD Releases](https://argo-cd.readthedocs.io/en/stable/cli_installation/) page.

### Install ArgoCD on Kubernetes

```bash
make argocd-install
```

### Access ArgoCD-UI

To access the ArgoCD-UI, you need to run the following command:


```bash
make argocd-ui-lb
```

Then run the manifests in the chart starting with the service

Now you can access the ArgoCD-UI on http://<load_balancer_dns_name>

## ArgoCD Login

To login to ArgoCD, you need to run the following command:

First you need to get the password for the admin user:

```bash
make argocd-get-password
```

Then you need to login to ArgoCD:

```bash
argocd login <load_balancer_dns_name> --username admin --password <password>
```

## ArgoCD Deployments

### Deploying the application from git repository

To deploy the application from git repository, you need to first:

set the current namespace to argocd running the following command: 
```bash
kubectl config set-context --current --namespace=argocd
```

Then you need to run the following command:

```bash
argocd app create <application_name> --repo <url_git_repo> --path <path> --dest-server https://kubernetes.default.svc --dest-namespace default --sync-policy automated
```
