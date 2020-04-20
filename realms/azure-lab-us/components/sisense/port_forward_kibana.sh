echo
echo "See: https://akomljen.com/get-kubernetes-logs-with-efk-stack-in-5-minutes/"
echo "The Kibana dashboard can be seen by visiting: http://localhost:5601"
echo

kubectl --kubeconfig .local/kubeconfig port-forward `. get_one_pod_name_by_ns_and_label.sh logging app=kibana` -n logging 5601 $@
