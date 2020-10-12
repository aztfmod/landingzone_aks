
```bash

# Deploy the launchpad
rover -lz /tf/caf/landingzones/caf_launchpad -launchpad -var-file /tf/caf/examples/104-private-cluster/asia/new-launchpad.tfvars -w tfstate -a apply

# Deploy the foundations (light)
rover -lz /tf/caf/landingzones/caf_foundations -a apply -w tfstate

# Deploy the networking landing zone

```