

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
	2. Edit "terraform/lab/resource-group/main.tf"
		1. Edit "terraform { backend {} }" as needed
		2. Edit "locals { * }" as needed
	3. cd terraform/lab/resource-group
    4. terraform init
	5. terraform apply

2. Setup Kubernetes/AKS
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/lab/resource-group/main.tf"
		1. Edit "terraform { backend {} }" as needed
		2. Edit "locals { * }" as needed
		3. Edit "data.terraform_remote_state.resource_group { config {} }" as needed
		4. Edit "resource.azurerm_kubernetes_cluster.kubernetes { * }" as needed
		5. Add / edit any namespace sections that need to be created (see "##### "dev" namespace (BEGIN)" -> "##### "dev" namespace (END)" )
	3. cd terraform/lab/kubernetes
	4. terraform init
	5. terraform apply
	
##### 6. Create "Dev" infrastructure
1. Setup Kubernetes namespace
   1.

1. Setup service-bus
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/dev/service-bus/main.tf"
		1. Edit "terraform { backend {} }" as needed
		2. Edit "locals { * }" as needed
		4. Edit "data.terraform_remote_state.resource_group { config {} }" as needed
	1. cd terraform/dev/service-bus
	2. terraform init
	3. terraform apply

4. Setup Data Lake
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/dev/data-lake/main.tf"
		1. Edit "terraform { backend {} }" as needed
		2. Edit "locals { * }" as needed
	3. cd terraform/dev/data-lake
	4. Review the "azurerm_data_lake_store_firewall_rule"(s) that are configured in "main.tf"
	5. terraform init
	6. terraform apply

5. Setup Event Hubs
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/dev/data-lake/main.tf"
		1. Edit "terraform { backend {} }" as needed
		2. Edit "locals { * }" as needed
	3. cd terraform/dev/event-hubs
	4. terraform init
	5. terraform apply
	6. Give permissions to the "datalake" Event Hub to capture into the Data Lake configured above (see: https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-archive-eventhub-capture#assign-permissions-to-event-hubs)
		1. Create a New Folder in the Data Lake named "raw_data"
		2. Follow the instructions in the link above
	7. Go to Azure Portal and configure the "datalake" Event Hub to "Capture" -> On and into the Data Lake configured above at path "/raw_data" (see: https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-enable-through-portal)

2. Setup Databases
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/dev/database/main.tf"
		1. Edit "terraform { backend {} }" as needed
		2. Edit "locals { * }" as needed
	1. cd terraform/dev/database
	2. terraform init
	3. terraform apply
	4. Configure user(s) in Gremlin
	    1. Create graph database in Cosmos
		![Image](../AddGraph.png)
	    5. Download Gremlin / Tinkerpop console http://tinkerpop.apache.org/docs/current/tutorials/the-gremlin-console/
		6. conf/remote.yaml
		8. hosts: [168.61.37.11]
		9. port: 8182
		10. serializer: { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV1d0, config: { serializeResultToString: true }}
		11. bin/gremlin.sh
			- :remote connect tinkerpop.server conf/remote.yaml
			- :> g.addV(label, 'User', 'name', 'steve.ardis@banyanhills.com', 'realm', 'banyan').addE("BELONGS_TO").to(g.addV(label, 'Branch', 'ref_id', 'Sapience', 'name', 'Sapience'))
	5. Setup schemas in SQL Server

3. Setup Canopy
	1. Setup Canopy container registry credentials
		1. Setup AWS credentials as secrets
			1. cd canopy-kubernetes-config/dev/canopy
			2. echo "<c>" > secrets/aws_access_key_id
			3. echo "<d>" > secrets/aws_secret_access_key
			4. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig  --ignore-not-found=true --namespace=dev delete secret banyan-aws
			5. kubectl --kubeconfig ../../../terraform/lab/kubernetes/kubeconfig create secret generic banyan-aws --namespace=dev --from-file=secrets/aws_access_key_id --from-file=secrets/aws_secret_access_key
		2. Deploy CronJob(s)
			1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	        2. Edit "terraform/dev/cronjob/main.tf"
		        1. Edit "terraform { backend {} }" as needed
		        2. Edit "locals { * }" as needed
			1. cd terraform/dev/cronjob
			2. terraform init
			3. terraform apply
			4. To make sure the secret for the "Setup Canopy" step is created, manually trigger this through the Kubernetes dashboard
	
	2. Configure global.properties
		1. Edit canopy-kubernetes-config/dev/canopy/secrets
			1. canopy.amqp.password
			2. canopy.database.password
			3. canopy.database.username
			4. canopy.event-hub.password
			5. google.api.key
		2. cd canopy-kubernetes-config
		3. ./update_all.sh dev
	
	3. Deploy Canopy containers
		1. cd /c/projects-sapience/terraform/dev/canopy
		2. terraform init
		3. terraform apply
