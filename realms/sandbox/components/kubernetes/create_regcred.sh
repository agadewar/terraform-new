kubectl --kubeconfig kubeconfig create secret docker-registry -n <namespace> <secret_name> -docker-server=<docker_server> --docker-username=<docker_username> --docker-password=<docker_password>
