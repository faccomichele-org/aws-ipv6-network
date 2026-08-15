output "vpc_id" {
  description = "ID of the IPv6-enabled VPC."
  value       = aws_vpc.this.id
}

output "vpc_ipv6_cidr_block" {
  description = "AWS-assigned IPv6 CIDR block for the VPC."
  value       = aws_vpc.this.ipv6_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the three public IPv6-native subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the three private IPv6-native subnets."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "flow_log_id" {
  description = "ID of the VPC flow log, if enabled."
  value       = try(aws_flow_log.vpc[0].id, null)
}

output "logging_bucket_name" {
  description = "Name of the S3 bucket used for flow logs and DNS query logs."
  value       = aws_s3_bucket.logging.id
}

output "logging_bucket_arn" {
  description = "ARN of the S3 bucket used for flow logs and DNS query logs."
  value       = aws_s3_bucket.logging.arn
}

output "resolver_query_log_config_id" {
  description = "ID of the Route 53 Resolver query log configuration, if enabled."
  value       = try(aws_route53_resolver_query_log_config.vpc[0].id, null)
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector, if enabled."
  value       = try(aws_guardduty_detector.this[0].id, null)
}

output "athena_database_name" {
  description = "Name of the Glue database containing the flow log and resolver log tables, if enabled."
  value       = try(aws_glue_catalog_database.logging[0].name, null)
}
