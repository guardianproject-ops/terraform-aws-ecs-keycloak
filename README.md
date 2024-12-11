
<!-- markdownlint-disable -->
# terraform-aws-ecs-keycloak
<!-- markdownlint-restore -->

<!-- [![README Header][readme_header_img]][readme_header_link] -->

[![The Guardian][logo]][website]

<!--




  ** DO NOT EDIT THIS FILE
  **
  ** This file was automatically generated by the `build-harness`.
  ** 1) Make all changes to `README.yaml`
  ** 2) Run `make init` (you only need to do this once)
  ** 3) Run`make readme` to rebuild this file.
  **
  ** (We maintain HUNDREDS of open source projects. This is how we maintain our sanity.)
  **





-->

Terraform module for deploying Keycloak to AWS ECS w/ Fargate

---






It's 100% Open Source and licensed under the [GNU General Public License](LICENSE).









## Introduction


## Goals of this module

* Run a stable and reliable keycloak that doesn't need to scale beyond 100 users
* Trading cost for low effort on going maintenance
    * We want this stack to run without having to worry about OS patching or other issues ec2 instance related issues
    * We don't mind spending 20-40% more per month on fixed infra costs to achieve this
* Security with escape hatches
    * This keycloak will be our IdP or wide including acting as the IdP for AWS and Gitlab, where keycloak itself is hosted
    * So there must be documented escape hatches and break-glass procedures, these are documented in our internal docs.


## Architecture Decisions

* Run on ECS
    * Pros: only need to worry about containers, no need to manage instances or disks. 
    * Cons: bigger up-front dev time to develop this stack, wonky restrictions compared to normally running on an instance
    
    
* ECS containers are in public subnets, but locked down
    * We do this to avoid NAT Gateway charges. Security groups are tuned carefully. Bonus benefit is tailscale is faster as it doesn't use DERP.
    
    
* Keycloak behind ALB with self signed certs
    * ALB uses an ACM cert, keycloak exposes its HTTPS using a self-signed (generated here in terraform)
    * As per [AWS' ALB docs][alb1]:
    
    > The load balancer establishes TLS connections with the targets using certificates that you install on the targets. The load balancer does not validate these certificates. Therefore, you can use self-signed certificates or certificates that have expired. Because the load balancer, and its targets are in a virtual private cloud (VPC), traffic between the load balancer and the targets is authenticated at the packet level, so it is not at risk of man-in-the-middle attacks or spoofing even if the certificates on the targets are not valid. Traffic that leaves AWS will not have these same protections, and additional steps may be needed to secure traffic further.
    * This lets us tick the box of full transit encryption
    
    
* Keycloak admin and management API is not exposed to the public, but only over tailscale
    * This means to login and edit Realms, you must access Keycloak over tailscale
    * What happens when tailscale is down or tailscale+keycloak auth is broken? Refer to our documented break-glass procedures (TL;DR: break glass on AWS account, edit ALB target group to remove path 
    


### Some implementation notes

* Tailscalesd supports AWS SSM storage of state but multiple bugs make this not useable in the container image
    * ref: https://github.com/tailscale/tailscale/issues/13409
    * ref: https://github.com/tailscale/tailscale/issues/9513
    * Result: We mount an EFS volume into the tailscale container so it can store its state

* The tailscale auth-key is stored in AWS Secrets Manager, we use our [lambda that rotates auth keys][ts-rotate] to rotate the auth key regularly and bypass expiry. The auth-key (and the OIDC creds that power the lambda) are locked down such that all nodes that use the auth key must have the given tags.

* We use two long-running services: keycloak, and tailscale. We do this because it lets us horizontally scale keycloak with more container instances, while keeping a single internal-ingress.
* tailscale runs a in a single container and provides an internal tailnet reverse proxy to the keycloak upstream

[ts-rotate]: https://gitlab.com/guardianproject-ops/terraform-aws-lambda-secrets-manager-tailscale
[alb1]: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-group-routing-configuration



## Usage


**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

Also, because of a bug in the Terraform registry ([hashicorp/terraform#21417](https://github.com/hashicorp/terraform/issues/21417)),
the registry shows many of our inputs as required when in fact they are optional.
The table below correctly indicates which inputs are required.



See [examples/simple](./examples/simple)






<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | cloudposse/alb/aws | 2.2.0 |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | cloudposse/ecs-cluster/aws | 0.9.0 |
| <a name="module_keycloak"></a> [keycloak](#module\_keycloak) | guardianproject-ops/ecs-web-app/aws | 0.0.1 |
| <a name="module_keycloak_def"></a> [keycloak\_def](#module\_keycloak\_def) | cloudposse/ecs-container-definition/aws | 0.61.1 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | cloudposse/kms-key/aws | 0.12.2 |
| <a name="module_label_alb"></a> [label\_alb](#module\_label\_alb) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_keycloak"></a> [label\_keycloak](#module\_label\_keycloak) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_log_group_keycloak"></a> [label\_log\_group\_keycloak](#module\_label\_log\_group\_keycloak) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_log_group_postgres_init"></a> [label\_log\_group\_postgres\_init](#module\_label\_log\_group\_postgres\_init) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_log_group_secrets_init"></a> [label\_log\_group\_secrets\_init](#module\_label\_log\_group\_secrets\_init) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_log_group_tailscale"></a> [label\_log\_group\_tailscale](#module\_label\_log\_group\_tailscale) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_log_group_tailscale_init"></a> [label\_log\_group\_tailscale\_init](#module\_label\_log\_group\_tailscale\_init) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_ssm_params"></a> [label\_ssm\_params](#module\_label\_ssm\_params) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_ssm_params_tailscale"></a> [label\_ssm\_params\_tailscale](#module\_label\_ssm\_params\_tailscale) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_tailscale"></a> [label\_tailscale](#module\_label\_tailscale) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_ts"></a> [label\_ts](#module\_label\_ts) | cloudposse/label/null | 0.25.0 |
| <a name="module_postgres_init_sidecar"></a> [postgres\_init\_sidecar](#module\_postgres\_init\_sidecar) | cloudposse/ecs-container-definition/aws | 0.61.1 |
| <a name="module_secrets_init_sidecar"></a> [secrets\_init\_sidecar](#module\_secrets\_init\_sidecar) | cloudposse/ecs-container-definition/aws | 0.61.1 |
| <a name="module_tailscale_def"></a> [tailscale\_def](#module\_tailscale\_def) | cloudposse/ecs-container-definition/aws | 0.61.1 |
| <a name="module_tailscale_ingress"></a> [tailscale\_ingress](#module\_tailscale\_ingress) | cloudposse/ecs-alb-service-task/aws | 0.76.1 |
| <a name="module_tailscale_init_sidecar"></a> [tailscale\_init\_sidecar](#module\_tailscale\_init\_sidecar) | cloudposse/ecs-container-definition/aws | 0.61.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_ts_rotate"></a> [ts\_rotate](#module\_ts\_rotate) | guardianproject-ops/lambda-secrets-manager-tailscale/aws | 0.0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.keycloak](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.postgres_init](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.secrets_init](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.tailscale](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.tailscale_init](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_efs_access_point.tailscale_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.tailscale_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.tailscale_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_policy.keycloak_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.keycloak_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.tailscale_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.tailscale_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.keycloak_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.keycloak_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tailscale_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tailscale_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.keycloak_clustering](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.keycloak_clustering](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_secretsmanager_secret.authkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.authkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.authkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs_to_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.keycloak](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.tailscale](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_http_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_http_namespace) | resource |
| [aws_ssm_parameter.keycloak_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.keycloak_tls_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.keycloak_tls_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_security_group_egress_rule.alb_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ecs_to_efs_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.keycloak_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.tailscale_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ecs_to_efs_tailscale](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.keycloak_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.keycloak_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.keycloak_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.keycloak_tailscale](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.keycloak_tailscale_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.keycloak_tailscale_web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.tailscale_tailscale](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_password.keycloak_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.keycloak](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.keycloak](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.keycloak_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.keycloak_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.keycloak_task_rds_iam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.keycloak_task_s3_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.keycloak_task_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tailscale_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tailscale_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_alarms_sns_topics_arns"></a> [alarms\_sns\_topics\_arns](#input\_alarms\_sns\_topics\_arns) | A list of SNS topic arns that will be the actions for cloudwatch alarms | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_db_keycloak_host"></a> [db\_keycloak\_host](#input\_db\_keycloak\_host) | The postgresql host for keycloak | `string` | n/a | yes |
| <a name="input_db_keycloak_name"></a> [db\_keycloak\_name](#input\_db\_keycloak\_name) | The postgresql db name for keycloak | `string` | `"keycloak"` | no |
| <a name="input_db_keycloak_password"></a> [db\_keycloak\_password](#input\_db\_keycloak\_password) | The postgresql password for keycloak, when not using IAM authentication | `string` | `null` | no |
| <a name="input_db_keycloak_port"></a> [db\_keycloak\_port](#input\_db\_keycloak\_port) | The postgresql port number for keycloak | `number` | `5432` | no |
| <a name="input_db_keycloak_user"></a> [db\_keycloak\_user](#input\_db\_keycloak\_user) | The password for the keycloak account on the postgres instance | `string` | `"keycloak"` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | Whether or not to enable deletion protection on things that support it | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_java_opts_extra"></a> [java\_opts\_extra](#input\_java\_opts\_extra) | An optional list of arguments to add to JAVA\_OPTS | `list(string)` | `[]` | no |
| <a name="input_jvm_heap_max"></a> [jvm\_heap\_max](#input\_jvm\_heap\_max) | Maximum JVM heap size for Keycloak in MB. The default is 75% of the task\_memory | `number` | `null` | no |
| <a name="input_jvm_heap_min"></a> [jvm\_heap\_min](#input\_jvm\_heap\_min) | Minimum JVM heap size for Keycloak in MB | `number` | `512` | no |
| <a name="input_jvm_meta_max"></a> [jvm\_meta\_max](#input\_jvm\_meta\_max) | Maximum JVM meta space size for Keycloak in MB. | `number` | `256` | no |
| <a name="input_jvm_meta_min"></a> [jvm\_meta\_min](#input\_jvm\_meta\_min) | Minimum JVM meta space size for Keycloak in MB" | `number` | `128` | no |
| <a name="input_keycloak_acm_certificate_arn"></a> [keycloak\_acm\_certificate\_arn](#input\_keycloak\_acm\_certificate\_arn) | The arn for the ACM certificate used to provide TLS for your keycloak instance | `string` | n/a | yes |
| <a name="input_keycloak_admin_subdomain"></a> [keycloak\_admin\_subdomain](#input\_keycloak\_admin\_subdomain) | If you want foobar.$tailscale-domain.ts.net to be how you access keycloak admin, then set this variable to "foobar". By default the value is derived from context. | `string` | `null` | no |
| <a name="input_keycloak_admin_username"></a> [keycloak\_admin\_username](#input\_keycloak\_admin\_username) | The username for the temporary superuser used to bootstrap the instance | `string` | `"admin"` | no |
| <a name="input_keycloak_container_image"></a> [keycloak\_container\_image](#input\_keycloak\_container\_image) | The fully qualified container image for keycloak. | `string` | `"registry.gitlab.com/guardianproject-ops/docker-keycloak:26.0"` | no |
| <a name="input_keycloak_node_count"></a> [keycloak\_node\_count](#input\_keycloak\_node\_count) | The number of keycloak containers to run in clustering mode | `number` | `1` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The kms key ARN used for various purposes throughout the deployment, if not provided a kms key will be created. This is difficult to change later. | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_log_group_retention_in_days"></a> [log\_group\_retention\_in\_days](#input\_log\_group\_retention\_in\_days) | The number in days that cloudwatch logs will be retained. | `number` | `30` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_port_efs_tailscale_state"></a> [port\_efs\_tailscale\_state](#input\_port\_efs\_tailscale\_state) | The port number at which the tailscale state efs mount is available | `number` | `2049` | no |
| <a name="input_port_keycloak_cluster"></a> [port\_keycloak\_cluster](#input\_port\_keycloak\_cluster) | The port number used for Keycloak cluster communication | `number` | `7800` | no |
| <a name="input_port_keycloak_management"></a> [port\_keycloak\_management](#input\_port\_keycloak\_management) | The port number for Keycloak management interface | `number` | `9000` | no |
| <a name="input_port_keycloak_web"></a> [port\_keycloak\_web](#input\_port\_keycloak\_web) | The port number for Keycloak web interface | `number` | `8443` | no |
| <a name="input_port_tailscale_healthcheck"></a> [port\_tailscale\_healthcheck](#input\_port\_tailscale\_healthcheck) | The port number for Tailscale health check endpoint | `number` | `7801` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The ids for the private subnets that EFS will be deployed into | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | The cidr blocks for the public subnets that ECS will be deployed into | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | The ids for the public subnets that ECS will be deployed into | `list(string)` | n/a | yes |
| <a name="input_rds_iam_auth_enabled"></a> [rds\_iam\_auth\_enabled](#input\_rds\_iam\_auth\_enabled) | Whether or not IAM authentication to an RDS instance will be used. | `bool` | `true` | no |
| <a name="input_rds_init_keycloak_db"></a> [rds\_init\_keycloak\_db](#input\_rds\_init\_keycloak\_db) | If true then the postgresql database for keycloak will be initialized using the RDS master credentials | `bool` | `true` | no |
| <a name="input_rds_master_user_secret_arn"></a> [rds\_master\_user\_secret\_arn](#input\_rds\_master\_user\_secret\_arn) | If true then the postgresql database for keycloak will be initialized using the RDS master credentials | `string` | `null` | no |
| <a name="input_rds_master_username"></a> [rds\_master\_username](#input\_rds\_master\_username) | The username of the RDS master user | `string` | `""` | no |
| <a name="input_rds_resource_id"></a> [rds\_resource\_id](#input\_rds\_resource\_id) | The RDS resource id , used when rds iam auth is enabled | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tailscale_client_id"></a> [tailscale\_client\_id](#input\_tailscale\_client\_id) | The OIDC client id for tailscale that has permissions to create auth keys with the `tailscale_tags_keycloak` tags | `string` | n/a | yes |
| <a name="input_tailscale_client_secret"></a> [tailscale\_client\_secret](#input\_tailscale\_client\_secret) | The OIDC client secret paired with `tailscale_client_id` | `string` | n/a | yes |
| <a name="input_tailscale_container_image"></a> [tailscale\_container\_image](#input\_tailscale\_container\_image) | The fully qualified container image for tailscale. | `string` | `"ghcr.io/tailscale/tailscale:stable"` | no |
| <a name="input_tailscale_tags_keycloak"></a> [tailscale\_tags\_keycloak](#input\_tailscale\_tags\_keycloak) | The list of tags that will be assigned to tailscale node created by this stack. | `list(string)` | n/a | yes |
| <a name="input_tailscale_tailnet"></a> [tailscale\_tailnet](#input\_tailscale\_tailnet) | description = The tailnet domain (or "organization's domain") for your tailscale tailnet, this s found under Settings > General > Organization | `string` | n/a | yes |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | The number of CPU units used by the task. If unspecified, it will default to `container_cpu`. If using `FARGATE` launch type `task_cpu` must match supported memory values (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size) | `number` | n/a | yes |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | The amount of memory (in MiB) used by the task. If unspecified, it will default to `container_memory`. If using Fargate launch type `task_memory` must match supported cpu value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size) | `number` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id ECS will be deployed into | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb"></a> [alb](#output\_alb) | n/a |
| <a name="output_cloudwatch_log_group_arn_keycloak"></a> [cloudwatch\_log\_group\_arn\_keycloak](#output\_cloudwatch\_log\_group\_arn\_keycloak) | Cloudwatch log group ARN for keycloak |
| <a name="output_cloudwatch_log_group_arn_tailscale"></a> [cloudwatch\_log\_group\_arn\_tailscale](#output\_cloudwatch\_log\_group\_arn\_tailscale) | Cloudwatch log group ARN for tailscale |
| <a name="output_cloudwatch_log_group_keycloak"></a> [cloudwatch\_log\_group\_keycloak](#output\_cloudwatch\_log\_group\_keycloak) | All outputs from `aws_cloudwatch_log_group.keycloak` |
| <a name="output_cloudwatch_log_group_name_keycloak"></a> [cloudwatch\_log\_group\_name\_keycloak](#output\_cloudwatch\_log\_group\_name\_keycloak) | Cloudwatch log group name for keycloak |
| <a name="output_cloudwatch_log_group_name_tailscale"></a> [cloudwatch\_log\_group\_name\_tailscale](#output\_cloudwatch\_log\_group\_name\_tailscale) | Cloudwatch log group name for tailscale |
| <a name="output_cloudwatch_log_group_tailscale"></a> [cloudwatch\_log\_group\_tailscale](#output\_cloudwatch\_log\_group\_tailscale) | All outputs from `aws_cloudwatch_log_group.tailscale` |
| <a name="output_keycloak_password"></a> [keycloak\_password](#output\_keycloak\_password) | n/a |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The KMS Key ARN used for this deployment |
| <a name="output_secrets_manager_secret_authkey_arn"></a> [secrets\_manager\_secret\_authkey\_arn](#output\_secrets\_manager\_secret\_authkey\_arn) | n/a |
| <a name="output_secrets_manager_secret_authkey_id"></a> [secrets\_manager\_secret\_authkey\_id](#output\_secrets\_manager\_secret\_authkey\_id) | n/a |
<!-- markdownlint-restore -->




## Help

**Got a question?** We got answers.

File a GitLab [issue](https://gitlab.com/guardianproject-ops/terraform-aws-ecs-keycloak/-/issues), send us an [email][email] or join our [Matrix Community][matrix].

## Matrix Community

[![Matrix badge](https://img.shields.io/badge/Matrix-%23guardianproject%3Amatrix.org-blueviolet)][matrix]

Join our [Open Source Community][matrix] on Matrix. It's **FREE** for everyone!
This is the best place to talk shop, ask questions, solicit feedback, and work
together as a community to build on our open source code.

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://gitlab.com/guardianproject-ops/terraform-aws-ecs-keycloak/-/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or help out with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitLab
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2021-2024 The Guardian Project










## License

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

```text
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```






## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained by [The Guardian Project][website].

[![The Guardian Project][logo]][website]

We're a [collective of designers, developers, and ops][website] folk focused on useable
privacy and security with a focus on digital human rights and humanitarian projects.

Everything we do is 100% FOSS.

Follow us on [Mastodon][mastodon] or [twitter][twitter], [apply for a job][join], or
[partner with us][partner].

We offer [paid support][contact] on all of our projects.

Check out [our other DevOps projects][gitlab] or our [entire other set of
projects][nonops] related to privacy and security related software, or [hire
us][website] to get support with using our projects.


## Contributors

<!-- markdownlint-disable -->
|  [![Abel Luck][abelxluck_avatar]][abelxluck_homepage]<br/>[Abel Luck][abelxluck_homepage] |
|---|
<!-- markdownlint-restore -->

  [abelxluck_homepage]: https://gitlab.com/abelxluck

  [abelxluck_avatar]: https://secure.gravatar.com/avatar/0f605397e0ead93a68e1be26dc26481a?s=200&amp;d=identicon


<!-- markdownlint-disable -->
  [website]: https://guardianproject.info/?utm_source=gitlab&utm_medium=readme&utm_campaign=guardianproject-ops/terraform-aws-ecs-keycloak&utm_content=website
  [gitlab]: https://www.gitlab.com/guardianproject-ops
  [contact]: https://guardianproject.info/contact/
  [matrix]: https://matrix.to/#/%23guardianproject:matrix.org
  [readme_header_img]: https://gitlab.com/guardianproject/guardianprojectpublic/-/raw/master/Graphics/GuardianProject/pngs/logo-color-w256.png
  [readme_header_link]: https://guardianproject.info?utm_source=gitlab&utm_medium=readme&utm_campaign=guardianproject-ops/terraform-aws-ecs-keycloak&utm_content=readme_header_link
  [readme_commercial_support_img]: https://www.sr2.uk/readme/paid-support.png
  [readme_commercial_support_link]: https://www.sr2.uk/?utm_source=gitlab&utm_medium=readme&utm_campaign=guardianproject-ops/terraform-aws-ecs-keycloak&utm_content=readme_commercial_support_link
  [partner]: https://guardianproject.info/how-you-can-work-with-us/
  [nonops]: https://gitlab.com/guardianproject
  [mastodon]: https://social.librem.one/@guardianproject
  [twitter]: https://twitter.com/guardianproject
  [email]: mailto:support@guardianproject.info
  [join_email]: mailto:jobs@guardianproject.info
  [join]: https://guardianproject.info/contact/join/
  [logo_square]: https://assets.gitlab-static.net/uploads/-/system/group/avatar/3262938/guardianproject.png?width=88
  [logo]: https://gitlab.com/guardianproject/guardianprojectpublic/-/raw/master/Graphics/GuardianProject/pngs/logo-color-w256.png
  [logo_black]: https://gitlab.com/guardianproject/guardianprojectpublic/-/raw/master/Graphics/GuardianProject/pngs/logo-black-w256.png
  [cdr]: https://digiresilience.org
  [cdr-tech]: https://digiresilience.org/tech/
<!-- markdownlint-restore -->
