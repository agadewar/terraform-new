echo "Usage: ./tail_logs.sh <namespace> <selector> <#lines>"

kubectl --kubeconfig kubeconfig logs -n=$1 -l $2 --tail=$3
