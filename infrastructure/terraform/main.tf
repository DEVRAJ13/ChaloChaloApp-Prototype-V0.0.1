# =========================================================
# CHALOCHALO OCI - ALWAYS FREE ONLY
# =========================================================

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}


# =========================================================
# ALWAYS-FREE SAFETY CONSTANTS
# =========================================================

locals {

  # -------------------------------------------------------
  # A1 COMPUTE - HARD LIMIT
  # -------------------------------------------------------

  compute_shape = "VM.Standard.A1.Flex"

  compute_ocpus = 2

  compute_memory_gb = 12

  # -------------------------------------------------------
  # MYSQL - HARD LIMIT
  # -------------------------------------------------------

  mysql_shape = "MySQL.Free"

  mysql_storage_gb = 50

  # -------------------------------------------------------
  # NETWORK
  # -------------------------------------------------------

  vcn_cidr = "10.0.0.0/16"

  public_subnet_cidr = "10.0.1.0/24"

  private_subnet_cidr = "10.0.2.0/24"
}


# =========================================================
# AVAILABILITY DOMAINS
# =========================================================

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}


# =========================================================
# ARM64 UBUNTU IMAGE
# =========================================================

data "oci_core_images" "ubuntu_arm64" {

  compartment_id = var.compartment_ocid

  operating_system = "Canonical Ubuntu"

  shape = local.compute_shape

  state = "AVAILABLE"

  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}


# =========================================================
# VCN
# =========================================================

resource "oci_core_vcn" "chalochalo" {

  compartment_id = var.compartment_ocid

  display_name = "chalochalo-vcn"

  cidr_blocks = [
    local.vcn_cidr
  ]

  dns_label = "chalochalo"
}


# =========================================================
# INTERNET GATEWAY
# =========================================================

resource "oci_core_internet_gateway" "chalochalo" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_vcn.chalochalo.id

  display_name = "chalochalo-internet-gateway"

  enabled = true
}


# =========================================================
# PUBLIC ROUTE TABLE
# =========================================================

resource "oci_core_route_table" "public" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_vcn.chalochalo.id

  display_name = "chalochalo-public-route-table"

  route_rules {

    destination = "0.0.0.0/0"

    destination_type = "CIDR_BLOCK"

    network_entity_id = (
      oci_core_internet_gateway.chalochalo.id
    )
  }
}


# =========================================================
# PRIVATE ROUTE TABLE
# =========================================================

resource "oci_core_route_table" "private" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_vcn.chalochalo.id

  display_name = "chalochalo-private-route-table"

  # No Internet Gateway.
  #
  # No NAT Gateway.
  #
  # Traffic between VCN subnets uses OCI's
  # implicit local routing.
}


# =========================================================
# PUBLIC SECURITY LIST
# =========================================================

resource "oci_core_security_list" "public" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_vcn.chalochalo.id

  display_name = "chalochalo-public-security-list"


  # -------------------------------------------------------
  # SSH
  # -------------------------------------------------------

  ingress_security_rules {

    protocol = "6"

    source = "0.0.0.0/0"

    tcp_options {

      min = 22

      max = 22
    }
  }


  # -------------------------------------------------------
  # HTTP
  # -------------------------------------------------------

  ingress_security_rules {

    protocol = "6"

    source = "0.0.0.0/0"

    tcp_options {

      min = 80

      max = 80
    }
  }


  # -------------------------------------------------------
  # HTTPS
  # -------------------------------------------------------

  ingress_security_rules {

    protocol = "6"

    source = "0.0.0.0/0"

    tcp_options {

      min = 443

      max = 443
    }
  }


  # -------------------------------------------------------
  # OUTBOUND
  # -------------------------------------------------------

  egress_security_rules {

    protocol = "all"

    destination = "0.0.0.0/0"
  }
}


# =========================================================
# PRIVATE SECURITY LIST
# =========================================================

resource "oci_core_security_list" "private" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_vcn.chalochalo.id

  display_name = "chalochalo-private-security-list"


  # -------------------------------------------------------
  # MYSQL
  #
  # ONLY CHALOCHALO PUBLIC SUBNET CAN CONNECT
  # -------------------------------------------------------

  ingress_security_rules {

    protocol = "6"

    source = local.public_subnet_cidr

    tcp_options {

      min = 3306

      max = 3306
    }
  }


  # -------------------------------------------------------
  # OUTBOUND
  # -------------------------------------------------------

  egress_security_rules {

    protocol = "all"

    destination = "0.0.0.0/0"
  }
}


# =========================================================
# PUBLIC SUBNET
# =========================================================

resource "oci_core_subnet" "public" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_vcn.chalochalo.id

  display_name = "chalochalo-public-subnet"

  cidr_block = local.public_subnet_cidr

  route_table_id = oci_core_route_table.public.id

  security_list_ids = [
    oci_core_security_list.public.id
  ]

  dns_label = "public"

  prohibit_public_ip_on_vnic = false
}


# =========================================================
# PRIVATE SUBNET
# =========================================================

resource "oci_core_subnet" "private" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_vcn.chalochalo.id

  display_name = "chalochalo-private-subnet"

  cidr_block = local.private_subnet_cidr

  route_table_id = oci_core_route_table.private.id

  security_list_ids = [
    oci_core_security_list.private.id
  ]

  dns_label = "private"

  # VERY IMPORTANT
  # MySQL cannot receive a public IP.

  prohibit_public_ip_on_vnic = true
}


# =========================================================
# MYSQL - ALWAYS FREE
# =========================================================

resource "oci_mysql_mysql_db_system" "chalochalo" {

  compartment_id = var.compartment_ocid


  # -------------------------------------------------------
  # ALWAYS FREE SHAPE
  # -------------------------------------------------------

  shape_name = local.mysql_shape


  # -------------------------------------------------------
  # AVAILABILITY DOMAIN
  # -------------------------------------------------------

  availability_domain = (
    data.oci_identity_availability_domains.ads
    .availability_domains[0]
    .name
  )


  # -------------------------------------------------------
  # PRIVATE SUBNET
  # -------------------------------------------------------

  subnet_id = oci_core_subnet.private.id


  display_name = "chalochalo-mysql"


  hostname_label = "chalochalo-mysql"


  # -------------------------------------------------------
  # MYSQL ADMIN
  # -------------------------------------------------------

  admin_username = var.mysql_admin_username

  admin_password = var.mysql_admin_password


  # -------------------------------------------------------
  # ALWAYS FREE STORAGE
  # -------------------------------------------------------

  data_storage_size_in_gb = local.mysql_storage_gb


  # -------------------------------------------------------
  # NO HIGH AVAILABILITY
  # -------------------------------------------------------

  is_highly_available = false


  # -------------------------------------------------------
  # IPV4 ONLY
  # -------------------------------------------------------

  is_ipv6enabled = false


  # -------------------------------------------------------
  # NORMAL READ/WRITE DATABASE
  # -------------------------------------------------------

  database_mode = "READ_WRITE"


  # -------------------------------------------------------
  # SAFETY
  # -------------------------------------------------------

  lifecycle {

    precondition {

      condition = (
        local.mysql_shape == "MySQL.Free"
      )

      error_message = <<-EOT
        SAFETY STOP:
        ChaloChalo only allows MySQL.Free.
      EOT
    }


    precondition {

      condition = (
        local.mysql_storage_gb == 50
      )

      error_message = <<-EOT
        SAFETY STOP:
        MySQL storage must remain 50 GB.
      EOT
    }


    precondition {

      condition = (
        local.mysql_shape == "MySQL.Free" &&
        local.mysql_storage_gb == 50 &&
        local.mysql_storage_gb <= 50
      )

      error_message = <<-EOT
        SAFETY STOP:
        MySQL configuration is outside the ChaloChalo
        Always Free policy.
      EOT
    }
  }
}


# =========================================================
# A1 FLEX COMPUTE
# =========================================================

resource "oci_core_instance" "chalochalo" {

  compartment_id = var.compartment_ocid

  display_name = "chalochalo-server"


  # -------------------------------------------------------
  # AVAILABILITY DOMAIN
  # -------------------------------------------------------

  availability_domain = availability_domain = var.a1_availability_domain


  # -------------------------------------------------------
  # ALWAYS FREE SHAPE
  # -------------------------------------------------------

  shape = local.compute_shape


  # -------------------------------------------------------
  # HARD-CODED 2 OCPU / 12 GB
  # -------------------------------------------------------

  shape_config {

    ocpus = local.compute_ocpus

    memory_in_gbs = local.compute_memory_gb
  }


  # -------------------------------------------------------
  # UBUNTU ARM64
  # -------------------------------------------------------

  source_details {

    source_type = "image"

    source_id = (
      data.oci_core_images.ubuntu_arm64.images[0].id
    )

    boot_volume_size_in_gbs = 50
  }


  # -------------------------------------------------------
  # PUBLIC NETWORK
  # -------------------------------------------------------

  create_vnic_details {

    subnet_id = oci_core_subnet.public.id

    assign_public_ip = true

    hostname_label = "chalochalo"

    display_name = "chalochalo-primary-vnic"
  }


  # -------------------------------------------------------
  # SSH
  # -------------------------------------------------------

  metadata = {

    ssh_authorized_keys = var.ssh_public_key
  }


  # -------------------------------------------------------
  # HARD SAFETY GUARDS
  # -------------------------------------------------------

  lifecycle {

    precondition {

      condition = (
        local.compute_shape == "VM.Standard.A1.Flex"
      )

      error_message = <<-EOT
        SAFETY STOP:
        Only VM.Standard.A1.Flex is allowed.
      EOT
    }


    precondition {

      condition = (
        local.compute_ocpus == 2
      )

      error_message = <<-EOT
        SAFETY STOP:
        A1 OCPU must remain exactly 2.
      EOT
    }


    precondition {

      condition = (
        local.compute_memory_gb == 12
      )

      error_message = <<-EOT
        SAFETY STOP:
        A1 memory must remain exactly 12 GB.
      EOT
    }


    precondition {

      condition = (
        local.compute_ocpus <= 2 &&
        local.compute_memory_gb <= 12
      )

      error_message = <<-EOT
        SAFETY STOP:
        ChaloChalo cannot exceed the Always Free A1 allocation.
      EOT
    }
  }
}


# =========================================================
# GLOBAL ALWAYS-FREE SAFETY CHECK
# =========================================================

check "chalochalo_always_free_policy" {

  assert {

    condition = (
      local.compute_shape == "VM.Standard.A1.Flex" &&
      local.compute_ocpus == 2 &&
      local.compute_memory_gb == 12 &&
      local.mysql_shape == "MySQL.Free" &&
      local.mysql_storage_gb == 50
    )

    error_message = <<-EOT
      CHALOCHALO SAFETY STOP

      Allowed configuration:

      A1:
        VM.Standard.A1.Flex
        2 OCPU
        12 GB RAM

      MySQL:
        MySQL.Free
        50 GB

      No paid configuration is permitted.
    EOT
  }
}