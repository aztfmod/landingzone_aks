# Deployment of the landing zones to support AKS clusters

The following steps guides you with the deployment of the landing zones required to run the examples.

## Setting up test environment

AKS landing zone operates at **level 3**.

For a review of the hierarchy approach of Cloud Adoption Framework for Azure landing zones on Terraform, you can refer to [the following documentation](https://github.com/Azure/caf-terraform-landingzones/blob/master/documentation/code_architecture/hierarchy.md).

With the following steps, you can deploy a simplified enterprise framework that setups the minimal foundations for enterprise. Once those steps are completed, you will be able to scaffold the AKS landing zones:

### Authenticate to your development environment

We assume that at this step, you have cloned the AKS landing zones repository (this repo) on your machine and have opened it into Visual Studio Code development environment.

Once into the development environment, please use the following steps:

```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
export environment=[YOUR_ENVIRONMENT]
```

### Apply DevOps foundations and networking configuration

```bash
# Level 0 - foundations services for devops
# Add the lower dependency landingzones
git clone --branch 0.4 https://github.com/Azure/caf-terraform-landingzones.git /tf/caf/public

# Deploy the launchpad to store the tfstates
# the /tf/caf/configuration/level0/100 is a tier down version of the caf_launchpad scenario 200
# it does not provide collaboration through azure ad groups and diagnostics settings
rover -lz /tf/caf/public/landingzones/caf_launchpad \
  -launchpad \
  -var-folder /tf/caf/examples/1-dependencies/launchpad/150 \
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

Once the previous steps have been completed, the deployment of the lightweigth enterprise scaffold to execute the AKS example landingzones is ready and you can step to one of the examples.

## Examples

The CAF landing zone for AKS provides you with the following examples

### Core AKS landing zone

You can find detailed steps for each of the following scenario:

| AKS landing zone example                                                                                              | Description                                                |
|---------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| [101-single-cluster](./examples/aks/101-single-cluster)| Provision single AKS cluster within open VNET |
| [102-multi-nodepools](./examples/aks/102-multi-nodepools)| Provision single AKS cluster with multiple nodepool within separate subnet (1 open VNET)|
| [103-multi-clusters](./examples/aks/103-multi-clusters)| Provision multiple AKS clusters in separate regions (different open VNETs)                     |
| [204-private-cluster](./examples/aks/204-private-cluster)| Provision private AKS clusters within private VNET with Hub & Spoke UDR to Azure Firewall |

### AKS Application landing zone

Deploys Applications Landing zone on top of an AKS Landing zone
| Application Landing Zone Example                                                                                              | Description                                                |
|---------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| [Flux](./examples/applications/flux)| Provision Flux helm charts on AKS LZ |
| [ArgoCD](./examples/applications/argocd)| Provision ArgoCD helm charts on AKS LZ |