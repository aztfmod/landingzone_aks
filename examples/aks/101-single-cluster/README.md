# Single Cluster example

Deploys a Single AKS cluster in a virtual network.

### 1. Rover login, Environment & example set

Ensure the below is set prior to apply or destroy.

```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
export TF_VAR_environment=[YOUR_ENVIRONMENT]
# Set the folder name of this example
example=101-single-cluster
```

### 2. Apply Landingzones

```bash
# Add the lower dependency landingzones
git clone --branch 0.4 https://github.com/Azure/caf-terraform-landingzones.git /tf/caf/public

# Deploy the launchpad to store the tfstates
rover -lz /tf/caf/public/landingzones/caf_launchpad -launchpad -var-file /tf/caf/configuration/100_configuration.tfvars -a apply

## To deploy AKS some dependencies are required to like networking and some accounting, security and governance services are required.
rover -lz /tf/caf/public/landingzones/caf_foundations -level level1 -a apply

# Deploy networking
rover -lz /tf/caf/public/landingzones/caf_networking/ \
      -tfstate ${example}_landingzone_networking.tfstate \
      -var-file /tf/caf/examples/aks/${example}/landingzone_networking.tfvars \
      -var tags={example=\"${example}\"} \
      -level level2 \
      -a apply

# Deploy shared_services
rover -lz /tf/caf/public/landingzones/caf_shared_services/ \
      -tfstate ${example}_caf_shared_services.tfstate \
      -var tags={example=\"${example}\"} \
      -level level2 \
      -a apply

# Run AKS landing zone deployment

rover -lz /tf/caf/ \
      -tfstate ${example}_landingzone_aks.tfstate \
      -var-file /tf/caf/examples/aks/${example}/configuration.tfvars \
      -var tags={example=\"${example}\"} \
      -level level3 \
      -a apply
```

### 3. Destroy Landing zones

Have fun playing with the landing zone an once you are done, you can simply delete the deployment using:

```bash
rover -lz /tf/caf/ \
      -tfstate ${example}_landingzone_aks.tfstate \
      -var-file /tf/caf/examples/aks/${example}/configuration.tfvars \
      -var tags={example=\"${example}\"} \
      -level level3 \
      -a destroy -auto-approve

# Only destroy foundations & Launchpad if you have no other landing zones dependent on them.
rover -lz /tf/caf/public/landingzones/caf_foundations -a destroy

# to destroy the launchpad you need to confirm you are connected with your user. If not reconnect with
rover login -t [tenand ID] -s [subscription GUID]

rover -lz /tf/caf/public/landingzones/caf_launchpad -launchpad -var-file /tf/caf/configuration/