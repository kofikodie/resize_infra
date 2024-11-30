argocd-install:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
argocd-ui-lb:	
	kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
argocd-get-password:
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
metric:
	kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml
plg-add:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm show values grafana/loki-stack > ./charts/plg/loki-stack-values.yml
plg-install:
	helm install loki grafana/loki-stack -n loki --create-namespace -f ./charts/plg/loki-stack-values.yml