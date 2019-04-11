kubectl --kubeconfig kubeconfig run stress-1 --image=progrium/stress -- --cpu 2 --io 1 --vm 2 --vm-bytes 128M --timeout 10s
