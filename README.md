

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
		1. Change 'key' in terraform{} block: "sapience.realm.<font color="red">lab</font>.kubernetes.terraform.tfstate"
	4. cd terraform/realms/lab/kubernetes
	5. terraform init -backend-config="../../../config/backend.config"
	6. terraform apply -var-file="../../../config/realm.lab.tfvars"
	- If it returns an error similar to this, you'll need to run Step 5 (Create "Lab" infrastructure -> Set resource group): 
	<font color="red"> Error inspecting states in the "azurerm" backend: Get https://terraformstatesapience.blob.core.windows.net/tfstate?comp=list&prefix=sapience.lab.kubernetes.terraform.tfstateenv%3A&restype=container: dial tcp: lookup terraformstatesapience.blob.core.windows.net on 64.238.96.12:53: no such host </font>
	
##### 2. Create "Dev" Environment Infrastructure
1. Setup Kubernetes namespace
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/kubernetes-namespace/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.kubernetes-namespace.terraform.tfstate"
	3. cd terraform/environments/dev/kubernetes-namespace
    4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
	6. The new Namespace will get a default-token-* secret that needs to be added to environment.dev.tfvars. Set kubernetes_namespace_default_token.Retrieve this from the Kubernetes Portal -> Secrets.

2. Setup service-bus
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/service-bus/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.service-bus.terraform.tfstate"
	3. cd terraform/environments/dev/service-bus
    4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

3. Setup Data Lake
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/data-lake/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.data-lake.terraform.tfstate"
	3. cd terraform/environments/dev/data-lake
	4. Review the "azurerm_data_lake_store_firewall_rule"(s) that are configured in "main.tf"
	5. terraform init -backend-config="../../../config/backend.config"
	6. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

4. Setup Event Hubs
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/event-hubs/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.event-hubs.terraform.tfstate"
	3. cd terraform/environments/dev/event-hubs
	4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
	6. Give permissions to the "datalake" Event Hub to capture into the Data Lake configured above (see: https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-archive-eventhub-capture#assign-permissions-to-event-hubs)
		1. Create a New Folder in the Data Lake named "raw_data"
		2. Follow the instructions in the link above
	7. Go to Azure Portal and configure the "datalake" Event Hub to "Capture" (see: https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-enable-through-portal)
		1. From the 'Overview' tab, scroll to the bottom and click on 'datalake'
			1. Click on the 'Captures' link and set Capture = On
			2. Set 'Capture Provider' = Azure Data Lake Store
			3. Set 'Data Lake Store' = sapiencedev
			4. Set 'Data Lake Path' = /raw_data

5. Setup Databases
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/database/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.database.terraform.tfstate"
	3. cd terraform/environments/dev/database
	4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
	6. Configure user(s) in Gremlin
	    1. Create graph database in Cosmos
			1. In Azure Portal, go to Azure Cosmos DB
			2. Click on sapience-canopy-hierarchy-dev
			3. Click 'Add Graph'
			4. Set "Database id = canopy" AND "Graph Id = hierarchy"
			5. For Dev, we set Storage Capacity = 'Fixed (10GB) and Throughput = 400
	    2. Execute this Gremlin query via the Cosmos portal:
			- g.addV(label, 'User', 'name', 'steve.ardis@banyanhills.com', 'realm', 'banyan').addE("BELONGS_TO").to(g.addV(label, 'Branch', 'ref_id', 'Sapience', 'name', 'Sapience'))
	7. Setup SQL Server (from Repo: canopy-sql)
		1. Run DDL in canopy-sql/ddl
		2. Run DML in canopy-sql/dml

6. Retrieve Keys
	1. Service Bus
		1. From Azure Portal -> Service Bus -> Click on sapience-dev -> 'Shared access policies' -> 'RootManageSharedAccessKey'
		2. Copy the Primary Key
		3. In environment.dev.tfvars, set canopy_amqp_password to the Primary Key
	2. Event Hubs
		1. From Azure Portal -> Event Hubs -> Click on sapience-event-hub-journal-dev -> 'Shared access policies' -> 'RootManageSharedAccessKey'
		2. Copy the Primary Key
		3. In environment.dev.tfvars, set canopy_event_hub_password to the Primary Key
	3. Cosmos DB
		1. From Azure Portal -> Event Hubs -> Click on sapience-canopy-hierarchy-dev -> Keys
		2. Copy the Primary Key
		3. In environment.dev.tfvars, set canopy_hierarchy_cosmos_password to the Primary Key

7. Setup Canopy
	1. Deploy CronJob(s)
		1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
		2. Edit "terraform/environments/dev/cronjob/main.tf"
			1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.cronjob.terraform.tfstate"
		3. cd terraform/environments/dev/cronjob
		4. terraform init -backend-config="../../../config/backend.config"
		5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
		6. To make sure the secret for the "Setup Canopy" step is created, manually trigger this through the Kubernetes dashboard
	
	2. Deploy Canopy containers
		1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	    2. Edit "terraform/environments/dev/canopy/main.tf"
		    1. Edit "terraform { backend {} }" as needed
		    2. Edit "locals { * }" as needed   *** be sure to change the "default_token" property based on the K8S namespace default token that is generated automatically (look in K8S Secrets)
		3. cd /c/projects-sapience/terraform/environments/dev/canopy
		4. terraform init -backend-config="../../../config/backend.config"
		5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

8. Setup DNS Zone
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/dns/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.dns.terraform.tfstate"
	3. cd terraform/environments/dev/dns
    4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

9. Setup Databricks
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/databricks/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.databricks.terraform.tfstate"
	3. cd terraform/environments/dev/databricks
    4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

10. Setup Ambassador
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/ambassador/main.tf"
		1. Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.ambassador.terraform.tfstate"
	3. cd terraform/environments/dev/ambassador
    4. terraform init -backend-config="../../../config/backend.config"
	5. terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"

