# ArgoCD

Deploys Applications on top of an AKS Landing zone

## Prerequisite
It is required to have an existing AKS Landing zone (level3) already provisioned prior to deploy Application Landing zone (level4) on top of.

## 1. Rover login, Environment & example set
Ensure the below is set prior to apply or destroy.
```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
export TF_VAR_environment=[YOUR_ENVIRONMENT]
# Set the folder name of this example
example=101-single-cluster
app_example=argocd
```
## 2. Apply Landing zone

Please make sure to change the cluster_key in /tf/caf/examples/applications/{app_example}/configuration.tfvars to choose the cluster to deploy this Application LZ to.

```bash
rover -lz /tf/caf/applications \
      -tfstate ${example}_dapr.tfstate \
      -var-file /tf/caf/examples/applications/${app_example}/configuration.tfvars \
      -var tags={example=\"${example}\"} \
      -a apply     
```
## 3. Destroy Landing zone
Have fun playing with the landing zone an once you are done, you can simply delete the deployment using:

```bash
rover -lz /tf/caf/applications \
      -tfstate ${example}_dapr.tfstate \
      -var-file /tf/caf/examples/applications/flux/configuration.tfvars \
      -var tags={example=\"${example}\"} \
      -a destroy -auto-approve
```

More details about this landing zone can also be found in the landing zone folder and its blueprints sub-folders.

## Contribute

Pull requests are welcome to evolve the framework and integrate new features.
