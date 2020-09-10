# Pre-requisites
git clone git@github.com:aztfmod/terraform-azurerm-caf-landingzone-modules.git /tf/caf/public

## Set your environment
export TF_VAR_environment=bicycle

# Level0
## Launchpad with scenario 200 at minimum
rover -lz /tf/caf/public/landingzones/caf_launchpad -launchpad -var-file /tf/caf/configuration/bicycle_launchpad_configuration.tfvars -a apply

# Level1
## Foundations
rover -lz /tf/caf/public/landingzones/caf_foundations -a apply

# Level2
## Deploy the networking hub
<!-- rover -lz /tf/caf/public/landingzones/caf_networking/ -var-file /tf/caf/public/landingzones/caf_networking/scenario/200-single-region-hub/configuration.tfvars -tfstate networking_hub.tfstate -a apply -->

## Deploy isolated networking hub and spoke for AKS environment
rover -lz /tf/caf/public/landingzones/caf_networking/ -var-file /tf/caf/examples/aks/204-private-cluster/caf_networking_configuration.tfvars -tfstate networking_aks.tfstate -parallelism=30 -a apply

# Level3
## To deploy the private cluster configuration
rover -lz /tf/caf -var-file /tf/caf/examples/aks/204-private-cluster/aks_configuration.tfvars -tfstate aks-bicycle.tfstate -parallelism=30 -a apply

# Install Azure cli on jumphost (to be added to a cloud init script)
curl -sL https://azurecliprod.blob.core.windows.net/deb_install.sh | sudo bash
kubectl
helm

Attach the private dns to the hub for bastion to access aks

az login --identity
az aks get-credentials --name scmmaksakscluster001adbhshvthcrwmweirsit --resource-group scmm-rg-aks-rg1-ymihuyilmxuemrkknthppjgd --overwrite-existing --admin