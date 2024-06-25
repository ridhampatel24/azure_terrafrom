variable "resource_grp_name" {
  type        = string
  description = "Name of the Resource Group"
}

variable "resource_grp_location" {
  type        = string
  description = "Location of the Resource Group"
}


variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}

variable "vnet_cidr" {
  type        = list(string)
  description = "Virtual Network CIDR value"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}
