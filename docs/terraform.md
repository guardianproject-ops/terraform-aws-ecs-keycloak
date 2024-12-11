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
| [aws_network_interface.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
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
| <a name="output_alb_enis"></a> [alb\_enis](#output\_alb\_enis) | n/a |
| <a name="output_alb_enis_ips"></a> [alb\_enis\_ips](#output\_alb\_enis\_ips) | n/a |
| <a name="output_cloudwatch_log_group_arn_keycloak"></a> [cloudwatch\_log\_group\_arn\_keycloak](#output\_cloudwatch\_log\_group\_arn\_keycloak) | Cloudwatch log group ARN for keycloak |
| <a name="output_cloudwatch_log_group_arn_tailscale"></a> [cloudwatch\_log\_group\_arn\_tailscale](#output\_cloudwatch\_log\_group\_arn\_tailscale) | Cloudwatch log group ARN for tailscale |
| <a name="output_cloudwatch_log_group_keycloak"></a> [cloudwatch\_log\_group\_keycloak](#output\_cloudwatch\_log\_group\_keycloak) | All outputs from `aws_cloudwatch_log_group.keycloak` |
| <a name="output_cloudwatch_log_group_name_keycloak"></a> [cloudwatch\_log\_group\_name\_keycloak](#output\_cloudwatch\_log\_group\_name\_keycloak) | Cloudwatch log group name for keycloak |
| <a name="output_cloudwatch_log_group_name_tailscale"></a> [cloudwatch\_log\_group\_name\_tailscale](#output\_cloudwatch\_log\_group\_name\_tailscale) | Cloudwatch log group name for tailscale |
| <a name="output_cloudwatch_log_group_tailscale"></a> [cloudwatch\_log\_group\_tailscale](#output\_cloudwatch\_log\_group\_tailscale) | All outputs from `aws_cloudwatch_log_group.tailscale` |
| <a name="output_keycloak_password"></a> [keycloak\_password](#output\_keycloak\_password) | n/a |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The KMS Key ARN used for this deployment |
| <a name="output_secrets_manager_secret_authkey_arn"></a> [secrets\_manager\_secret\_authkey\_arn](#output\_secrets\_manager\_secret\_authkey\_arn) | n/a |
<!-- markdownlint-restore -->
