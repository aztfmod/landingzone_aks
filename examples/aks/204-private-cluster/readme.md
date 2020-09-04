# Pre-requisites

mkdir -p /tf/caf/landingzones
git clone git@github.com:aztfmod/terraform-azurerm-caf-landingzone-modules.git /tf/caf/landingzones

## Launchpad with scenario 200 at minimum
Foundations



## Deploy isolated networking hub and spoke for AKS environment
rover -lz /tf/caf/landingzones/landingzones/caf_networking/ -var-file /tf/caf/examples/aks/204-private-cluster/caf_networking_configuration.tfvars -tfstate aks_networking.tfstate -parallelism=30 -a apply

# To deploy the private cluster configuration
rover -lz /tf/caf -var-file /tf/caf/examples/aks/204-private-cluster/aks_configuration.tfvars -tfstate aks.tfstate -parallelism=30 -a apply

# Install Azure cli on jumphost (to be added to a cloud init script)
curl -sL https://azurecliprod.blob.core.windows.net/deb_install.sh | sudo bash
kubectl
helm

az login --identity
az aks get-credentials --name scmmaksakscluster001adbhshvthcrwmweirsit --resource-group scmm-rg-aks-rg1-ymihuyilmxuemrkknthppjgd --overwrite-existing --admin