# Private Cluster example

Deploys Private Cluster with Hub & Spoke UDR to Azure Firewall for egress.


### 1. Rover login, Environment & example set
Ensure the below is set prior to apply or destroy.
```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
export TF_VAR_environment=[YOUR_ENVIRONMENT]
# Set the folder name of this example
example=204-private-cluster
```
### 2. Apply Landingzones
```bash
# Add the lower dependency landingzones
# rover --clone-landingzones --clone-branch vnext13
git clone --branch vnext https://github.com/Azure/caf-terraform-landingzones.git /tf/caf/public
git clone --branch HN-aks git@github.com:aztfmod/terraform-azurerm-caf.git /tf/caf/modules

# Deploy the launchpad light to store the tfstates
rover -lz /tf/caf/public/landingzones/caf_launchpad -launchpad -var-file /tf/caf/configuration/100_configuration.tfvars -a apply
## To deploy AKS some dependencies are required to like networking and some acounting, security and governance services are required.
rover -lz /tf/caf/public/landingzones/caf_foundations -a apply

# Deploy networking
# Deploy networking hub services
networking_hub="/tf/caf/examples/aks/${example}/networking_hub"
rover -lz /tf/caf/public/landingzones/caf_networking/ \
      -tfstate networking_hub.tfstate \
      -var-file ${networking_hub}/configuration.tfvars \
      -var-file ${networking_hub}/firewalls.tfvars \
      -var-file ${networking_hub}/nsgs.tfvars \
      -var-file ${networking_hub}/public_ips.tfvars \
      -a apply

networking_spoke="/tf/caf/examples/aks/${example}/networking_spoke"
rover -lz /tf/caf/public/landingzones/caf_networking/ \
      -tfstate ${example}_landingzone_networking.tfstate \
      -var-file ${networking_spoke}/configuration.tfvars \
      -var-file ${networking_spoke}/route_tables.tfvars \
      -var-file ${networking_spoke}/nsgs.tfvars \
      -var-file ${networking_spoke}/public_ips.tfvars \
      -var-file ${networking_spoke}/bastion.tfvars \
      -var tags={example=\"${example}\"} \
      -a apply
# Run AKS landing zone deployment

rover -lz /tf/caf/ \
      -tfstate ${example}_landingzone_aks.tfstate \
      -var-file /tf/caf/examples/aks/${example}/configuration.tfvars \
      -var tags={example=\"${example}\"} \
      -a apply    
```
### 3. Destroy Landingzones
Have fun playing with the landing zone an once you are done, you can simply delete the deployment using:

```bash
rover -lz /tf/caf/ \
      -tfstate ${example}_landingzone_aks.tfstate \
      -var-file /tf/caf/examples/aks/${example}/configuration.tfvars \
      -var tags={example=\"${example}\"} \
      -a destroy -auto-approve
rover -lz /tf/caf/public/landingzones/caf_networking/ \
      -tfstate ${example}_landingzone_networking.tfstate \
      -var-file /tf/caf/examples/aks/${example}/landingzone_networking.tfvars \
      -var tags={example=\"${example}\"} \
      -a destroy -auto-approve

# Only destroy Foundation & Launchpad if you have no other Landingzones dependent on them.
rover -lz /tf/caf/public/landingzones/caf_foundations -a destroy

# to destroy the launchpad you need to conifrm you are connected with your user. If not reconnect with
rover login -t terraformdev.onmicrosoft.com -s [subscription GUID]

rover -lz /tf/caf/public/landingzones/caf_launchpad -launchpad -var-file /tf/caf/configuration/bicycle_launchpad_configuration.tfvars -a destroy
```
