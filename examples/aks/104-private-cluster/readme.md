# Private Cluster example

Deploys Private Cluster with Hub & Spoke UDR to Azure Firewall for egress.


### 1. Rover login, Environment & example set
Ensure the below is set prior to apply or destroy.
```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
environment=[YOUR_ENVIRONMENT]

```
### 2. Apply Landingzones
```bash

# Deploy networking
# Deploy networking hub services
#
# The following command extends the networking hub 101-multi-region-hub 

example="104-private-cluster"

rover -lz /tf/caf/public/landingzones/caf_networking/ \
  -tfstate networking_hub.tfstate \
  -var-folder /tf/caf/public/landingzones/caf_networking/scenario/101-multi-region-hub \
  -var-folder /tf/caf/examples/aks/${example}/networking_hub/single_region \
  # -var-folder /tf/caf/examples/aks/${example}/networking_hub/diagnostics \                # Uncomment to enable diagnotics
  -env ${environment} \
  -level level2 \
  -a [plan|apply]


rover -lz /tf/caf/public/landingzones/caf_networking/ \
  -tfstate networking_spoke_aks.tfstate \
  -var-folder /tf/caf/examples/1-dependencies/networking/spoke_aks/single_region \
  -var-folder /tf/caf/examples/aks/${example}/networking_spoke/single_region \
  -env ${environment} \
  -level level3 \
  -a [plan|apply]

# Run AKS landing zone deployment

# Set the folder name of this example
example=104-private-cluster

rover -lz /tf/caf/ \
  -tfstate ${example}_landingzone_aks.tfstate \
  -var-folder /tf/caf/examples/aks/${example} \
  -var tags={example=\"${example}\"} \
  -env ${environment} \
  -level level3 \
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
