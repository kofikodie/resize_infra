.PHONY: argocd-password argocd-ui argocd-login argocd-create-app argocd-get-lb-url

# Get ArgoCD admin password
argocd-password:
	@echo "ArgoCD Admin Password:"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo

# Set LoadBalancer URL
argocd-set-lb-url:
	@echo "ArgoCD LoadBalancer URL:"
	@kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}'
	@echo

# Get LoadBalancer URL
argocd-get-lb-url:
	@echo "ArgoCD LoadBalancer URL:"
	@kubectl get svc argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
	@echo

# Login to ArgoCD CLI
argocd-login:
	$(eval ARGOCD_PASSWORD := $(shell kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d))
	$(eval ARGOCD_SERVER := $(shell kubectl get svc argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"))
	@echo "Logging into ArgoCD..."
	@argocd login $(ARGOCD_SERVER) --username admin --password $(ARGOCD_PASSWORD) --insecure

# Create a new ArgoCD application
argocd-create-app:
	@if [ -z "$(NAME)" ] || [ -z "$(REPO)" ] || [ -z "$(PATH)" ]; then \
		echo "Usage: make argocd-create-app NAME=<app-name> REPO=<git-repo-url> PATH=<path-to-manifests>"; \
		exit 1; \
	fi
	@kubectl config set-context --current --namespace=argocd
	@argocd app create $(NAME) \
		--repo $(REPO) \
		--path $(PATH) \
		--dest-server https://kubernetes.default.svc \
		--dest-namespace default \
		--sync-policy automated \
		--auto-prune \
		--self-heal

# Install ArgoCD
argocd-install:
	kubectl create namespace argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Waiting for ArgoCD server to be ready..."
	@kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# List all applications
argocd-list-apps:
	@argocd app list

# Sync an application
argocd-sync-app:
	@if [ -z "$(NAME)" ]; then \
		echo "Usage: make argocd-sync-app NAME=<app-name>"; \
		exit 1; \
	fi
	@argocd app sync $(NAME)

# Delete an application
argocd-delete-app:
	@if [ -z "$(NAME)" ]; then \
		echo "Usage: make argocd-delete-app NAME=<app-name>"; \
		exit 1; \
	fi
	@argocd app delete $(NAME) --yes

# Install metrics server
metric:
	kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml