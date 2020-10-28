# Single Cluster example

Deploys a Single AKS cluster in a virtual network.

### 1. Rover login, Environment & example set

Ensure the below is set prior to apply or destroy.

```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
environment=[YOUR_ENVIRONMENT]
# Set the folder name of this example
example=102-multi-nodepools
```
### 2. Deploy the dependency landingzones


### 3. Apply landingzones

# Run AKS landing zone deployment

```bash
rover -lz /tf/caf/ \
  -tfstate landingzone_aks.tfstate \
  -var-folder /tf/caf/examples/aks/${example} \
  -var tags={example=\"${example}\"} \
  -env ${environment} \
  -level level3 \
  -a apply
```

### 3. Destroy Landing zones

Have fun playing with the landing zone an once you are done, you can simply delete the deployment using:

```bash
rover -lz /tf/caf/ \
  -tfstate landingzone_aks.tfstate \
  -var-folder /tf/caf/examples/aks/${example} \
  -var tags={example=\"${example}\"} \
  -env ${environment} \
  -level level3 \
  -a destroy -auto-approve

```