# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
data "local_file" "version" {
  filename = "${path.module}/VERSION"
}

data "local_file" "python_version" {
  filename = "${path.module}/PYTHON_VERSION"
}

data "aws_service" "home_region_validation" {
  service_id = "controltower"
  lifecycle {
    precondition {
      condition     = try(contains(local.service_catalog_regional_availability.values, var.ct_home_region), true) == true
      error_message = "AFT is not supported on Control Tower home region ${var.ct_home_region}. Refer to https://docs.aws.amazon.com/controltower/latest/userguide/limits.html for more information."
    }
  }
}

data "aws_partition" "current" {
}



# added for trouble shoot

data "aws_caller_identity" "current" {}

output "tfc_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "tfc_account_id" {
  value = data.aws_caller_identity.current.account_id
}

#Run a plan/apply in TFC and read the output.

#This ARN is the identity Terraform is using inside that workspace (i.e., the role/session that actually executed AWS API calls).

#If it shows arn:aws:sts::032104382159:assumed-role/<RoleName>/<session> → that <RoleName> is what TFC is effectively using in the AFT management account.

#If it shows a role in a different account → you’re not actually running in the AFT management account context; you’re assuming into it (or failing to).

#This is the most deterministic check.