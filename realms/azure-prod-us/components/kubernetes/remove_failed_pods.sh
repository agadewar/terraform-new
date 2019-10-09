kubectl --kubeconfig=kubeconfig get po --all-namespaces | awk '{if ($4 != "Running") system ("kubectl --kubeconfig=kubeconfig -n " $1 " delete pods " $2 " --grace-period=0 " " --force ")}'

