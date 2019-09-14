echo
echo "Documentation about the Ambassador Diagnostics UI can be found at: https://www.getambassador.io/reference/diagnostics/"
echo "The Ambassador Diagnostics UI can be seen by visiting: http://localhost:8877/ambassador/v0/diag/"
echo

kubectl --kubeconfig kubeconfig port-forward `. get_one_pod_name_by_ns_and_label.sh $1 service=ambassador` -n $1 8877
