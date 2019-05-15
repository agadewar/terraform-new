

#<font color="orange"> **Setup Sapience Azure Account via Terraform** </font>


### Requirements
----
1. Azure CLI locally installed.  Version 2.0.60+.  
	```
	az --version
	az extension add --name storage-preview
	```
2. Helm locally installed
3. Docker locally installed?

### Create Storage Account and Access Key (Only do this when creating the very first Terraform environment)
----
1. Create a Storage Account (via the Azure Portal) for Terraform remote state storage for the resource group (i.e. "tfstatelab")
2. Create a "tfstate" Blob container (private)
3. Retrieve the "Access Key" for the Terraform remote state Storage Account via the Azure Portal... this will be used in Terraform "backend" blocks in each Terraform main.tf

	**SECRET** :a:

4. Create an Azure Service Principal via the Azure CLI: see Microsoft AKS documentation, Microsoft Azure CLI documentation, and Terraform documentation
	```
	az account set --subscription="<subscription_id>"
	az ad sp create-for-rbac --skip-assignment --name Terraform`
	```
	If the sp has already been created, use `az ad sp show --id http://Terraform`
5. Copy and store the output of the command above

	**SECRET** :b:

### Create Realm and Environment Infrastructure
----
##### 1. Create "Lab" Realm Infrastructure
1. Setup resource group(s)
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/realms/lab/resource-group/main.tf"
		- Change 'key' in terraform{} block: "sapience.realm.<font color="red">lab</font>.resource-group.terraform.tfstate"
	3. Terraform Initialize and Apply
		```
		cd terraform/realms/lab/resource-group
		terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars"
		```

2. Setup Kubernetes/AKS
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Remove any existing terraform/lab/kubernetes/kubeconfig
	3. Edit "terraform/realms/lab/kubernetes/main.tf"
		- Change 'key' in terraform{} block: "sapience.realm.<font color="red">lab</font>.kubernetes.terraform.tfstate"
	4. Terraform Initialize and Apply
		```
		cd terraform/realms/lab/kubernetes
		terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars"
		```
	- If it returns an error similar to this, you'll need to run Step 5 (Create "Lab" infrastructure -> Set resource group): 

		`Error inspecting states in the "azurerm" backend: Get https://terraformstatesapience.blob.core.windows.net/tfstate?comp=list&prefix=sapience.lab.kubernetes.terraform.tfstateenv%3A&restype=container: dial tcp: lookup terraformstatesapience.blob.core.windows.net on 64.238.96.12:53: no such host`

##### 2. Create "Dev" Environment Infrastructure
1. Setup Kubernetes namespace
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/kubernetes-namespace/main.tf"
		- Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.kubernetes-namespace.terraform.tfstate"
	3. Terraform Initialize and Apply
		```
		cd terraform/environments/dev/kubernetes-namespace
		terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
		```
	- The new Namespace will get a default-token-* secret that needs to be added to environment.dev.tfvars. Set kubernetes_namespace_default_token.Retrieve this from the Kubernetes Portal -> Secrets.

2. Setup service-bus
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/service-bus/main.tf"
		- Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.service-bus.terraform.tfstate"
	3. Terraform Initialize and Apply
		```
		cd terraform/environments/dev/service-bus
		terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
		```

3. Setup Data Lake
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/data-lake/main.tf"
		- Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.data-lake.terraform.tfstate"
		- Review the "azurerm_data_lake_store_firewall_rule"(s)
	3. Terraform Initialize and Apply
		```
		cd terraform/environments/dev/data-lake
		terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
		```

4. Setup Databases
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/database/main.tf"
		- Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.database.terraform.tfstate"
	3. Terraform Initialize and Apply
		```
		cd terraform/environments/dev/database
		terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
		```
	4. Configure user(s) in Gremlin
	    1. Create graph database in Cosmos
			1. In Azure Portal, go to Azure Cosmos DB
			2. Click on sapience-canopy-hierarchy-dev
			3. Click 'Add Graph'
			4. Set "Database id = canopy" AND "Graph Id = hierarchy"
			5. For Dev, we set Storage Capacity = 'Fixed (10GB) and Throughput = 400
	    2. Execute this Gremlin query via the Cosmos portal:
			- `g.addV(label, 'User', 'name', 'steve.ardis@banyanhills.com', 'realm', 'banyan').addE("BELONGS_TO").to(g.addV(label, 'Branch', 'ref_id', 'Sapience', 'name', 'Sapience'))`
	5. Setup SQL Server (from Repo: canopy-sql)
		1. Run DDL in canopy-sql/ddl
		2. Run DML in canopy-sql/dml

5. Retrieve Keys
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

6. Setup Canopy
	1. Deploy CronJob(s)
		1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
		2. Edit "terraform/environments/dev/cronjob/main.tf"
			- Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.cronjob.terraform.tfstate"
		3. Terraform Initialize and Apply
			```
			cd terraform/environments/dev/cronjob
			terraform init -backend-config="../../../config/backend.config"
			terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
			```
		4. To make sure the secret for the "Setup Canopy" step is created, manually trigger this through the Kubernetes dashboard
	
	2. Deploy Canopy containers
		1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	    2. Edit "terraform/environments/dev/canopy/main.tf"
		    1. Edit "terraform { backend {} }" as needed
			2. Update kubernetes_namespace_default_token in the environment.<font color="red">dev</font>.tfvars file in the config folder.  This token is automatically generated.
				1. In the Kubernetes Portal, switch to the current environment Namespace
				2. Click on Secrets and find the Secret named default-token-XXXXX
				3. Copy the characters in place of the XXXXX and replace it in the environment.<font color="red">dev</font>.tfvars file.
		3. Terraform Initialize and Apply
			```
			cd /c/projects-sapience/terraform/environments/dev/canopy
			terraform init -backend-config="../../../config/backend.config"
			terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
			```

7. Setup DNS Zone
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/dns/main.tf"
		- Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.dns.terraform.tfstate"
	3. Terraform Initialize and Apply
		```
		cd terraform/environments/dev/dns
		terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
		```
	4. You will need to manually add NS records if the DNS is hosted by another provider.  You don't need to do this step if the Zone is hosted by Azure in the same Subscription.
		1. In Azure, go to DNS Zones and click on the newly created Zone.
		2. Copy the 4 Name Servers listed.
		3. At the DNS host, create the NS records.  _(Today, this is in Net4India)_

8. Setup Databricks
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/databricks/main.tf"
		- Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.databricks.terraform.tfstate"
	3. Terraform Initialize and Apply
		```
		cd terraform/environments/dev/databricks
    	terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
		```

9. Setup Ambassador
    1. Remove any existing ".terraform" folder if copying from an existing folder and this is new non-existing infrastructure
	2. Edit "terraform/environments/dev/ambassador/main.tf"
		- Change 'key' in terraform{} block: "sapience.environment.<font color="red">dev</font>.ambassador.terraform.tfstate"
	3. Terraform Initialize and Apply
		```
		cd terraform/environments/dev/ambassador
    	terraform init -backend-config="../../../config/backend.config"
		terraform apply -var-file="../../../config/realm.lab.tfvars" -var-file="../../../config/environment.dev.tfvars"
		```
	4. After the pods are running, you will need to update the LetsEncrypt domain and token in the environment.<font color="red">dev</font>.tfvars file
		1. In the Kubernetes Portal, find the Cert Manager pod and view its logs.  Near the top, you'll find a line containing the domain and token.
			
			`"Looking up Ingresses for selector certmanager.k8s.io/acme-http-domain=1937180995,certmanager.k8s.io/acme-http-token=869731899"`
		2. Update the following settings in environment.<font color="red">dev</font>.tfvars
			- ambassador_letsencrypt_acme_http_domain
			- ambassador_letsencrypt_acme_http_token


