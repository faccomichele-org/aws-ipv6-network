output "vpc_id" {
  description = "ID of the IPv6-enabled VPC."
  value       = aws_ssm_parameter.vpc_id.name
}

output "vpc_ipv6_cidr_block" {
  description = "AWS-assigned IPv6 CIDR block for the VPC."
  value       = aws_ssm_parameter.vpc_ipv6_cidr_block.name
}

output "public_subnet_ids" {
  description = "IDs of the three public IPv6-native subnets."
  value       = aws_ssm_parameter.public_subnet_ids.name
}

output "private_subnet_ids" {
  description = "IDs of the three private IPv6-native subnets."
  value       = aws_ssm_parameter.private_subnet_ids.name
}

output "services_subnet_ids" {
  description = "IDs of the three dual-stack service subnets."
  value       = aws_ssm_parameter.services_subnet_ids.name
}
