echo "Usage: ./open_shell.sh <pod-name> <container-name>"

kubectl --kubeconfig kubeconfig exec $1 -c $2 -it /bin/ash
