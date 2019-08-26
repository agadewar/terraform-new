echo "Usage: ./open_shell.sh <namespace> <pod-name> <container-name>"

kubectl --kubeconfig .local/kubeconfig exec -n $1 $2 -c $3 -it /bin/bash
