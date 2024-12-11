resource "aws_security_group" "ecs_to_efs" {
  count       = module.this.enabled ? 1 : 0
  name        = "${module.this.id}-ecs-to-efs"
  description = "Security group for ECS to EFS access"
  vpc_id      = var.vpc_id
  tags        = merge(module.this.tags, { "Name" : "${module.this.id}-ecs-to-efs" })
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_efs_egress_all" {
  count             = module.this.enabled ? 1 : 0
  security_group_id = aws_security_group.ecs_to_efs[0].id
  ip_protocol       = "-1" # -1 means all protocols
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress traffic"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_to_efs_tailscale" {
  count                        = module.this.enabled ? 1 : 0
  security_group_id            = aws_security_group.ecs_to_efs[0].id
  referenced_security_group_id = aws_security_group.tailscale[0].id
  from_port                    = local.port_efs_tailscale_state
  to_port                      = local.port_efs_tailscale_state
  ip_protocol                  = "tcp"
  description                  = "Allow ECS to access EFS from tailscale"
}

# resource "aws_vpc_security_group_ingress_rule" "ecs_to_efs_keycloak" {
#   count                        = module.this.enabled ? 1 : 0
#   security_group_id            = aws_security_group.ecs_to_efs[0].id
#   referenced_security_group_id = aws_security_group.keycloak[0].id
#   from_port                    = local.port_efs_tailscale_state
#   to_port                      = local.port_efs_tailscale_state
#   ip_protocol                  = "tcp"
#   description                  = "Allow ECS to access EFS from Keycloak"
# }


resource "aws_security_group" "tailscale" {
  count       = module.this.enabled ? 1 : 0
  name        = "${module.this.id}-tailscale-ingress"
  description = "Security group for tailscale ingress"
  vpc_id      = var.vpc_id
  tags        = merge(module.this.tags, { "Name" : "${module.this.id}-tailscale-ingress" })
}

resource "aws_vpc_security_group_egress_rule" "tailscale_egress_all" {
  count             = module.this.enabled ? 1 : 0
  security_group_id = aws_security_group.tailscale[0].id
  ip_protocol       = "-1" # -1 means all protocols
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress traffic"
}

resource "aws_vpc_security_group_ingress_rule" "tailscale_tailscale" {
  count             = module.this.enabled ? 1 : 0
  security_group_id = aws_security_group.tailscale[0].id
  from_port         = 41641
  to_port           = 41641
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all inbound tailscale"
}

resource "aws_security_group" "keycloak" {
  count       = module.this.enabled ? 1 : 0
  name        = "${module.this.id}-keycloak"
  description = "Security group for Keycloak"
  vpc_id      = var.vpc_id
  tags        = merge(module.this.tags, { "Name" : "${module.this.id}-keycloak" })
}

resource "aws_vpc_security_group_egress_rule" "keycloak_egress_all" {
  count             = module.this.enabled ? 1 : 0
  security_group_id = aws_security_group.keycloak[0].id
  ip_protocol       = "-1"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress traffic"
}

resource "aws_vpc_security_group_ingress_rule" "keycloak_tailscale_web" {
  count                        = module.this.enabled ? 1 : 0
  security_group_id            = aws_security_group.keycloak[0].id
  referenced_security_group_id = aws_security_group.tailscale[0].id
  from_port                    = local.port_keycloak_web
  to_port                      = local.port_keycloak_web
  ip_protocol                  = "tcp"
  description                  = "Allow tailscale ingress to keycloak management"
}

resource "aws_vpc_security_group_ingress_rule" "keycloak_tailscale_management" {
  count                        = module.this.enabled ? 1 : 0
  security_group_id            = aws_security_group.keycloak[0].id
  referenced_security_group_id = aws_security_group.tailscale[0].id
  from_port                    = local.port_keycloak_management
  to_port                      = local.port_keycloak_management
  ip_protocol                  = "tcp"
  description                  = "Allow tailscale ingress to keycloak management"
}

resource "aws_vpc_security_group_ingress_rule" "keycloak_http" {
  count             = length(local.alb_actual_cidrs)
  security_group_id = aws_security_group.keycloak[0].id
  cidr_ipv4         = local.alb_actual_cidrs[count.index]
  from_port         = local.port_keycloak_web
  to_port           = local.port_keycloak_web
  ip_protocol       = "tcp"
  description       = "Allow web ingress from ALB"
}

resource "aws_vpc_security_group_ingress_rule" "keycloak_cluster" {
  count             = length(local.alb_actual_cidrs)
  security_group_id = aws_security_group.keycloak[0].id
  cidr_ipv4         = local.alb_actual_cidrs[count.index]
  from_port         = local.port_keycloak_cluster
  to_port           = local.port_keycloak_cluster
  ip_protocol       = "tcp"
  description       = "Allow keycloak clustering on our local subnets"
}

resource "aws_vpc_security_group_ingress_rule" "keycloak_management" {
  count             = length(local.alb_actual_cidrs)
  security_group_id = aws_security_group.keycloak[0].id
  cidr_ipv4         = local.alb_actual_cidrs[count.index]
  from_port         = local.port_keycloak_management
  to_port           = local.port_keycloak_management
  ip_protocol       = "tcp"
  description       = "Allow management ingress from ALB for health checks"
}

resource "aws_vpc_security_group_ingress_rule" "keycloak_tailscale" {
  count             = module.this.enabled ? 1 : 0
  security_group_id = aws_security_group.keycloak[0].id
  from_port         = 41641
  to_port           = 41641
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all inbound tailscale"
}

resource "aws_security_group" "alb" {
  count       = module.label_alb.enabled ? 1 : 0
  name        = "${module.this.id}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
  tags        = merge(module.this.tags, { "Name" : "${module.this.id}-alb" })
}

resource "aws_vpc_security_group_egress_rule" "alb_egress_all" {
  count             = module.label_alb.enabled ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  ip_protocol       = "-1"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all egress traffic"
}
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  count             = module.label_alb.enabled ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTP ingress"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count             = module.label_alb.enabled ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow HTTPS ingress"
}
