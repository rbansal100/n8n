variable "region" {
  description = "IBM Cloud region"
  default     = "us-south"
}

variable "zone" {
  description = "IBM Cloud availability zone"
  default     = "us-south-1"
}

variable "ssh_public_key" {
  description = "Public SSH key for VM access"
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key content"
  type        = string
  sensitive   = true
}

variable "n8n_user" {
  description = "Username for n8n basic auth"
  default     = "admin"
}

variable "n8n_pass" {
  description = "Password for n8n basic auth"
  default     = "securepassword"
}
