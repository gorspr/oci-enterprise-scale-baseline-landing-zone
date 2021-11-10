# ---------------------------------------------------------------------------------------------------------------------
# IAM Policy for Administrators
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "administrator_policies" {
  compartment_id = var.tenancy_ocid
  description    = "OCI Landing Zone Administrator Tenancy Policy"
  name           = "${var.administrator_policy_name}-${var.random_policy_name_id}"

  freeform_tags = {
    "Description" = "Policy for access to all resources in tenancy"
  }

  statements = [
    "Allow group ${var.administrator_group_name} to manage all-resources in tenancy where request.user.mfaTotpVerified='true'"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policy Network Admins
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "network_admin_policies" {
  compartment_id = var.network_compartment_id
  description    = "OCI Landing Zone VCN Administrator Policy"
  name           = var.network_admin_policy_name

  freeform_tags = {
    "Description" = "Policy for access to all network resources in Network Compartment"
  }

  statements = [
    "Allow group ${var.network_admin_group_name} to manage virtual-network-family in compartment ${var.network_compartment_name}"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policies LB Users
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "lb_users_policies" {
  for_each       = toset(var.workload_compartment_name_list)
  compartment_id = var.network_compartment_id
  description    = "OCI Landing Zone Load Balancer User Policy"
  name           = "OCI-LZ-${each.value}-LBUserPolicy"

  freeform_tags = {
    "Description" = "Policy for access to all components in Load-balancing and use network family in Network compartment"
  }

  statements = [
    "Allow group ${var.lb_users_group_name} to use virtual-network-family in compartment ${var.network_compartment_name}",
    "Allow group ${var.lb_users_group_name} to manage load-balancers in compartment ${var.network_compartment_name}"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policies Workload-Storage-Admins
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "workload_storage_admins_policies" {
  for_each       = toset(var.workload_compartment_name_list)
  compartment_id = var.workload_compartment_ocids[each.value].workload_compartment_id
  description    = "OCI Landing Zone Workload Specific Storage Administrator Policies"
  name           = "OCI-LZ-${each.value}-StorageAdminPolicy"

  freeform_tags = {
    "Description" = "Policy for Workload Specific Storage Administrator"
  }

  statements = [
    # Ability to do all things with block storage volumes, volume backups, and volume groups
    "Allow group ${var.workload_storage_admins_group_names[each.value].name} to manage volume-family in compartment ${each.value}",
    # Ability to create, manage, or delete a file system or file system clone
    "Allow group ${var.workload_storage_admins_group_names[each.value].name} to manage file-family in compartment ${each.value}",
    # Ability to do all things with object storage buckets
    "Allow group ${var.workload_storage_admins_group_names[each.value].name} to manage buckets in compartment ${each.value}",
    # Ability to do all things with object storage objects
    "Allow group ${var.workload_storage_admins_group_names[each.value].name} to manage objects in compartment ${each.value}"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policies Workload Storage Users
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "workload_storage_users_policies" {
  for_each       = toset(var.workload_compartment_name_list)
  compartment_id = var.workload_compartment_ocids[each.value].workload_compartment_id
  description    = "OCI Landing Zone Storage Workload User Policy"
  name           = "OCI-LZ-${each.value}-WorkloadStorageUserPolicy"

  freeform_tags = {
    "Description" = "Policy for Workload Specific Storage Users"
  }

  statements = [
    # Ability to get all buckets in the compartment
    "Allow group ${var.workload_storage_users_group_names[each.value].name} to read buckets in compartment ${each.value}",
    # Ability to create, inspect and download objects in the compartment
    "Allow group ${var.workload_storage_users_group_names[each.value].name} to manage objects in compartment ${each.value} where any {request.permission='OBJECT_CREATE', request.permission='OBJECT_INSPECT', request.permission='OBJECT_READ'}"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policies Workload Admins
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "workload_admins_policies" {
  for_each       = toset(var.workload_compartment_name_list)
  compartment_id = var.workload_compartment_ocids[each.value].workload_compartment_id
  description    = "OCI Landing Zone Workload User Policy"
  name           = "OCI-LZ-${each.value}-WorkloadAdminPolicy"

  freeform_tags = {
    "Description" = "Policy for Workload Specific Administrators"
  }

  statements = [
    # Ability to do everything with custom images and compute instances
    "Allow group ${var.workload_admins_group_names[each.value].name} to manage instance-images in compartment ${each.value}",
    "Allow group ${var.workload_admins_group_names[each.value].name} to manage instances in compartment ${each.value}",
    "Allow group ${var.workload_admins_group_names[each.value].name} to manage object-family in compartment ${each.value}",
    "Allow group ${var.workload_admins_group_names[each.value].name} to use volume-family in compartment ${each.value}",
    "Allow group ${var.workload_admins_group_names[each.value].name} to use virtual-network-family in compartment ${each.value}",
    # Ability to do all things with instance configurations, instance pools, and cluster networks
    "Allow group ${var.workload_admins_group_names[each.value].name} to manage compute-management-family in compartment ${each.value}",
    "Allow group ${var.workload_admins_group_names[each.value].name} to read instance-family in compartment ${each.value}",
    "Allow group ${var.workload_admins_group_names[each.value].name} to inspect volumes in compartment ${each.value}",
    "Allow group ${var.workload_admins_group_names[each.value].name} to use tag-namespaces in compartment ${each.value} where target.tag-namespace.name = 'oracle-tags'",
    "Allow service compute_management to use compute-capacity-reservations in compartment ${each.value}",
    # Ability to create, update, and delete autoscaling configurations
    "Allow group ${var.workload_admins_group_names[each.value].name} to manage auto-scaling-configuration in compartment ${each.value}",
    # Ability to manage Instance Console Creation
    "Allow group ${var.workload_admins_group_names[each.value].name} to manage instance-console-connection in compartment ${each.value}",
    # Ability to create and list subscriptions to images in the partner Image catalog.
    "Allow group ${var.workload_admins_group_names[each.value].name} to manage app-catalog-listing in compartment ${each.value}",
    # Ability to create, update and delete dedicated Virtual Machine Hosts
    "Allow group ${var.workload_admins_group_names[each.value].name} to manage dedicated-vm-hosts in compartment ${each.value}"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policies Workload Users
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "workload_users_policies" {
  for_each       = toset(var.workload_compartment_name_list)
  compartment_id = var.workload_compartment_ocids[each.value].workload_compartment_id
  description    = "OCI Landing Zone Workload User Policy"
  name           = "OCI-LZ-${each.value}-WorkloadUserPolicy"

  freeform_tags = {
    "Description" = "Policy for Workload Specific Users"
  }

  statements = [
    # Ability to do everything with instances launched into the cloud network and subnets 
    "Allow group ${var.workload_users_group_names[each.value].name} to manage instance in compartment ${each.value}",
    "Allow group ${var.workload_users_group_names[each.value].name} to use virtual-network-family in compartment ${each.value}",
    # Ability to create instance console creation
    "Allow group ${var.workload_users_group_names[each.value].name} to manage instance-console-connection in compartment ${each.value}",
    # Ability to list and create subscriptions to images in partner image catalog.
    "Allow group ${var.workload_users_group_names[each.value].name} to manage app-catalog-listing in compartment ${each.value}",
    # Ability to launch instances on dedicated virtual machine hosts
    "Allow group ${var.workload_users_group_names[each.value].name} to use dedicated-vm-hosts in compartment ${each.value}",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policies Security Admins
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "security_admins_policy" {
  compartment_id = var.parent_compartment_id
  description    = "OCI Landing Zone Security Admin Policy"
  name           = var.security_admins_policy_name

  freeform_tags = {
    "Description" = "Policy for Security Admin Users"
  }

  statements = [
    # Ability to associate an Object Storage bucket, Block Volume volume, File Storage file system, Kubernetes cluster, or Streaming stream pool with a specific key
    "Allow group ${var.security_admins_group_name} to use key-delegate in compartment ${var.parent_compartment_name}", #where target.key.id = '<key_OCID>'",
    # Ability to list, view, and perform cryptographic operations with all keys in compartment 
    "Allow group ${var.security_admins_group_name} to use keys in compartment ${var.parent_compartment_name}",
    "Allow service blockstorage, FssOc1Prod, oke, streaming to use keys in compartment ${var.parent_compartment_name}", #objectstorage-<region-name>
    # Ability to do all things with secrets in a specific vault 
    "Allow group ${var.security_admins_group_name} to manage secret-family in compartment ${var.parent_compartment_name}", #where target.vault.id='<vault_OCID>'",
    # Ability to manage all resources in the Bastion service in all compartments
    "Allow group ${var.security_admins_group_name} to manage bastion in compartment ${var.parent_compartment_name}",
    "Allow group ${var.security_admins_group_name} to manage bastion-session in compartment ${var.parent_compartment_name}",
    "Allow group ${var.security_admins_group_name} to manage virtual-network-family in compartment ${var.parent_compartment_name}",
    "Allow group ${var.security_admins_group_name} to read instance-family in compartment ${var.parent_compartment_name}",
    "Allow group ${var.security_admins_group_name} to read instance-agent-plugins in compartment ${var.parent_compartment_name}",
    "Allow group ${var.security_admins_group_name} to inspect work-requests in compartment ${var.parent_compartment_name}"
  ]
}
# ---------------------------------------------------------------------------------------------------------------------
# IAM Policy Cloud Guard Operator
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "cloud_guard_operators_policies" {
  compartment_id = var.parent_compartment_id
  description    = "OCI Landing Zone Cloud Guard Operators Policy"
  name           = var.cloud_guard_operators_policy_name

  freeform_tags = {
    "Description" = "Policy for Cloud Guard Operators"
  }

  statements = [
    # Basic access to Cloud Guard - read announcements
    "Allow group ${var.cloud_guard_operators_group_name} to read cloud-guard-config in compartment ${var.parent_compartment_name}",
    "Allow group ${var.cloud_guard_operators_group_name} to read announcements in compartment ${var.parent_compartment_name}",
    # Read access to Risk and Security Scores
    "Allow group ${var.cloud_guard_operators_group_name} to inspect cloud-guard-risk-scores in compartment ${var.parent_compartment_name}",
    "Allow group ${var.cloud_guard_operators_group_name} to inspect cloud-guard-security-scores in compartment ${var.parent_compartment_name}",
    # Read-only access to Cloud Guard problems
    "Allow group ${var.cloud_guard_operators_group_name} to read cloud-guard-family in compartment ${var.parent_compartment_name}",
    "Allow group ${var.cloud_guard_operators_group_name} to inspect cloud-guard-detectors in compartment ${var.parent_compartment_name}",
    "Allow group ${var.cloud_guard_operators_group_name} to inspect cloud-guard-targets in compartment ${var.parent_compartment_name}",
    "Allow group ${var.cloud_guard_operators_group_name} to inspect cloud-guard-resource-types in compartment ${var.parent_compartment_name}",
    # "Allow group ${var.cloud_guard_operators_group_name} to read compartments in compartment ${var.parent_compartment_name}",
    # Read-only access to Cloud Guard detector recipes
    "Allow group ${var.cloud_guard_operators_group_name} to read cloud-guard-detector-recipes in compartment ${var.parent_compartment_name}"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policies Cloudguard Analyst
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "cloudguard_analysts_policy" {
  compartment_id = var.parent_compartment_id
  description    = "OCI Landing Zone Cloud Guard Analyst Policy"
  name           = var.cloudguard_analysts_policy_name

  freeform_tags = {
    "Description" = "Policy for Cloud Guard Analyst Users"
  }

  statements = [
    # Read-only access to Cloud Guard problems
    "Allow group ${var.cloudguard_analysts_group_name} to read cloud-guard-family in compartment ${var.parent_compartment_name}",
    "Allow group ${var.cloudguard_analysts_group_name} to inspect cloud-guard-detectors in compartment ${var.parent_compartment_name}",
    "Allow group ${var.cloudguard_analysts_group_name} to inspect cloud-guard-targets in compartment ${var.parent_compartment_name}",
    "Allow group ${var.cloudguard_analysts_group_name} to inspect cloud-guard-resource-types in compartment ${var.parent_compartment_name}",
    "allow group ${var.cloudguard_analysts_group_name} to read announcements in compartment ${var.parent_compartment_name}",
    "allow group ${var.cloudguard_analysts_group_name} to read compartments in compartment ${var.parent_compartment_name}",
    "allow group ${var.cloudguard_analysts_group_name} to read cloud-guard-config in compartment ${var.parent_compartment_name}",
    # Read-only access to Cloud Guard detector recipes
    "allow group ${var.cloudguard_analysts_group_name} to read cloud-guard-detector-recipes in compartment ${var.parent_compartment_name}",
    "allow group ${var.cloudguard_analysts_group_name} to read announcements in compartment ${var.parent_compartment_name}",
    "allow group ${var.cloudguard_analysts_group_name} to read compartments in compartment ${var.parent_compartment_name}",
    "allow group ${var.cloudguard_analysts_group_name} to read cloud-guard-config in compartment ${var.parent_compartment_name}"
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policy Cloud Guard Architect
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "cloud_guard_architects_policies" {
  compartment_id = var.parent_compartment_id
  description    = "OCI Landing Zone Cloud Guard Architect Policy"
  name           = var.cloud_guard_architects_policy_name

  freeform_tags = {
    "Description" = "Policy for Cloud Guard Architect"
  }

  statements = [
    "Allow group ${var.cloud_guard_architects_group_name} to manage cloud-guard-family in compartment ${var.parent_compartment_name}"
  ]
}
