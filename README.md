
	1. Create a "terraformstatesapience" Storage Account via the Azure Portal
	2. Create a "tfstate" Blob container (private)
	3. Retrieve the "Access Key" for the "terraformstatesapience" Storage Account via the Azure Portal... this will be used in Terraform "backend" blocks in each Terraform main.tf


	1. Create an Azure Service Principal via the Azure CLI: see Microsoft AKS documentation, Microsoft Azure CLI documentation, and Terraform documentation

		1. az account set --subscription="102120b5-ffe5-46c3-bdb5-19248bcb798b"
		2. az ad sp create-for-rbac --skip-assignment --name Terraform
		3. Copy and store the output of the command above
	2. Create "Lab" infrastructure

		1. Setup resource group(s)

			1. cd /c/projects-sapience/terraform/lab/resource-group
			2. terraform init
			3. terraform apply
		2. Setup Kubernetes/AKS

			1. cd /c/projects-sapience/terraform/lab/kubernetes
			2. terraform init
			3. terraform apply
	3. Create "Dev" infrastructure

		1. Setup service-bus

			1. cd /c/projects-sapience/terraform/dev/service-bus
			2. terraform init
			3. terraform apply
		2. Setup Gremlin

			1. cd /c/projects-sapience/terraform/dev/gremlin
			2. terraform init
			3. terraform apply
		3. Setup Canopy

			1. Setup Canopy container registry credentials

				1. Setup AWS credentials as secrets

					1. cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
					2. echo "" > secrets/aws_access_key_id
					3. echo "" > secrets/aws_secret_access_key
					4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret banyan-aws
					5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic banyan-aws --namespace=dev --from-file=secrets/aws_access_key_id --from-file=secrets/aws_secret_access_key
				2. Deploy  CronJob(s)

					1. cd /c/projects-sapience/terraform/dev/cronjob
					2. terraform init
					3. terraform apply
					4. To make sure the secret for the "Setup Canopy" step is created, manually trigger this through the Kubernetes dashboard
			2. Deploy secrets

				1. eventpipeline-leaf-broker

					1. cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
					2. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap eventpipeline-leaf-broker
					3. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap eventpipeline-leaf-broker --namespace=dev --from-file=application.properties=eventpipeline-leaf-broker.properties --from-file=global.properties=global.properties
					4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret eventpipeline-leaf-broker
					5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic eventpipeline-leaf-broker --namespace=dev --from-file=secrets/canopy.database.username --from-file=secrets/canopy.database.password
				2. canopy-user-service

					1. cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
					2. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap canopy-user-service
					3. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap canopy-user-service --namespace=dev --from-file=application.properties=canopy-user-service.properties --from-file=global.properties=global.properties
					4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret canopy-user-service
					5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic canopy-user-service --namespace=dev --from-file=secrets/canopy.database.username --from-file=secrets/canopy.database.password
				3. canopy-hierarchy-service

					1. cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
					2. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap canopy-hierarchy-service
					3. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap canopy-hierarchy-service --namespace=dev --from-file=application.properties=canopy-hierarchy-service.properties --from-file=global.properties=global.properties
					4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret canopy-hierarchy-service
					5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic canopy-hierarchy-service --namespace=dev
				4. canopy-device-service

					1. cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
					2. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap canopy-device-service
					3. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap canopy-device-service --namespace=dev --from-file=application.properties=canopy-device-service.properties --from-file=global.properties=global.properties
					4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret canopy-device-service
					5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic canopy-device-service --namespace=dev --from-file=secrets/canopy.database.username --from-file=secrets/canopy.database.password --from-file=secrets/google.api.key
				5. eventpipeline-service

					1. cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
					2. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap eventpipeline-service
					3. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap eventpipeline-service --namespace=dev --from-file=application.properties=eventpipeline-service.properties --from-file=global.properties=global.properties
					4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret eventpipeline-service
					5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic eventpipeline-service --namespace=dev --from-file=secrets/canopy.database.username --from-file=secrets/canopy.database.password
				6. sapience-event-hub-journal

					1. cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
					2. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap sapience-event-hub-journal
					3. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap sapience-event-hub-journal --namespace=dev --from-file=application.properties=sapience-event-hub-journal.properties --from-file=global.properties=global.properties
					4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret sapience-event-hub-journal
					5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic sapience-event-hub-journal --namespace=dev
			3. Deploy Canopy containers



				1. cd /c/projects-sapience/terraform/dev/canopy
				2. terraform init
				3. terraform apply



