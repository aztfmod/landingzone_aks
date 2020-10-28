# Multi Clusters example

Deploys Multiple Clusters within different VNETs:
- 1 in Southeast Asia - Availability Zone [1] enabled for Default System Pool & User Pool1
- 1 in East Asia - no Availability Zone

### 1. Rover login, Environment & example set
Ensure the below is set prior to apply or destroy.
```bash
# Login the Azure subscription
rover login -t [TENANT_ID/TENANT_NAME] -s [SUBSCRIPTION_GUID]
# Environment is needed to be defined, otherwise the below LZs will land into sandpit which someone else is working on
export environment=[YOUR_ENVIRONMENT]

```

```bash
# Set the folder name of this example
example=103-multi-clusters

# Deploy networking
rover -lz /tf/caf/public/landingzones/caf_networking/ \
  -tfstate networking_spoke_aks.tfstate \
  -var-folder /tf/caf/examples/1-dependencies/networking/spoke_aks/multi_region \
  -env ${environment} \
  -level level3 \
  -a [plan|apply]
# Run AKS landing zone deployment

rover -lz /tf/caf/ \
  -tfstate ${example}_landingzone_aks.tfstate \
  -var-folder /tf/caf/examples/aks/${example} \
  -var tags={example=\"${example}\"} \
  -level level3 \
  -a [plan|apply]
```

