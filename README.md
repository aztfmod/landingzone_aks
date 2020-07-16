# Azure AKS landing zone


## Prerequisites


## Overall architecture

The following diagram shows the environment we are deploying for this POC:

![DMZ](../../_pictures/hub_spoke/hybrid-network-hub-spoke.png)

## Getting Started

To deploy a landing zone, use the execution environnement as described at the root of the landing zone repository.

## Deploying this landing zone

Those are the minimum steps to allow a single devops engineer. 

If the subscription is shared across multiple devops engineer is it recommended each devops engineer use their own launchpad to avoid any conflicts between devops engineers. This can be achieved by setting a specific environment variable value. In the following script we use the environment value of "asia".

Note - the script bellow is not covering a shared environment multiple devops engineer can get access and collaborate (coming later)

```bash
# Login the Azure subscription
rover login -t terraformdev.onmicrosoft.com -s [subscription GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
export TF_VAR_environment={Your Environment}
# Add the lower dependency landingzones
rover --clone-landingzones --clone-branch vnext13

# Deploy the launchpad light to store the tfstates
rover -lz /tf/caf/landingzones/launchpad -a apply -launchpad

## To deploy AKS some dependencies are required to like networking and some acounting, security and governance services are required.
rover -lz /tf/caf/landingzones/landingzone_caf_foundations/ -a apply -var-file /tf/caf/configuration/landingzone_caf_foundations.tfvars
rover -lz /tf/caf/landingzones/landingzone_networking/ -var-file /tf/caf/configuration/landingzone_networking.tfvars -a apply


# Run AKS landing zone deployment
rover -lz /tf/caf/ -tfstate landingzone_aks.tfstate -a apply
```

Have fun playing with the landing zone an once you are done, you can simply delete the deployment using:

```bash
rover -lz /tf/caf/ -tfstate landingzone_aks.tfstate -a destroy -auto-approve
rover -lz /tf/caf/landingzones/landingzone_networking/ -a destroy -var-file /tf/caf/configuration/landingzone_networking.tfvars
rover -lz /tf/caf/landingzones/landingzone_caf_foundations/ -a destroy -var-file /tf/caf/configuration/landingzone_caf_foundations.tfvars

# to destroy the launchpad you need to conifrm you are connected with your user. If not reconnect with
rover login -t terraformdev.onmicrosoft.com -s [subscription GUID]

rover -lz /tf/caf/landingzones/launchpad -a destroy -launchpad
```

More details about this landing zone can also be found in the landing zone folder and its blueprints sub-folders.

## Contribute

Pull requests are welcome to evolve the framework and integrate new features.
