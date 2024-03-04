variable "availability_zone" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b"]
  description = "AZs where the VMs must be deployed"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
  description = "Region where whole infra will be provisioned."
}

variable "sg_ports_for_internet" {
  type    = list(number)
  default = [80, 443] # 80 -> http, 443 -> https
  description = "List of allowed ports accessible through LB."
}