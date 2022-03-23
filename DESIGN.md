# Cardano Infrastructure Repository Design
## Goals
* Provide a reliable open-source project that anyone can leverage to build their\
cardano infrastructure on-premise or in the cloud.
* Create automation that builds repeatable, maintainable, and secure Cardano\
infrastructure.
* Encourage community interaction and feedback to use in improving the automation.

## Tools
The following open-source tools are used to execute the code in this repository  
and a brief explanation of why we chose them:
* [Terraform](https://www.terraform.io/intro)
  * Terraform is an industry leading tool in rapidly provisioning cloud based\
infrastructure.
  * Terraform removes the burden of tracking the myriad of resources required\
to build infrastructure.
  * With its [Directed Acyclic Graph](https://www.terraform.io/internals/graph) Terraform makes it easy to ensure\
resources are provisioned in the correct order and leverage the output of one\
resource as the input to another.
* [Ansible](https://www.ansible.com/overview/how-ansible-works)
  * Ansible is an extremely accessible automation framework that simplifies\
repetitive, complex, and inter-dependent tasks.
  * With an extensive [module support](https://docs.ansible.com/ansible/latest/collections/index_module.html) Ansible abstracts API and System interactions\
so we can focus on what the automation does and not how it does it.
  * Similar to Terraform, Ansible allows us to avoid reinventing the wheel and\
leverage existing and well maintained roles.

## Main
[cardano-infrastructure](https://github.com/cloudstruct/cardano-infrastructure) is a Terraform project which when forked or cloned  
and applied with a valid YAML config produces a functioning, secure, and  
maintainable Cardano deployment.  

`Cardano Deployment` is defined as any combination of Cardano nodes  
(Passive, Relay, Block Producer) as configured in the YAML input.  

The repo will pull in common well maintained open-source Terraform modules as  
required.  

The code is config-driven with configuration supplied via YAML in the documented  
and exemplified format. `config-driven` in this context means that within a given release of  
[terraform-cloud-cardano-stake-pool](https://github.com/cloudstruct/terraform-cloud-cardano-stake-pool), no Terraform HCL code should require  
modification.  

### Network
The network model will consider security as its top-level objective with cost as  
its secondary. There will be places where a non-optimal, yet still perfectly  
secure configuration, will be noticed. This can almost always be explained with  
'cost' as the reason.  
* The repo will support secure network architecture relative to the cloud\
provider being used.
* Direct VPC peering will be maintained between VPCs as needed/appropriate.
* Security groups will be locked down to white-list only as provided by YAML\
config

### Supported Regions / Providers
Within the repo, we will create a provider for every supported region. As regions  
continue to grow they can be added via a simple merge request to become supported.  
Providers can then be included in the modules and leveraged if the YAML config  
includes them.  

### External Nodes
External nodes will be supported via the YAML configuration. This means  
hard-coding the addresses/information to white-list and prepare the external  
relay and all surrounding configuration outside of this repo.  

### IAM (Identity and Access Management)
Identity roles, policies, and instance principals are used where available and  
appropriate. The repo will attempt to avoid creating users and leveraging  
credentials wherever possible.  

### Encryption
All objects that can be will be encrypted. This will include but is not limited  
to object storage buckets, root disks, and block volumes.  

### Monitoring / Notifications
Prometheus is used to monitor server and service health wherever possible.  
In cloud providers containing one, this will mean leveraging managed Prometheus  
services. Where this service is not available, there may be optional Prometheus  
servers created.
* Notifications will initially be handled via slack and discord webhooks\
sending alerts to a channel set by the YAML configuration.
* Hosts will leverage `node-exporter` for systems monitoring.
* Hosts will leverage exposed metrics provided within applications for  
  services-based monitoring.

### General host usage pattern
Wherever possible hosts are confined to running Docker and all services  
used within the host will run as docker containers.  

### User Controlled Secrets
This section details the eventual need to handle secrets that the automation  
will have no way to tell ahead of time.
* The initial implementation of this will be a configurable local file lookup for  
  the relative secrets.
* A forward-looking feature could see us leveraging cloud provider services like\
AWS Secrets Manager to pull secrets from, but this would still require staging\
of secrets into the secret service by the user.

### Service Discovery
[ETCD Public Discovery Service](https://etcd.io/docs/latest/dev-internal/discovery_protocol/#public-discovery-service) can optionally be configured when provisioning  
an infrastructure that requires service discovery.
* A UUID for this service can be provided or generated via Terraform
* A new node will reach out to the discovery service to check for existing nodes  
  and take appropriate action based on the provided settings.
* ETCD will run on each provisioned node when enabled

## External Repositories
### terraform-cloud-userdata-launcher
[terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher) is a Terraform module that creates required  
infrastructure to launch a cloud 'instance' (Virtual Machine) and runs cloud-init  
based on input provided to this module. The product is configurable  
enough to provision quite literally anything that the user can code or script on  
an EC2 instance.  

#### Prerequisites
* A cloud account
* An existing and functioning VPC with an implemented network layer
* A gzipped tarball containing a code package to execute that is retrievable by  
  the instance at boot-time via HTTP(S)

#### Design
This Terraform module will provide the following cloud objects with non-required   
features enabled via feature flags:
* Virtual Machine instance
* Ability to take in security group IDs and apply to created instances
* Auto-scaling Groups / Launch Templates
* Block Volumes / Backup-Policies
* External Facing IPs
* SSH Key Pairs
* Identity Roles and Policies
* Cloud-init functionality passed as instance user-data to execute a defined code  
  package (Packaged as a gzipped tarball)

### cardano-node-ansible
[cardano-node-ansible](https://github.com/cloudstruct/cardano-node-ansible) is a repo that contains flexible and modular ansible code which produces a  
Cardano node of a defined type along with required operating system modifications.
* The repo generates artifacts consumed by [terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher).
* Generated artifacts are also capable of being run in a stand-alone capacity.

#### Prerequisites
A server (Bare Metal or VM) capable of running Ansible or having Ansible  
installed.

#### Design
* The ansible code will provision Passive, Relay, and Block Producing nodes.  
  It will also continue to support any other Cardano node types required in the  
  future.
* A dynamically provisioned ETCD cluster is used for service discovery of\
other nodes
* The workflow would be:
  * Create a TF module instantiation of [terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher) which\
provides required user-data input.
  * The above input is passed to this Ansible playbook.
  * Ansible runs and produces a node and any required output.
  * If enabled, the node will connect itself to a dynamically provisioned ETCD\
cluster via the [ETCD Public Discovery Service](https://etcd.io/docs/latest/dev-internal/discovery_protocol/#public-discovery-service)
  * The ETCD cluster will act as a point of information that nodes will leverage\
to dynamically configure themselves relative to other deployed Cardano\
infrastructure resources.
