# aws-ipv6-network

Terraform templates to deploy an AWS VPC designed for IPv6-native workloads:

- AWS-assigned IPv6 CIDR block on the VPC
- 3 public + 3 private IPv6-native subnets (`/64`, minimal IPv6 subnet size in AWS)
- 3 dual-stack service subnets (`/26` IPv4 + `/64` IPv6), one per availability zone
- Dedicated route table for public, private, and services tiers
- Public internet routing through an Internet Gateway
- Private egress-only internet routing through an Egress-Only Internet Gateway
- Services egress-only IPv6 internet routing through an Egress-Only Internet Gateway, with no IPv4 internet route or NAT Gateway
- Dedicated NACL per tier with:
  - free VPC-internal communications
  - internet egress limited to HTTPS (`443`) and SSH (`22`)
  - ephemeral return traffic rules
  - internet ingress HTTPS only on public tier (+ ephemeral return traffic)
- Default security group locked down (no rules)
- Default network ACL locked down (no rules)
- VPC Flow Logs to S3 (Parquet, per-hour hive-compatible partitions) with the full custom field set including ECS task metadata (`ecs-*`), resource tags (`instance-tag`, `interface-tag`, `asg-tag`), `traffic-path`, `encryption-status`, `reject-reason`, and `next-hop-*` fields
- Route 53 Resolver query logging (VPC DNS logs) to the same S3 bucket
- Athena workgroup + Glue database with pre-built `vpc_flow_logs` and `resolver_query_logs` tables (Parquet / JSON serde, hive-compatible partitions)
- Optional GuardDuty detector (disabled by default)

> Note: AWS requires an IPv4 CIDR on the VPC itself. The default `/24` VPC CIDR provides three `/26` IPv4 ranges for the dual-stack service subnets; use a VPC CIDR with a `/16` through `/24` prefix. Public and private subnets remain IPv6-native and do not receive IPv4 CIDRs.

Service subnets have IPv4 and IPv6 addresses for workloads that require both address families. Their route table has an IPv6 `::/0` route through the egress-only internet gateway, but no IPv4 `0.0.0.0/0` route. IPv4 traffic is limited to automatic VPC-local routing, so no NAT Gateway is provisioned.

## Usage

```hcl
module "ipv6_network" {
  source = "./"

  tags = {
    Project = "example-ipv6-network"
  }
}
```

The environment and region are derived from the Terraform workspace name (`<environment>_<region>`, e.g. `dev_eu-west-1`).

## Logging

All logs are stored in a single S3 bucket (SSE-S3 encrypted, public access blocked, lifecycle: `STANDARD_IA` after 30 days, `GLACIER_IR` after 90 days, expiration after 365 days).

| Variable | Default | Description |
| --- | --- | --- |
| `enable_flow_logs` | `true` | VPC Flow Logs to S3 in Parquet format |
| `enable_resolver_query_logs` | `true` | Route 53 Resolver query logs |
| `enable_guardduty` | `false` | GuardDuty detector (account-level resource) |
| `enable_athena` | `true` | Athena workgroup + Glue tables |
| `logging_bucket_name` | `null` | Override the generated bucket name |
| `flow_logs_retention_days` | `365` | S3 object expiration |
| `flow_logs_transition_ia_days` | `30` | Transition to `STANDARD_IA` |
| `flow_logs_transition_glacier_days` | `90` | Transition to `GLACIER_IR` |
| `flow_logs_tag_keys` | `{instance=[Name], network-interface=[Name], auto-scaling-group=[Name]}` | Tag keys included in flow log records |

### Querying flow logs

Run `MSCK REPAIR TABLE vpc_flow_logs` (and `resolver_query_logs`) once after the first logs are delivered to load the hive-compatible partitions, then query from the workgroup:

```sql
SELECT srcaddr, dstaddr, dstport, action, flow_direction, ecs_service_name
FROM vpc_flow_logs
WHERE action = 'REJECT' AND year = '2026' AND month = '08'
LIMIT 100;
```

### Caveats

- **ECS metadata fields** (`ecs-*`) are only populated for ECS tasks running in `awsvpc` network mode.
- **Tag fields** (`instance-tag`, `asg-tag`, ...) require the auto-created "Flow Logs Amazon EC2 Tags" service-linked role. ASG tag values may be stale without an enabled CloudTrail trail in the account. The tag fields in the log format (and the corresponding Athena table columns) are generated from `flow_logs_tag_keys`: one key per resource type adds `<resource>-tag`, a second key adds `<resource>-tag-2`.
- Flow log metadata fields are best-effort and may be missing (`-`) for traffic not associated with a tagged resource, ECS task, or supported ENI type.
- **GuardDuty** is account-scoped, not VPC-scoped; creating it via this module in multiple workspaces will target the same account-level detector.
- Metadata fields increase the volume of log data delivered, which increases cost. S3 + Parquet keeps storage and query costs low.
