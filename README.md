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

## ArgoCD Setup and Usage

## Prerequisites
- Kubernetes cluster with EKS
- kubectl configured to access your cluster
- Helm v3+
- Make utility installed

## Installation and Setup

1. **Install ArgoCD**
```bash
make argocd-install
```

2. **Configure LoadBalancer and Get URL**
```bash
make argocd-get-lb-url
```

3. **Get Admin Password**
```bash
make argocd-password
```

4. **Access ArgoCD UI**
Visit the LoadBalancer URL in your browser (using HTTPS)
```bash
https://<LOADBALANCER_URL>
```

5. **Login to ArgoCD CLI**
```bash
make argocd-login
```

## Managing Applications

### Create a New Application
```bash
make argocd-create-app NAME=myapp REPO=https://github.com/org/repo PATH=k8s/
```

### List All Applications
```bash
make argocd-list-apps
```

### Sync an Application
```bash
make argocd-sync-app NAME=myapp
```

### Delete an Application
```bash
make argocd-delete-app NAME=myapp
```

## Application Configuration

Applications can be defined in Git using the following format:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/your-repo.git
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Best Practices

1. **GitOps Workflow**
   - Keep all Kubernetes manifests in Git
   - Use branches for environments
   - Implement pull request reviews

2. **Application Structure**
   - Use Helm charts for complex applications
   - Organize manifests by environment
   - Use ApplicationSets for similar applications

3. **Security**
   - Enable SSO integration
   - Use RBAC for team access
   - Regularly rotate credentials

4. **Monitoring**
   - Enable metrics collection
   - Set up alerts for sync failures
   - Monitor resource usage

## Troubleshooting

1. **UI Not Accessible**
   ```bash
   # Check ArgoCD pods
   kubectl get pods -n argocd
   
   # Check ArgoCD services
   kubectl get svc -n argocd
   ```

2. **Application Not Syncing**
   ```bash
   # Check application status
   argocd app get myapp
   
   # Check application logs
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
   ```

3. **Authentication Issues**
   ```bash
   # Reset admin password
   kubectl -n argocd patch secret argocd-initial-admin-secret \
     -p '{"data": {"password": null}}'
   ```

## Available Make Commands
| Command | Description |
|---------|-------------|
| `make argocd-install` | Install ArgoCD |
| `make argocd-get-lb-url` | Get LoadBalancer URL |
| `make argocd-password` | Get admin password |
| `make argocd-login` | Login to ArgoCD CLI |
| `make argocd-create-app` | Create new application |
| `make argocd-list-apps` | List all applications |
| `make argocd-sync-app` | Sync an application |
| `make argocd-delete-app` | Delete an application |
