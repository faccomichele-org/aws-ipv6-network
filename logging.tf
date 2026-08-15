resource "aws_s3_bucket" "logging" {
  bucket = local.logging_bucket_name
  tags = merge(local.tags,
    {
      Name = "${local.project_name}-logging-bucket"
      File = "logging.tf"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.logging.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logging" {
  bucket = aws_s3_bucket.logging.id
  rule {
    id     = "logs-retention"
    status = "Enabled"
    filter {}
    dynamic "transition" {
      for_each = local.flow_logs_transition_ia_days > 0 ? [1] : []
      content {
        days          = local.flow_logs_transition_ia_days
        storage_class = "STANDARD_IA"
      }
    }
    dynamic "transition" {
      for_each = local.flow_logs_transition_glacier_days > 0 ? [1] : []
      content {
        days          = local.flow_logs_transition_glacier_days
        storage_class = "GLACIER_IR"
      }
    }
    expiration {
      days = local.flow_logs_retention_days
    }
  }
}

resource "aws_flow_log" "vpc" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination          = aws_s3_bucket.logging.arn
  log_destination_type     = "s3"
  log_format               = local.flow_log_format
  max_aggregation_interval = 60
  traffic_type             = "ALL"
  vpc_id                   = aws_vpc.this.id

  destination_options {
    file_format                = "parquet"
    per_hour_partition         = true
    hive_compatible_partitions = true
  }

  dynamic "tag_field_specification" {
    for_each = var.flow_logs_tag_keys
    content {
      resource_type = tag_field_specification.key
      tag_keys      = tag_field_specification.value
    }
  }

  tags = merge(local.tags,
    {
      Name = "${local.project_name}-vpc-flow-log"
      File = "logging.tf"
    }
  )
}

resource "aws_route53_resolver_query_log_config" "vpc" {
  count = var.enable_resolver_query_logs ? 1 : 0

  name            = "${local.project_name}-resolver-query-log"
  destination_arn = aws_s3_bucket.logging.arn

  tags = merge(local.tags,
    {
      Name = "${local.project_name}-resolver-query-log"
      File = "logging.tf"
    }
  )
}

resource "aws_route53_resolver_query_log_config_association" "vpc" {
  count = var.enable_resolver_query_logs ? 1 : 0

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.vpc[0].id
  resource_id                  = aws_vpc.this.id
}

resource "aws_guardduty_detector" "this" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  tags = merge(local.tags,
    {
      Name = "${local.project_name}-guardduty"
      File = "logging.tf"
    }
  )
}

resource "aws_guardduty_detector_feature" "s3_data_events" {
  count = var.enable_guardduty ? 1 : 0

  detector_id = aws_guardduty_detector.this[0].id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}
