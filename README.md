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

# Add the lower dependency landingzones
rover --clone-landingzones --clone-branch vnext13

# Deploy the launchpad light to store the tfstates
rover -lz /tf/caf/landingzones/launchpad -a apply -launchpad -env asia

## To deploy AKS some dependencies are required to like networking and some acounting, security and governance services are required.
rover -lz /tf/caf/landingzones/landingzone_caf_foundations/ -a apply -var-file /tf/caf/configuration/landingzone_caf_foundations.tfvars -env asia
rover -lz /tf/caf/landingzones/landingzone_hub_spoke/ -a apply -var-file /tf/caf/configuration/landingzone_hub_spoke.tfvars -env asia -tfstate landingzone_networking.tfstate


```

Review the configuration and if you are ok with it, deploy it by running:

```bash
rover /tf/caf/landingzones/landingzone_hub_spoke apply
```

Have fun playing with the landing zone an once you are done, you can simply delete the deployment using:

```bash
rover /tf/caf/landingzones/landingzone_hub_spoke destroy
```

More details about this landing zone can also be found in the landing zone folder and its blueprints sub-folders.

## Contribute

Pull requests are welcome to evolve the framework and integrate new features.
