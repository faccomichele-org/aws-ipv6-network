locals {
  environment  = split("_", terraform.workspace)[0]
  aws_region   = split("_", terraform.workspace)[1]
  project_name = var.tags["Project"] != null ? var.tags["Project"] : "unknown"
  selected_azs = slice(data.aws_availability_zones.available.names, 0, 3)

  flow_logs_retention_days = local.environment == "prod" ? 365 : 7
  flow_logs_transition_ia_days = local.environment == "prod" ? 30 : 0
  flow_logs_transition_glacier_days = local.environment == "prod" ? 90 : 0

  public_subnets = {
    for index, az in local.selected_azs : az => {
      az              = az
      ipv6_cidr_block = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, index)
    }
  }

  private_subnets = {
    for index, az in local.selected_azs : az => {
      az              = az
      ipv6_cidr_block = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, index + 3)
    }
  }

  tags = merge(var.tags, {
    Project = local.project_name
  })

  logging_bucket_name = "${local.project_name}-flow-logs-${local.environment}-${local.aws_region}-${data.aws_caller_identity.current.account_id}"

  flow_log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path} $${ecs-cluster-arn} $${ecs-cluster-name} $${ecs-service-name} $${ecs-task-arn} $${ecs-task-id} $${ecs-task-definition-arn} $${ecs-container-instance-arn} $${ecs-container-instance-id} $${ecs-container-id} $${ecs-second-container-id} $${reject-reason} $${resource-id} $${encryption-status} $${instance-tag} $${instance-tag-2} $${interface-tag} $${interface-tag-2} $${asg-tag} $${asg-tag-2} $${interface-type} $${next-hop-interface-id} $${next-hop-subnet-id} $${next-hop-az-id} $${next-hop-vpc-id} $${next-hop-interface-type}"

  athena_database_name  = "${replace(replace(lower(local.project_name), "-", "_"), ".", "_")}_logging"
  athena_workgroup_name = "${replace(replace(lower(local.project_name), "_", "-"), ".", "-")}-logging"
}
