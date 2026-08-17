variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "vpc_cidr_block must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = can(regex("/(1[6-9]|2[0-4])$", var.vpc_cidr_block))
    error_message = "vpc_cidr_block must use a /16 through /24 prefix so three /26 service subnets can be allocated."
  }
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
  description = "Map of resource type to tag keys included in flow log records via the Amazon EC2 Tags feature. The tag fields in the log format (and Athena table columns) are generated from this map: the first key maps to <resource>-tag and an optional second key to <resource>-tag-2"
  type        = map(list(string))
  default = {
    instance             = ["Name"]
    "network-interface"  = ["Name"]
    "auto-scaling-group" = ["Name"]
  }

  validation {
    condition     = alltrue([for k in keys(var.flow_logs_tag_keys) : contains(["instance", "network-interface", "auto-scaling-group"], k)])
    error_message = "flow_logs_tag_keys keys must be one of instance, network-interface, or auto-scaling-group."
  }

  validation {
    condition     = alltrue([for v in values(var.flow_logs_tag_keys) : length(v) >= 1 && length(v) <= 2])
    error_message = "Each resource type in flow_logs_tag_keys must have between 1 and 2 tag keys."
  }
}
