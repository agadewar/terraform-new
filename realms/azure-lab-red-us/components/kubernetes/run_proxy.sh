echo
#echo "The Kubernetes Dashboard can be seen by visiting: http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=_all"
echo "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default"
echo

kubectl --kubeconfig=.local/kubeconfig proxy $@
#kubectl --kubeconfig=/root/.kube/config proxy $@
