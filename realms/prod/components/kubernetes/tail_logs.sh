echo "Usage: ./tail_logs.sh <namespace> <selector> <#lines>"

kubectl --kubeconfig .local/kubeconfig logs -n=$1 -l $2 --tail=$3
