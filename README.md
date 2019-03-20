

#<font color="orange"> **Setup Sapience Azure Account via Terraform** </font>

---
### Create Storage Account and Access Key (Only do this when creating the very first Terraform environment)

1. Create a Storage Account (via the Azure Portal) for Terraform remote state storage for the resource group (i.e. "tfstatelab")
2. Create a "tfstate" Blob container (private)
3. Retrieve the "Access Key" for the Terraform remote state Storage Account via the Azure Portal... this will be used in Terraform "backend" blocks in each Terraform main.tf

	**SECRET** :a:

4. Create an Azure Service Principal via the Azure CLI: see Microsoft AKS documentation, Microsoft Azure CLI documentation, and Terraform documentation
	1. az account set --subscription="<subscription_id>"
	2. az ad sp create-for-rbac --skip-assignment --name Terraform (if the sp has already been created, use "az ad sp show --id http://Terraform")
	3. Copy and store the output of the command above

		**SECRET** :b:

### Create Realm and Environment Infrastructure

##### 1. Create "Lab" Realm Infrastructure
1. Setup resource group(s)
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/realms/lab/resource-group/main.tf"
		1. Change 'key' in terraform{} block: "sapience.realm.<font color="red">lab</font>.resource-group.terraform.tfstate"
	3. cd terraform/realms/lab/resource-group
    4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars"

2. Setup Kubernetes/AKS
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Remove any existing terraform/lab/kubernetes/kubeconfig
	3. Edit "terraform/realms/lab/kubernetes/main.tf"
		1. Change 'key' in terraform{} block: "sapience.realm.<font color="red">lab</font>.resource-group.terraform.tfstate"
	4. cd terraform/realms/lab/kubernetes
	5. terraform init -backend-config="../../../config/backend.config"
	6. terraform apply -var-file="../../../config/realm.lab.tfvars"
	- If it returns an error similar to this, you'll need to run Step 5 (Create "Lab" infrastructure -> Set resource group): 
	<font color="red"> Error inspecting states in the "azurerm" backend: Get https://terraformstatesapience.blob.core.windows.net/tfstate?comp=list&prefix=sapience.lab.kubernetes.terraform.tfstateenv%3A&restype=container: dial tcp: lookup terraformstatesapience.blob.core.windows.net on 64.238.96.12:53: no such host </font>
	
##### 2. Create "Dev" Environment Infrastructure
1. Setup Kubernetes namespace
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/kubernetes-namespace/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.resource-group.terraform.tfstate"
	3. cd terraform/environments/dev/kubernetes-namespace
    4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

1. Setup service-bus *** NEED TO DO.  HAD TO WAIT 4 HOURS AFTER DELETING SERVICE-BUS FROM OLD DEV SUBSCRIPTION
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/service-bus/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.resource-group.terraform.tfstate"
	3. cd terraform/environments/dev/service-bus
    4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

4. Setup Data Lake
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/data-lake/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.resource-group.terraform.tfstate"
	3. cd terraform/environments/dev/data-lake
	4. Review the "azurerm_data_lake_store_firewall_rule"(s) that are configured in "main.tf"
	5. terraform init -backend-config="../../../config/backend.config"
	6. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

5. Setup Event Hubs *** NEED TO DO
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/dev/event-hubs/main.tf"
		1. Edit "terraform { backend {} }" as needed
		2. Edit "locals { * }" as needed
		3. Edit "data.terraform_remote_state.resource_group { config {} }" as needed
	3. cd terraform/dev/event-hubs
	4. terraform init
	5. terraform apply
	6. Give permissions to the "datalake" Event Hub to capture into the Data Lake configured above (see: https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-archive-eventhub-capture#assign-permissions-to-event-hubs)
		1. Create a New Folder in the Data Lake named "raw_data"
		2. Follow the instructions in the link above
	7. Go to Azure Portal and configure the "datalake" Event Hub to "Capture" -> On and into the Data Lake configured above at path "/raw_data" (see: https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-enable-through-portal)

2. Setup Databases
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/database/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.resource-group.terraform.tfstate"
	3. cd terraform/environments/dev/database
	4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
	6. Configure user(s) in Gremlin *** LEFT OFF HERE
	    1. Create graph database in Cosmos  (SHOULD BE "Database id = canopy" AND "Graph Id = hierarchy")
		![Image](../AddGraph.png)
	    2. Execute this Gremlin query via the Cosmos portal:
			- g.addV(label, 'User', 'name', 'steve.ardis@banyanhills.com', 'realm', 'banyan').addE("BELONGS_TO").to(g.addV(label, 'Branch', 'ref_id', 'Sapience', 'name', 'Sapience'))
	7. Setup SQL Server
		1. Run DDL in canopy-sql/ddl
		2. Run DML in canopy-sql/dml

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
			3. cd terraform/dev/cronjob
			4. terraform init
			5. terraform apply
			6. To make sure the secret for the "Setup Canopy" step is created, manually trigger this through the Kubernetes dashboard
	
	2. Configure secrets
		1. Edit canopy-kubernetes-config/dev/canopy/secrets
			1. canopy.amqp.password
			2. canopy.database.password
			3. canopy.database.username
			4. canopy.event-hub.password
			5. google.api.key
		2. Edit canopy-kubernetes-config/dev/canopy/gremlin-cosmos.yaml
		3. cd canopy-kubernetes-config
		4. ./update_all.sh dev
	
	3. Deploy Canopy containers
		1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	    2. Edit "terraform/dev/canopy/main.tf"
		    1. Edit "terraform { backend {} }" as needed
		    2. Edit "locals { * }" as needed   *** be sure to change the "default_token" property based on the K8S namespace default token that is generated automatically (look in K8S Secrets)
		3. cd /c/projects-sapience/terraform/dev/canopy
		4. terraform init
		5. terraform apply
