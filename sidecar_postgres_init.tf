module "postgres_init_sidecar" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.1"

  count = module.this.enabled && var.rds_init_keycloak_db ? 1 : 0

  container_name  = "postgres-init"
  container_image = "amazonlinux:latest"
  essential       = false

  #echo "Resetting database"
  #PGPASSWORD=$RDS_MASTER_PASSWORD psql -h $RDS_ENDPOINT -p $RDS_PORT \
  #  "sslmode=require dbname=postgres user=$RDS_MASTER_USERNAME" <<-EOF
  #  DROP DATABASE IF EXISTS "$RDS_KEYCLOAK_DB_NAME";
  #  DROP USER IF EXISTS "$RDS_KEYCLOAK_USERNAME";
  #EOF
  command = [
    "/bin/bash",
    "-c",
    <<-EOT
    set -ex -o pipefail

    echo "Postgres init container starting"
    echo "Installing dependencies..."
    yum update -y
    yum install -y postgresql16

    echo "Create keycloak user and associated database"
    echo "Note: Any message indicating that the user or the database already exists is informational and can be safely ignored."
    PGPASSWORD=$RDS_MASTER_PASSWORD psql -h $RDS_ENDPOINT -p $RDS_PORT \
      "sslmode=require dbname=postgres user=$RDS_MASTER_USERNAME" <<-EOF
        CREATE DATABASE "$RDS_KEYCLOAK_DB_NAME";
    EOF

    PGPASSWORD=$RDS_MASTER_PASSWORD psql -h $RDS_ENDPOINT -p $RDS_PORT \
      "sslmode=require dbname=$RDS_KEYCLOAK_DB_NAME user=$RDS_MASTER_USERNAME" <<-EOF
        CREATE USER "$RDS_KEYCLOAK_USERNAME" WITH LOGIN NOSUPERUSER CREATEDB CREATEROLE INHERIT;
        GRANT ALL PRIVILEGES ON DATABASE "$RDS_KEYCLOAK_DB_NAME" TO "$RDS_KEYCLOAK_USERNAME";
        GRANT ALL ON SCHEMA public TO "$RDS_KEYCLOAK_USERNAME";
        GRANT rds_iam TO "$RDS_KEYCLOAK_USERNAME";
    EOF
    EOT
  ]

  # This is a bunch of stuff that was useful for troubleshooting, leaving it here for now
  #
  # yum install -y  awscli-2
  #   PGPASSWORD=$RDS_MASTER_PASSWORD psql -h $RDS_ENDPOINT -p $RDS_PORT \
  #     "sslmode=require dbname=$RDS_KEYCLOAK_DB_NAME user=$RDS_MASTER_USERNAME" <<-EOF
  #       SELECT r.rolname,
  #       ARRAY(SELECT b.rolname
  #       FROM pg_catalog.pg_auth_members m
  #       JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
  #       WHERE m.member = r.oid) memberof
  #       FROM pg_catalog.pg_roles r
  #       WHERE r.rolname !~ '^pg_'
  #       ORDER BY 1;
  #   EOF
  #   echo testing role
  #   aws sts get-caller-identity
  #   echo "Testing iam auth"
  #   export PGPASSWORD="$(aws rds generate-db-auth-token --hostname $RDS_ENDPOINT --port $RDS_PORT --username $RDS_KEYCLOAK_USERNAME)"
  #   psql -h $RDS_ENDPOINT -p $RDS_PORT "sslmode=require dbname=$RDS_KEYCLOAK_DB_NAME user=$RDS_KEYCLOAK_USERNAME" <<-EOF
  #       SELECT * FROM pg_catalog.pg_tables;
  #   EOF

  secrets = [
    {
      name      = "RDS_MASTER_PASSWORD"
      valueFrom = "${local.rds_master_user_secret_arn}:password::"
    }
  ]
  environment = [
    {
      name  = "RDS_ENDPOINT"
      value = local.db_addr
    },
    {
      name  = "RDS_PORT"
      value = local.db_port
    },
    {
      name  = "RDS_MASTER_USERNAME"
      value = local.rds_master_username
    },
    {
      name  = "RDS_KEYCLOAK_DB_NAME"
      value = var.db_keycloak_name
    },
    {
      name  = "RDS_KEYCLOAK_USERNAME"
      value = var.db_keycloak_user
    }
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = local.region
      "awslogs-group"         = aws_cloudwatch_log_group.postgres_init[0].name
      "awslogs-region"        = local.region
      "awslogs-stream-prefix" = "ecs"
    }
  }
}
