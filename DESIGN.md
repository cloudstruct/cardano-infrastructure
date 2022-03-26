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
required.  These modules are used to provision common aspects of infrastructure  
and avoid duplicating effort and code already done and shared by others.

The code is config-driven with input provided as a YAML formatted document.  
This input is then used to template configuration for the  
[terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher) Terraform module which in turn  
passes data down to your configured code package.  If leveraging  
[cardano-node-ansible](https://github.com/cloudstruct/cardano-node-ansible) as your deployable code package then the same  
would apply. The behavior of the Ansible playbooks would be altered via the input  
provided in the YAML input document.

The [terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher) is used as a Terraform module  
within this repo and is described in more detail below in the Modules section.

The [cardano-node-ansible](https://github.com/cloudstruct/cardano-node-ansible) repository contains a code package deployable  
by the [terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher) Terraform module.  This is  
described in more detail in the below Modules section.

### Generic Cloud Workflow
* The [cardano-infrastructure](https://github.com/cloudstruct/cardano-infrastructure) code provisions the basic infrastructure and networking.
* It will then use [terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher) which\
provides required user-data input to the code execution package.
* The above input is passed to the Ansible playbook from [cardano-node-ansible](https://github.com/cloudstruct/cardano-node-ansible)\
where Ansible runs and produces a node and any required output.
* If enabled, the node will connect itself to a dynamically provisioned ETCD\
uster via the [ETCD Public Discovery Service](https://etcd.io/docs/latest/dev-internal/discovery_protocol/#public-discovery-service)
  * The ETCD cluster will act as a point of information that nodes will leverage\
to dynamically configure themselves relative to other deployed Cardano\
infrastructure resources.

### Generic Local Workflow
* The user will download and provide configuration to [cardano-node-ansible](https://github.com/cloudstruct/cardano-node-ansible)\
and then execute the ansible-playbook following directions in the [README](https://github.com/cloudstruct/cardano-node-ansible/blob/main/README.md)

### Network
When deploying to a cloud provider the default network model will consider a  
minimally viable configuration to limit cost. This means:
* Use of single availability zones within regions
* Direct private network peering in place of more advanced peering techniques
* Use of public IPs whit locked down firewall rules where it cuts costs

Additional configurations alternative network configurations are supported
but come at an additional cost to the user.  An example alternative could be  
Multi-tier subnetting including the use of NAT layers to avoid public IPs.

### Supported Regions
All available regions within a cloud provider will be supported. If you find a  
region you're looking to operate in is not supported please [Submit an Issue](https://github.com/cloudstruct/cardano-infrastructure/issues).

### External Nodes
External nodes will be supported via the YAML configuration. This means  
hard-coding the addresses/information to allow-list and prepare the external  
relay and all surrounding configuration outside of this repo.  

### IAM (Identity and Access Management)
Identity roles, policies, and instance principals are used where available and  
appropriate. The repo will attempt to avoid creating users and leveraging  
credentials wherever possible.  

### Encryption
All objects that can be will be encrypted. This will include but is not limited  
to object storage buckets, root disks, and block volumes.  

### Monitoring / Alerting
[Prometheus](https://prometheus.io/docs/introduction/overview/) is optionally used to monitor and
alert on server and service health wherever possible. Prometheus is an open-source  
systems monitoring and alerting toolkit.

In cloud providers containing one, this will mean leveraging managed Prometheus  
services. Where this service is not available, there may be optional Prometheus  
servers created.
* Alerts will initially be handled via Slack and Discord webhooks\
sending alerts to a channel set by the YAML configuration.
* Hosts will leverage [Node Exporter](https://prometheus.io/docs/guides/node-exporter/) for systems monitoring.
* Hosts will leverage exposed metrics provided within applications for\  
services-based monitoring.

### General host usage pattern
Wherever possible hosts are confined to running Docker and all services  
used within the host will run as docker containers. There are exceptions  
to this rule where it makes sense, for example:
* Required scheduled tasks (Cronjobs) will be run directly on the host
* Security hardening takes place at the host level

### User Controlled Secrets
This section details the eventual need to handle secrets that the automation  
will have no way to tell ahead of time.
* The initial implementation of this will be a configurable local file lookup for  
  the relative secrets.

### Service Discovery
[ETCD Public Discovery Service](https://etcd.io/docs/latest/dev-internal/discovery_protocol/#public-discovery-service) can optionally be configured when provisioning  
an infrastructure that requires service discovery.
* A UUID for this service can be provided or generated via Terraform
* A new node will reach out to the discovery service to check for existing nodes  
  and take appropriate action based on the provided settings.
* ETCD does come with considerations that add complexity:
  * The recommended size of an ETCD cluster is 7 or less nodes.
  * It is recommended to always keep an odd number of nodes for an ETCD cluster.
  * The automation will guide users towards these recommendations where possible.

## External CloudStruct Repositories
### terraform-cloud-userdata-launcher
[terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher) is a Terraform module that creates required  
infrastructure to launch a cloud 'instance' (Virtual Machine) and runs cloud-init  
based on input provided to this module. The product is configurable  
enough to provision quite literally anything that the user can code or script on  
an virtual machine instance.  

#### Prerequisites
* A cloud account
* An existing and functioning VPC with an implemented network layer
  * This is provided by [cardano-infrastructure](https://github.com/cloudstruct/cardano-infrastructure)
* A gzipped tarball containing a code package to execute that is retrievable by  
  the instance at boot-time via HTTP(S)

#### Design
This Terraform module will provide the following cloud objects with non-required   
features enabled via feature flags:
* Virtual Machine instance or Auto-Scaling Groups / Launch Templates
* Ability to create or consume security group by IDs and apply to created instances
* Auto-scaling Groups / Launch Templates
* Block Volumes / Backup-Policies
* External Facing IPs
* SSH Key Pairs
* Identity Roles and Policies
* Cloud-init functionality passed as instance user-data to execute a defined code  
  package (Packaged as a gzipped tarball)

### cardano-node-ansible
[cardano-node-ansible](https://github.com/cloudstruct/cardano-node-ansible) is a repo that contains flexible and modular Ansible code which produces a  
Cardano node of a defined type along with required operating system modifications.
* A release on this repo generates an artifact capable of being consumed by\
[terraform-cloud-userdata-launcher](https://github.com/cloudstruct/terraform-cloud-userdata-launcher).
* Generated artifacts are also capable of being run in a stand-alone capacity.

#### Prerequisites
A server (Bare Metal or VM) capable of running Ansible or having Ansible  
installed.

#### Design
* The Ansible code will provision Passive, Relay, and Block Producing nodes.  
  It will also continue to support any other Cardano node types required in the  
  future.
* A dynamically provisioned ETCD cluster is used for service discovery of\
other nodes

## External Terraform Modules
* [AWS VPC](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
* [AWS IAM](https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest)
* [AWS AutoScaling](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/latest)
* [AWS Security Group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)
* [CloudPossse AWS VPC Peering](https://registry.terraform.io/modules/cloudposse/vpc-peering/aws/latest)
