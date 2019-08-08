echo "Usage: ./open_shell.sh <pod-name> <container-name> <namespace>"

kubectl --kubeconfig kubeconfig exec $1 -c $2 -n $3 -it /bin/bash
