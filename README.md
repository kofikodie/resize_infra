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
