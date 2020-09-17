# Azure AKS landing zone


## Getting Started

To deploy a landing zone, use the execution environnement as described at the root of the landing zone repository.

## Deploy AKS (Level 3) Landing zone

Those are the minimum steps to allow a single devops engineer. 

If the subscription is shared across multiple devops engineer is it recommended each devops engineer use their own launchpad to avoid any conflicts between devops engineers. This can be achieved by setting a specific environment variable value. In the following script we use the environment value of "asia".

The scripts in example folders below can be used shared environment multiple devops engineer can get access and collaborate.

We are currently using <em>bicycle</em> environment to deploy Landing zones.

```
export TF_VAR_environment=bicycle
```
| AKS Landing Zone Example                                                                                              | Description                                                |
|---------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| [101-single-cluster](./examples/aks/101-single-cluster)| Provision single AKS cluster within open VNET |
| [102-multi-nodepools](./examples/aks/102-multi-nodepools)| Provision single AKS cluster with multiple nodepool within separate subnet (1 open VNET)|
| [103-multi-clusters](./examples/aks/103-multi-clusters)| Provision multiple AKS clusters in separate regions (different open VNETs)                     |
| [204-private-cluster](./examples/aks/204-private-cluster)| Provision private AKS clusters within private VNET with Hub & Spoke UDR to Azure Firewall |

## Deploy Application (Level 4) Landing zone
Deploys Applications Landing zone on top of an AKS Landing zone
| Application Landing Zone Example                                                                                              | Description                                                |
|---------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| [Flux](./examples/applications/flux)| Provision Flux helm charts on AKS LZ |



## Contribute

More details about this landing zone can also be found in the landing zone folder and its blueprints sub-folders.

Pull requests are welcome to evolve the framework and integrate new features.

