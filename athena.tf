locals {
  athena_database_name  = "${replace(replace(lower(local.project_name), "-", "_"), ".", "_")}_logging"
  athena_workgroup_name = "${replace(replace(lower(local.project_name), "_", "-"), ".", "-")}-logging"
}

resource "aws_glue_catalog_database" "logging" {
  count = var.enable_athena ? 1 : 0

  name = local.athena_database_name
}

resource "aws_glue_catalog_table" "vpc_flow_logs" {
  count = var.enable_athena ? 1 : 0

  database_name = aws_glue_catalog_database.logging[0].name
  name          = "vpc_flow_logs"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL           = "TRUE"
    has_encrypted_data = "true"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.logging.bucket}/AWSLogs/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "ParquetSerDe"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "version"
      type = "int"
    }
    columns {
      name = "account_id"
      type = "string"
    }
    columns {
      name = "interface_id"
      type = "string"
    }
    columns {
      name = "srcaddr"
      type = "string"
    }
    columns {
      name = "dstaddr"
      type = "string"
    }
    columns {
      name = "srcport"
      type = "int"
    }
    columns {
      name = "dstport"
      type = "int"
    }
    columns {
      name = "protocol"
      type = "int"
    }
    columns {
      name = "packets"
      type = "bigint"
    }
    columns {
      name = "bytes"
      type = "bigint"
    }
    columns {
      name = "start"
      type = "bigint"
    }
    columns {
      name = "end"
      type = "bigint"
    }
    columns {
      name = "action"
      type = "string"
    }
    columns {
      name = "log_status"
      type = "string"
    }
    columns {
      name = "vpc_id"
      type = "string"
    }
    columns {
      name = "subnet_id"
      type = "string"
    }
    columns {
      name = "instance_id"
      type = "string"
    }
    columns {
      name = "tcp_flags"
      type = "int"
    }
    columns {
      name = "type"
      type = "string"
    }
    columns {
      name = "pkt_srcaddr"
      type = "string"
    }
    columns {
      name = "pkt_dstaddr"
      type = "string"
    }
    columns {
      name = "region"
      type = "string"
    }
    columns {
      name = "az_id"
      type = "string"
    }
    columns {
      name = "sublocation_type"
      type = "string"
    }
    columns {
      name = "sublocation_id"
      type = "string"
    }
    columns {
      name = "pkt_src_aws_service"
      type = "string"
    }
    columns {
      name = "pkt_dst_aws_service"
      type = "string"
    }
    columns {
      name = "flow_direction"
      type = "string"
    }
    columns {
      name = "traffic_path"
      type = "int"
    }
    columns {
      name = "ecs_cluster_arn"
      type = "string"
    }
    columns {
      name = "ecs_cluster_name"
      type = "string"
    }
    columns {
      name = "ecs_service_name"
      type = "string"
    }
    columns {
      name = "ecs_task_arn"
      type = "string"
    }
    columns {
      name = "ecs_task_id"
      type = "string"
    }
    columns {
      name = "ecs_task_definition_arn"
      type = "string"
    }
    columns {
      name = "ecs_container_instance_arn"
      type = "string"
    }
    columns {
      name = "ecs_container_instance_id"
      type = "string"
    }
    columns {
      name = "ecs_container_id"
      type = "string"
    }
    columns {
      name = "ecs_second_container_id"
      type = "string"
    }
    columns {
      name = "reject_reason"
      type = "string"
    }
    columns {
      name = "resource_id"
      type = "string"
    }
    columns {
      name = "encryption_status"
      type = "int"
    }
    columns {
      name = "instance_tag"
      type = "string"
    }
    columns {
      name = "instance_tag_2"
      type = "string"
    }
    columns {
      name = "interface_tag"
      type = "string"
    }
    columns {
      name = "interface_tag_2"
      type = "string"
    }
    columns {
      name = "asg_tag"
      type = "string"
    }
    columns {
      name = "asg_tag_2"
      type = "string"
    }
    columns {
      name = "interface_type"
      type = "string"
    }
    columns {
      name = "next_hop_interface_id"
      type = "string"
    }
    columns {
      name = "next_hop_subnet_id"
      type = "string"
    }
    columns {
      name = "next_hop_az_id"
      type = "string"
    }
    columns {
      name = "next_hop_vpc_id"
      type = "string"
    }
    columns {
      name = "next_hop_interface_type"
      type = "string"
    }
  }

  partition_keys {
    name = "aws-account-id"
    type = "string"
  }
  partition_keys {
    name = "aws-service"
    type = "string"
  }
  partition_keys {
    name = "aws-region"
    type = "string"
  }
  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }
  partition_keys {
    name = "hour"
    type = "string"
  }
}

resource "aws_glue_catalog_table" "resolver_query_logs" {
  count = var.enable_athena ? 1 : 0

  database_name = aws_glue_catalog_database.logging[0].name
  name          = "resolver_query_logs"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL           = "TRUE"
    has_encrypted_data = "true"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.logging.bucket}/AWSLogs/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "JsonSerDe"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
      parameters = {
        "ignore.malformed.json" = "true"
      }
    }

    columns {
      name = "version"
      type = "string"
    }
    columns {
      name = "account_id"
      type = "string"
    }
    columns {
      name = "region"
      type = "string"
    }
    columns {
      name = "vpc_id"
      type = "string"
    }
    columns {
      name = "query_timestamp"
      type = "string"
    }
    columns {
      name = "query_name"
      type = "string"
    }
    columns {
      name = "query_type"
      type = "string"
    }
    columns {
      name = "query_class"
      type = "string"
    }
    columns {
      name = "rcode"
      type = "string"
    }
    columns {
      name = "answer_type"
      type = "string"
    }
    columns {
      name = "rdata"
      type = "string"
    }
    columns {
      name = "answer_class"
      type = "string"
    }
    columns {
      name = "srcaddr"
      type = "string"
    }
    columns {
      name = "srcport"
      type = "string"
    }
    columns {
      name = "transport"
      type = "string"
    }
    columns {
      name = "srcids"
      type = "string"
    }
    columns {
      name = "instance"
      type = "string"
    }
    columns {
      name = "resolver_endpoint"
      type = "string"
    }
    columns {
      name = "firewall_rule_group_id"
      type = "string"
    }
    columns {
      name = "firewall_rule_action"
      type = "string"
    }
    columns {
      name = "firewall_domain_list_id"
      type = "string"
    }
    columns {
      name = "additional_properties"
      type = "string"
    }
  }

  partition_keys {
    name = "aws-account-id"
    type = "string"
  }
  partition_keys {
    name = "aws-service"
    type = "string"
  }
  partition_keys {
    name = "aws-region"
    type = "string"
  }
  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }
}

resource "aws_athena_workgroup" "logging" {
  count = var.enable_athena ? 1 : 0

  name = local.athena_workgroup_name
  tags = merge(local.tags,
    {
      Name = "${local.project_name}-logging-workgroup"
      File = "athena.tf"
    }
  )

  configuration {
    enforce_workgroup_configuration = true

    engine_version {
      selected_engine_version = "Athena engine version 3"
    }

    result_configuration {
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
      output_location = "s3://${aws_s3_bucket.logging.bucket}/athena-results/"
    }
  }
}
