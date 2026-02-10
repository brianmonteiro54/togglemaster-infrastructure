# =============================================================================
# Locals
# =============================================================================
locals {
  # Private subnets indexed by AZ
  private_subnets = [
    module.vpc.private_subnet_ids[0], # index 0 = AZ-a
    module.vpc.private_subnet_ids[1]  # index 1 = AZ-b
  ]

  # Resolve subnet_ids for each nodegroup using AZ mapping
  nodegroup_subnets = {
    for name, az_index in var.nodegroup_az_mapping :
    name => [local.private_subnets[az_index]]
  }
}
