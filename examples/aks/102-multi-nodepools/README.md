# Multiple nodepools example

Deploys a Single AKS cluster with multiple nodepools in a VNET, within different subnets:
- Default system pool in aks_nodepool_system subnet
- 1 system pool in aks_nodepool_system1 subnet
- 1 user pool in aks_nodepool_user1 subnet

## Prerequisites




## Deploying this landing zone

Those are the minimum steps to allow a single devops engineer. 

If the subscription is shared across multiple devops engineer is it recommended each devops engineer use their own launchpad to avoid any conflicts between devops engineers. This can be achieved by setting a specific environment variable value. In the following script we use the environment value of "asia".

Note - the script bellow is not covering a shared environment multiple devops engineer can get access and collaborate (coming later)


### 1. Rover login, Environment & example set
Ensure the below is set prior to apply or destroy.
```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
export TF_VAR_environment=[YOUR_ENVIRONMENT]
# Set the folder name of this example
example=102-multi-nodepools
```
### 2. Apply Landingzones
```bash
# Add the lower dependency landingzones
# rover --clone-landingzones --clone-branch vnext13
rover --clone-folder /landingzones/launchpad --clone-branch vnext13
rover --clone-folder /landingzones/landingzone_caf_foundations --clone-branch vnext13
rover --clone-folder /landingzones/landingzone_networking --clone-branch vnext13

# Deploy the launchpad light to store the tfstates
rover -lz /tf/caf/landingzones/launchpad -a apply -launchpad -var location=southeastasia
## To deploy AKS some dependencies are required to like networking and some acounting, security and governance services are required.
rover -lz /tf/caf/landingzones/landingzone_caf_foundations/ -a apply -var-file /tf/caf/configuration/landingzone_caf_foundations.tfvars

# Deploy networking
rover -lz /tf/caf/landingzones/landingzone_networking/ \
      -tfstate ${example}_landingzone_networking.tfstate \
      -var-file /tf/caf/examples/${example}/landingzone_networking.tfvars \
      -a apply
# Run AKS landing zone deployment
rover -lz /tf/caf/ \
      -tfstate ${example}_landingzone_aks.tfstate \
      -var-file /tf/caf/examples/${example}/configuration.tfvars \
      -var tfstate_landingzone_networking=${example}_landingzone_networking.tfstate \
      -var landingzone_tag=${example}_landingzone_aks \
      -a apply
```
### 3. Destroy Landingzones
Have fun playing with the landing zone an once you are done, you can simply delete the deployment using:

```bash
rover -lz /tf/caf/ \
      -tfstate ${example}_landingzone_aks.tfstate \
      -var-file /tf/caf/examples/${example}/configuration.tfvars \
      -var tfstate_landingzone_networking=${example}_landingzone_networking.tfstate \
      -a destroy
rover -lz /tf/caf/landingzones/landingzone_networking/ \
      -tfstate ${example}_landingzone_networking.tfstate \
      -var-file /tf/caf/examples/${example}/landingzone_networking.tfvars \
      -a destroy

# Only destroy Foundation & Launchpad if you have no other Landingzones dependent on them.
rover -lz /tf/caf/landingzones/landingzone_caf_foundations/ -a destroy -var-file /tf/caf/configuration/landingzone_caf_foundations.tfvars

# to destroy the launchpad you need to conifrm you are connected with your user. If not reconnect with
rover login -t terraformdev.onmicrosoft.com -s [subscription GUID]

rover -lz /tf/caf/landingzones/launchpad -a destroy -launchpad
```

More details about this landing zone can also be found in the landing zone folder and its blueprints sub-folders.

## Contribute

Pull requests are welcome to evolve the framework and integrate new features.
