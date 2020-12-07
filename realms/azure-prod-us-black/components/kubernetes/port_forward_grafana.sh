echo
echo "The Grafana dashboard can be seen by visiting: http://localhost:3000/login"
echo "The admin username/password can be found in the secret named \"prometheus-grafana\""
echo

#kubectl --kubeconfig .local/kubeconfig port-forward `. get_one_pod_name_by_ns_and_label.sh monitoring app=grafana` -n monitoring 3000
kubectl --kubeconfig .local/kubeconfig port-forward `. get_one_pod_name_by_ns_and_label.sh monitoring app.kubernetes.io/name=grafana` -n monitoring 3000
