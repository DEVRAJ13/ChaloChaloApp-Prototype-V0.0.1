output "vcn_id" {
  description = "ChaloChalo VCN OCID"
  value       = oci_core_vcn.chalochalo.id
}

output "public_subnet_id" {
  description = "Public subnet OCID"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet OCID"
  value       = oci_core_subnet.private.id
}

output "compute_instance_id" {
  description = "A1 Compute instance OCID"
  value       = oci_core_instance.chalochalo.id
}

output "compute_private_ip" {
  description = "A1 private IP"
  value       = oci_core_instance.chalochalo.private_ip
}

output "compute_public_ip" {
  description = "A1 public IP"
  value       = oci_core_instance.chalochalo.public_ip
}

output "mysql_db_system_id" {
  description = "MySQL DB System OCID"
  value       = oci_mysql_mysql_db_system.chalochalo.id
}

output "mysql_private_ip" {
  description = "MySQL private IP"
  value       = oci_mysql_mysql_db_system.chalochalo.ip_address
}