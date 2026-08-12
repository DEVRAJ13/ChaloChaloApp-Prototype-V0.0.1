variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCI user OCID"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "OCI API key fingerprint"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "OCI API private key path"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OCI home region"
  type        = string
}

variable "compartment_ocid" {
  description = "OCI compartment OCID"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for the A1 VM"
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_public_key)) > 0
    error_message = "SSH public key cannot be empty."
  }
}

variable "mysql_admin_username" {
  description = "MySQL administrator username"
  type        = string

  validation {
    condition     = length(trimspace(var.mysql_admin_username)) >= 1
    error_message = "MySQL administrator username cannot be empty."
  }
}

variable "mysql_admin_password" {
  description = "MySQL administrator password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.mysql_admin_password) >= 8
    error_message = "MySQL password must contain at least 8 characters."
  }
}

variable "a1_availability_domain" {
  description = "Availability Domain for Always Free A1"
  type        = string

  validation {
    condition = can(regex(
      "^ujaX:AP-MUMBAI-1-AD-[1-3]$",
      var.a1_availability_domain
    ))

    error_message = "A1 must use AP-MUMBAI-1 AD-1, AD-2, or AD-3 only."
  }
}