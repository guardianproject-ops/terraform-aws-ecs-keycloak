variable "vpc_id" {
  type        = string
  description = "The VPC id ECS will be deployed into"
}

#variable "vpc_cidr" {
#  type        = string
#  description = "The CIDR of the VPC"
#
#  validation {
#    condition     = can(regex("^(10\\.|192\\.168\\.)", var.vpc_cidr))
#    error_message = "VPC CIDR must start with either '10.' or '192.168.', because keycloak's clustering provider requires this."
#    # ref: http://www.jgroups.org/manual/html/protlist.html#Transport
#    # under SITE_LOCAL
#  }
#}

variable "public_subnet_ids" {
  type        = list(string)
  description = <<EOT
The ids for the public subnets that ECS will be deployed into
EOT
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = <<EOT
The cidr blocks for the public subnets that ECS will be deployed into
EOT
}

variable "private_subnet_ids" {
  type        = list(string)
  description = <<EOT
The ids for the private subnets that EFS will be deployed into
EOT
}


variable "log_group_retention_in_days" {
  default     = 30
  type        = number
  description = <<EOT
The number in days that cloudwatch logs will be retained.
EOT
}

variable "tailscale_container_image" {
  type        = string
  default     = "ghcr.io/tailscale/tailscale:stable"
  description = <<EOT
The fully qualified container image for tailscale.
EOT
}

variable "keycloak_container_image" {
  type        = string
  default     = "registry.gitlab.com/guardianproject-ops/docker-keycloak:26.0"
  description = <<EOT
The fully qualified container image for keycloak.
EOT
}

variable "kms_key_arn" {
  type        = string
  description = "The kms key ARN used for various purposes throughout the deployment, if not provided a kms key will be created. This is difficult to change later."
  default     = null
}


variable "keycloak_admin_username" {
  type        = string
  description = "The username for the temporary superuser used to bootstrap the instance"
  default     = "admin"
}

variable "keycloak_node_count" {
  type        = number
  description = "The number of keycloak containers to run in clustering mode"
  default     = 1
}

variable "keycloak_admin_subdomain" {
  type        = string
  default     = null
  description = <<EOT
If you want foobar.$tailscale-domain.ts.net to be how you access keycloak admin, then set this variable to "foobar". By default the value is derived from context.
EOT
}

variable "java_opts_extra" {
  type        = list(string)
  default     = []
  description = <<EOT
An optional list of arguments to add to JAVA_OPTS
EOT
}

variable "jvm_heap_min" {
  description = <<EOT
Minimum JVM heap size for Keycloak in MB
  EOT
  type        = number
  default     = 512
}

variable "jvm_heap_max" {
  description = <<EOT
Maximum JVM heap size for Keycloak in MB. The default is 75% of the task_memory
EOT
  type        = number
  default     = null
}

variable "jvm_meta_min" {
  description = <<EOT
Minimum JVM meta space size for Keycloak in MB"
EOT
  type        = number
  default     = 128
}

variable "jvm_meta_max" {
  description = <<EOT
 Maximum JVM meta space size for Keycloak in MB.
EOT
  type        = number
  default     = 256
}

variable "tailscale_tags_keycloak" {
  type = list(string)

  description = "The list of tags that will be assigned to tailscale node created by this stack."
  validation {
    condition = alltrue([
      for tag in var.tailscale_tags_keycloak : can(regex("^tag:", tag))
    ])
    error_message = "max_allocated_storage: Each tag in tailscale_tags_keycloak must start with 'tag:'"
  }
}


variable "tailscale_tailnet" {
  type = string

  description = <<EOT
  description = The tailnet domain (or "organization's domain") for your tailscale tailnet, this s found under Settings > General > Organization
EOT
}

variable "tailscale_client_id" {
  type        = string
  sensitive   = true
  description = "The OIDC client id for tailscale that has permissions to create auth keys with the `tailscale_tags_keycloak` tags"
}

variable "tailscale_client_secret" {
  type        = string
  sensitive   = true
  description = "The OIDC client secret paired with `tailscale_client_id`"
}

variable "task_cpu" {
  type        = number
  description = "The number of CPU units used by the task. If unspecified, it will default to `container_cpu`. If using `FARGATE` launch type `task_cpu` must match supported memory values (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)"
}

variable "task_memory" {
  type        = number
  description = "The amount of memory (in MiB) used by the task. If unspecified, it will default to `container_memory`. If using Fargate launch type `task_memory` must match supported cpu value (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size)"
}

variable "keycloak_acm_certificate_arn" {
  type        = string
  description = <<EOT
The arn for the ACM certificate used to provide TLS for your keycloak instance
EOT
}

variable "rds_iam_auth_enabled" {
  type        = bool
  default     = true
  description = <<EOT
Whether or not IAM authentication to an RDS instance will be used.
EOT
}

variable "rds_resource_id" {
  type        = string
  default     = null
  description = <<EOT
The RDS resource id , used when rds iam auth is enabled
EOT
  validation {
    condition     = var.rds_iam_auth_enabled == true ? var.rds_resource_id != null : true
    error_message = "rds_resource_id: When using RDS IAM authentication, you must pass var.rds_resource_id"
  }
}

variable "rds_init_keycloak_db" {
  type        = bool
  default     = true
  description = <<EOT
If true then the postgresql database for keycloak will be initialized using the RDS master credentials
EOT
}

variable "rds_master_username" {
  type        = string
  default     = ""
  description = <<EOT
The username of the RDS master user
EOT

  validation {
    condition     = var.rds_init_keycloak_db == true ? length(var.rds_master_username) > 1 : true
    error_message = "When initialzing the RDS instance with a keycloak user and db, you must specific the var.rds_master_username"
  }
}

variable "rds_master_user_secret_arn" {
  type        = string
  default     = null
  description = <<EOT
If true then the postgresql database for keycloak will be initialized using the RDS master credentials
EOT

  validation {
    condition     = var.rds_init_keycloak_db == true ? var.rds_master_user_secret_arn != null : true
    error_message = "When initialzing the RDS instance with a keycloak user and db, you must specific the var.rds_master_user_secret_arn"
  }
}


variable "db_keycloak_user" {
  type        = string
  default     = "keycloak"
  description = "The password for the keycloak account on the postgres instance"
}

variable "db_keycloak_name" {
  type        = string
  default     = "keycloak"
  description = <<EOT
The postgresql db name for keycloak
EOT
}
variable "db_keycloak_port" {
  type        = number
  default     = 5432
  description = <<EOT
The postgresql port number for keycloak
EOT
}

variable "db_keycloak_host" {
  type        = string
  description = <<EOT
The postgresql host for keycloak
EOT
}

variable "db_keycloak_password" {
  type        = string
  default     = null
  description = <<EOT
The postgresql password for keycloak, when not using IAM authentication
EOT
}


variable "port_efs_tailscale_state" {
  type        = number
  default     = 2049
  description = <<EOT
The port number at which the tailscale state efs mount is available
EOT
}

variable "port_keycloak_cluster" {
  type        = number
  default     = 7800
  description = <<EOT
The port number used for Keycloak cluster communication
EOT
}

variable "port_keycloak_web" {
  type        = number
  default     = 8443
  description = <<EOT
The port number for Keycloak web interface
EOT
}

variable "port_keycloak_management" {
  type        = number
  default     = 9000
  description = <<EOT
The port number for Keycloak management interface
EOT
}

variable "port_tailscale_healthcheck" {
  type        = number
  default     = 7801
  description = <<EOT
The port number for Tailscale health check endpoint
EOT
}

variable "deletion_protection_enabled" {
  type        = bool
  description = "Whether or not to enable deletion protection on things that support it"
  default     = true
}

variable "alarms_sns_topics_arns" {
  type        = list(string)
  default     = []
  description = "A list of SNS topic arns that will be the actions for cloudwatch alarms"
}

variable "exec_enabled" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  default     = false
}
