- [Setup Sapience Azure Account via Terraform](#setup-sapience-azure-account-via-terraform)
- [Create a New Environment in Lab](#create-a-new-environment-in-lab)




# Setup Sapience Azure Account via Terraform 

---
##### 1. Create a "terraformstatesapience" Storage Account via the Azure Portal

##### 2. Create a "tfstate" Blob container (private)

##### 3. Retrieve the "Access Key" for the "terraformstatesapience" Storage Account via the Azure Portal... this will be used in Terraform "backend" blocks in each Terraform main.tf
SECRET :a:

##### 4. Create an Azure Service Principal via the Azure CLI: see Microsoft AKS documentation, Microsoft Azure CLI documentation, and Terraform documentation
1. az account set --subscription="102120b5-ffe5-46c3-bdb5-19248bcb798b"
2. az ad sp create-for-rbac --skip-assignment --name Terraform
3. Copy and store the output of the command above

SECRET :b:

##### 5. Create "Lab" infrastructure
1. Setup resource group(s)
	1. cd /c/projects-sapience/terraform/lab/resource-group
	2. terraform init
	3. terraform apply

2. Setup Kubernetes/AKS
	1. cd /c/projects-sapience/terraform/lab/kubernetes
	2. terraform init
	3. terraform apply
##### 6. Create "Dev" infrastructure
1. Setup service-bus
	1. cd /c/projects-sapience/terraform/dev/service-bus
	2. terraform init
	3. terraform apply

2. Setup Gremlin
	1. cd /c/projects-sapience/terraform/dev/gremlin
	2. terraform init
	3. terraform apply
	4. Configure user(s) in Gremlin
	5. Download Gremlin / Tinkerpop console http://tinkerpop.apache.org/docs/current/tutorials/the-gremlin-console/
	6. conf/remote.yaml
	8. hosts: [168.61.37.11]
	9. port: 8182
	10. serializer: { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV1d0, config: { serializeResultToString: true }}
	11. bin/gremlin.sh
	12. :remote connect tinkerpop.server conf/remote.yaml
	13. :> g.addV(label, 'Branch', 'id', 'Sapience', 'name', 'Sapience')
	14. :> g.addV(label, 'User', 'name', 'steve.ardis@banyanhills.com', 'realm', 'banyan').next().addEdge('BELONGS_TO', g.V(0).next())

3. Setup Canopy
	1. Setup Canopy container registry credentials
		1. Setup AWS credentials as secrets
			1. cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
			2. echo "<c>" > secrets/aws_access_key_id
			3. echo "<d>" > secrets/aws_secret_access_key
			4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret banyan-aws
			5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic banyan-aws --namespace=dev --from-file=secrets/aws_access_key_id --from-file=secrets/aws_secret_access_key
		2. Deploy  CronJob(s)
			1. cd /c/projects-sapience/terraform/dev/cronjob
			2. terraform init
			3. terraform apply
			4. To make sure the secret for the "Setup Canopy" step is created, manually trigger this through the Kubernetes dashboard
	
	2. Configure global.properties
		1. Edit /c/projects-sapience/canopy-kubernetes-config/dev/canopy/global.properties
			1. environment=
			2. spring.datasource.url=
			3. spring.datasource.username=
			4. spring.datasource.password=
			5. amqp.url=
		2. Edit /c/projects-sapience/canopy-kubernetes-config/dev/canopy/eventpipeline-leaf-broker.properties
			1. messaging.event-ingestion-queue=
		3. Edit sapience-event-hub-journal.properties
			1. NEEDS PARAMETERIZED VIA SECRETS
		4. Edit Dockerfile for eventpipeline-service in cat eventpipeline.sources.in.queue=sapience-dev-canopy-eventpipeline\n\
	
	3. Deploy ConfigMaps and Secrets
		1. eventpipeline-leaf-broker
			```
			cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap eventpipeline-leaf-broker
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap eventpipeline-leaf-broker --namespace=dev --from-file=application.properties=eventpipeline-leaf-broker.properties --from-file=global.properties=global.properties
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret eventpipeline-leaf-broker
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic eventpipeline-leaf-broker --namespace=dev --from-file=secrets/canopy.database.username --from-file=secrets/canopy.database.password --from-file=secrets/canopy.amqp.password
			```
		2. canopy-user-service
			```
			cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap canopy-user-service
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap canopy-user-service --namespace=dev --from-file=application.properties=canopy-user-service.properties --from-file=global.properties=global.properties
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret canopy-user-service
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic canopy-user-service --namespace=dev --from-file=secrets/canopy.database.username --from-file=secrets/canopy.database.password --from-file=secrets/canopy.amqp.password
			```
		3. canopy-hierarchy-service
			```
			cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap canopy-hierarchy-service
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap canopy-hierarchy-service --namespace=dev --from-file=application.properties=canopy-hierarchy-service.properties --from-file=global.properties=global.properties
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret canopy-hierarchy-service
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic canopy-hierarchy-service --namespace=dev
			```
		4. canopy-device-service
			```
			cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap canopy-device-service
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap canopy-device-service --namespace=dev --from-file=application.properties=canopy-device-service.properties --from-file=global.properties=global.properties
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret canopy-device-service
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic canopy-device-service --namespace=dev --from-file=secrets/canopy.database.username --from-file=secrets/canopy.database.password --from-file=secrets/google.api.key --from-file=secrets/canopy.amqp.password
			```
		5. eventpipeline-service
			```
			cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap eventpipeline-service
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap eventpipeline-service --namespace=dev --from-file=application.properties=eventpipeline-service.properties --from-file=global.properties=global.properties
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret eventpipeline-service
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic eventpipeline-service --namespace=dev --from-file=secrets/canopy.database.username --from-file=secrets/canopy.database.password --from-file=secrets/canopy.amqp.password
			```
		6. sapience-event-hub-journal
			```
			cd /c/projects-sapience/canopy-kubernetes-config/dev/canopy
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete configmap sapience-event-hub-journal
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create configmap sapience-event-hub-journal --namespace=dev --from-file=application.properties=sapience-event-hub-journal.properties --from-file=global.properties=global.properties
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret sapience-event-hub-journal
			kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic sapience-event-hub-journal --namespace=dev --from-file=secrets/canopy.amqp.password
			```
	4. Deploy Canopy containers
		1. cd /c/projects-sapience/terraform/dev/canopy
		2. terraform init
		3. terraform apply

4. Setup Data Lake
	1. cd /c/projects-sapience/terraform/dev/datalake
	2. Review the "azurerm_data_lake_store_firewall_rule"(s) that are configured in "main.tf"
	3. terraform init
	4. terraform apply

5. Setup Event Hubs
	1. cd /c/projects-sapience/terraform/dev/eventhubs
	2. terraform init
	3. terraform apply
	4. Give permissions to the "datalake" Event Hub to capture into the Data Lake configured above (see: https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-archive-eventhub-capture#assign-permissions-to-event-hubs)
		1. Create a New Folder in the Data Lake named "raw_data"
		2. Follow the instructions in the link above
	5. Go to Azure Portal and configure the "datalake" Event Hub to "Capture" -> On and into the Data Lake configured above at path "/raw_data" (see: https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-enable-through-portal)




# Create a New Environment in Lab

---

