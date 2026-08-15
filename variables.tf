variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs delivered to Amazon S3 in Parquet format with EC2/ECS metadata fields"
  type        = bool
  default     = true
}

variable "enable_resolver_query_logs" {
  description = "Enable Route 53 Resolver query logging (DNS logs) for the VPC"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable the Amazon GuardDuty detector (account-level resource, not VPC-scoped)"
  type        = bool
  default     = false
}

variable "enable_athena" {
  description = "Provision the Athena workgroup and Glue database/tables to query the logs"
  type        = bool
  default     = true
}

variable "flow_logs_tag_keys" {
  description = "Map of resource type to tag keys included in flow log records via the Amazon EC2 Tags feature"
  type        = map(list(string))
  default = {
    instance             = ["Name"]
    "network-interface"  = ["Name"]
    "auto-scaling-group" = ["Name"]
  }
}
