kubectl --kubeconfig .local/kubeconfig -n $1 get pods -l $2 -o json | jq -r '.items[0].metadata.name'
