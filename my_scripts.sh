
aws eks update-kubeconfig --region us-east-1 --name eksCluster


#aws eks update-kubeconfig \
#    --region us-east-1 \
#    --name eksCluster \
#    --role-arn arn:aws:iam::632504983555:role/eksRole


aws eks create-cluster --region us-east-1 --name eksCluster --kubernetes-version 1.23 \
--role-arn arn:aws:iam::632504983555:role/eksRole \
--resources-vpc-config subnetIds=subnet-039b8cc010c44b50c,subnet-0e587094a4e842edf,securityGroupIds=sg-09d9732241e099e00

kubectl apply -f aws-secret.yaml
kubectl apply -f env-secret.yaml
kubectl apply -f env-configmap.yaml

kubectl apply -f backend-feed-deployment.yaml
kubectl apply -f backend-user-deployment.yaml
kubectl apply -f frontend.yaml
kubectl apply -f reverseproxy.yaml

kubectl expose deployment frontend --type=LoadBalancer --name=publicfrontend
kubectl expose deployment reverseproxy --type=LoadBalancer --name=publicreverseproxy

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl get deployment metrics-server -n kube-system
kubectl autoscale deployment backend-user --cpu-percent=70 --min=3 --max=5



kubectl exec --stdin --tty backend-feed-859575555d-9f4j6 -- /bin/sh

curl http://10.100.159.175:8080/api/v0/feed

# Run these commands from the /udagram-frontend directory
docker build . -t omotayoishola/udagram-frontend:v3
docker push omotayoishola/udagram-frontend:v3
