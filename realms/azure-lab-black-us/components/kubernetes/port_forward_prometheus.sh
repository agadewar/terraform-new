echo
echo "See: https://akomljen.com/get-kubernetes-cluster-metrics-with-prometheus-in-5-minutes/"
echo "The Prometheus UI can be seen by visiting: http://localhost:9090/graph"
echo

kubectl --kubeconfig .local/kubeconfig port-forward `. get_one_pod_name_by_ns_and_label.sh monitoring app=prometheus` -n monitoring 9090
