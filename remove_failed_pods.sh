kubectl --kubeconfig=lab/kubernetes/kubeconfig get po --all-namespaces | awk '{if ($4 != "Running") system ("kubectl --kubeconfig=lab/kubernetes/kubeconfig -n " $1 " delete pods " $2 " --grace-period=0 " " --force ")}'

