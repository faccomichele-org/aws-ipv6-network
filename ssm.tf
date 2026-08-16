resource "aws_ssm_parameter" "vpc_id" {
	name  = "${local.ssm_path}vpc_id"
	type  = "String"
	value = aws_vpc.this.id

	tags = local.tags
}

resource "aws_ssm_parameter" "vpc_ipv6_cidr_block" {
	name  = "${local.ssm_path}vpc_ipv6_cidr_block"
	type  = "String"
	value = aws_vpc.this.ipv6_cidr_block

	tags = local.tags
}

resource "aws_ssm_parameter" "public_subnet_ids" {
	name  = "${local.ssm_path}public_subnet_ids"
	type  = "StringList"
	value = join(",", [for subnet in aws_subnet.public : subnet.id])

	tags = local.tags
}

resource "aws_ssm_parameter" "private_subnet_ids" {
	name  = "${local.ssm_path}private_subnet_ids"
	type  = "StringList"
	value = join(",", [for subnet in aws_subnet.private : subnet.id])

	tags = local.tags
}
