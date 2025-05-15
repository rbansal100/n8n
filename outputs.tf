output "n8n_public_ip" {
  value = ibm_is_floating_ip.n8n_fip.address
  description = "Public IP address of n8n server"
}
