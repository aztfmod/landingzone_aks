# Single Cluster example

Deploys a Single AKS cluster in a virtual network.

### 1. Rover login, Environment & example set

Ensure the below is set prior to apply or destroy.

```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
export environment=[YOUR_ENVIRONMENT]
# Set the folder name of this example
example=101-single-cluster
```

### 2. Apply Landingzones

```bash
# Level 0 - foundations services for devops
# Add the lower dependency landingzones
git clone --branch 0.4 https://github.com/Azure/caf-terraform-landingzones.git /tf/caf/public

# Deploy the launchpad to store the tfstates
# the /tf/caf/configuration/level0/100 is a tier down version of the caf_launchpad scenario 200
# it does not provide collaboration through azure ad groups and diagnostics settings
rover -lz /tf/caf/public/landingzones/caf_launchpad \
  -launchpad \
  -var-folder /tf/caf/configuration/level0/100 \
  -level level0 \
  -env ${environment} \
  -a apply

# Level1
## To deploy AKS some dependencies are required to like networking and some accounting, security and governance services are required.
rover -lz /tf/caf/public/landingzones/caf_foundations \
  -level level1 \
  -env ${environment} \
  -a apply

# Deploy shared_services
rover -lz /tf/caf/public/landingzones/caf_shared_services/ \
  -tfstate caf_shared_services.tfstate \
  -parallelism 30 \
  -level level2 \
  -env ${environment} \
  -a apply

# Deploy networking hub
rover -lz /tf/caf/public/landingzones/caf_networking/ \
  -tfstate networking_hub.tfstate \
  -var-folder /tf/caf/public/landingzones/caf_networking/scenario/101-multi-region-hub \
  -env ${environment} \
  -level level2 \
  -a apply


# Deploy networking spoke for AKS
rover -lz /tf/caf/public/landingzones/caf_networking/ \
  -tfstate networking_spoke_aks.tfstate \
  -var-folder /tf/caf/examples/1-dependencies/level3/networking_spoke_aks \
  -env ${environment} \
  -level level3 \
  -a plan

```

This complete the deployment of the lightweigth enterprise scaffold to execute the AKS example landingzones.