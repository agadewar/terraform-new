

#<font color="orange"> **Setup Sapience Azure Account via Terraform** </font>

---
##### 1. Create a Storage Account (via the Azure Portal) for Terraform remote state storage (i.e. "tfstatelower")

##### 2. Create a "tfstate" Blob container (private)

##### 3. Retrieve the "Access Key" for the Terraform remote state Storage Account via the Azure Portal... this will be used in Terraform "backend" blocks in each Terraform main.tf
SECRET :a:

##### 4. Create an Azure Service Principal via the Azure CLI: see Microsoft AKS documentation, Microsoft Azure CLI documentation, and Terraform documentation
1. az account set --subscription="<subscription_id>"
2. az ad sp create-for-rbac --skip-assignment --name Terraform (if the sp has already been created, use "az ad sp show --id http://Terraform")
3. Copy and store the output of the command above

SECRET :b:

##### 5. Create "Lab" infrastructure
1. Setup resource group(s)
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	1. Edit "terraform/lab/resource-group/main.tf"
		1. Edit "terraform { backend {} }" as needed
		2. Edit "locals { subscription_id }" as needed
		3. Edit "locals { resource_group_name }" as needed
		4. Edit "locals { common_tags {} }" as needed
	2. cd terraform/lab/resource-group
    3. terraform init
	4. terraform apply

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
		- :remote connect tinkerpop.server conf/remote.yaml
		- :> g.addV(label, 'User', 'name', 'steve.ardis@banyanhills.com', 'realm', 'banyan').addE("BELONGS_TO").to(g.addV(label, 'Branch', 'ref_id', 'Sapience', 'name', 'Sapience'))

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
		1. cd /c/projects-sapience/canopy-kubernetes-config
		2. ./update_all.sh <env> (i.e. ./update_all.sh dev)
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


<br>

# <font color="orange"> **Create a New Environment in Lab** </font>

---
1. Add a new "dev2" namespace
	1. add a new "dev2" namespace to "/terraform/lab/kubernetes/main.tf"
	2. cd /terraform/lab/kubernetes
	3. terraform apply

	http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=_all

2. Prepare "dev2" folder structure
	1. Copy "/terraform/dev" to "/terraform/dev2"
	2. Remove all .terraform folders (recursively) under "dev2"

3. Prepare "dev2" configurations
	1. Edit "/terraform/dev2/canopy/main.tf"
		1. Change all "dev" to "dev2"
		2. Change all "Dev" to "Dev2"
		3. Change "default_token" to the newly created namespace's secret name
	2. Edit "/terraform/dev2/cronjob/main.tf"
		1. Change all "dev" to "dev2"
		2. Change all "Dev" to "Dev2"
		3. Change "config/canopy-container-registry-credential-helper" namespace property to "dev2"   (this can be templated)
	3. Edit "/terraform/dev2/datalake/main.tf"
		1. Change all "dev" to "dev2"
		2. Change all "Dev" to "Dev2"
	4. Edit "/terraform/dev2/eventhubs/main.tf"
		1. Change all "dev" to "dev2"
		2. Change all "Dev" to "Dev2"
	5. Edit "/terraform/dev2/gremlin/main.tf"
		1. Change all "dev" to "dev2"
		2. Change all "Dev" to "Dev2"
	6. Edit "/terraform/dev2/service-bus/main.tf"
		1. Change all "dev" to "dev2"
		2. Change all "Dev" to "Dev2"

4. Run "terraform init && terraform apply" against each of the following folders
	1. /terraform/dev2/service-bus
	2. /terraform/dev2/eventhubs
	3. /terraform/dev2/datalake

5. Setup capture of Event Hub into Data Lake (cannot be done via Terraform at this time, as only Blob Storage is supported for capture)
	1. Setup permissions on Data Lake for Event Hubs
	2. Setup capture in Event Hubs to data lake

6. Add ConfigMaps and Secrets
	1. cp /canopy-kubernetes-config/dev /canopy/kubernetes-config/dev2
	2. <font color="red">eventpipeline-service needs to be fixed to dynamically build eventpipeline.conf at container startup</font>
	3. Edit properties (remove the need for this via ${environment} property)
		1. Edit "sapience-event-hub-journal.properties"
			1. Grab the Event Hub key and update "event-hub.key" 
				- <font color="red">this needs to be put into a secret</font>
		2. Edit "global.properties"
			1. Change the "environment" property from "dev" to "dev2" 
				- <font color="red">this needs to be put into a ConfigMap</font>
			2. Change the "spring.datasource.*" properties 
				- <font color="red">this needs to be put into a secret</font>
		3. Edit all secrets files
			- <font color="red">these can be templated</font>
			- <font color="red">be sure to copy the amqp.password from the Azure Service Bus</font>
		4. Deploy ConfigMaps and Secrets
			1. cd canopy-kubernetes-config
			2. ./update_all.sh dev2
		5. Run "terraform init && terraform apply" against each of the following folders
			1. /terraform/dev2/cronjob
			2. /terraform/dev2/gremlin
		6. Trigger the "canopy-container-registry-credential-helper" CronJob
		7. Run "terraform init && terraform apply" against each of the following folders
			1. /terraform/dev2/canopy
		8. Setup the root of the hierarchy via Gremlin CLI
			1. conf/remote.yaml
				- hosts: [ Cosmos host ]
				- port: 8182
				- serializer: { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV1d0, config: { serializeResultToString: true }}
				- bin/gremlin.sh
				- :remote connect tinkerpop.server conf/remote.yaml
				- :> g.addV(label, 'User', 'name', 'steve.ardis@banyanhills.com', 'realm', 'banyan').addE("BELONGS_TO").to(g.addV(label, 'Branch', 'ref_id', 'Sapience', 'name', 'Sapience'))