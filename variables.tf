variable "region" {
  default     = "us-east-1"
  type        = string
  description = "region"
}

variable "domain_name" {
  default     = "viatech.live"
  type        = string
  description = "my domain name"
}

variable "instance_class" {
  default     = "t2.micro"
  type        = string
  description = "instance class"
  
}

variable "inbound_ports" {
  default     = [80, 443, 22]
  type        = list(number)
  description = "inbound ports"
}

variable "outbound_port" {
  default     = 80
  description = "outbound port"
} 

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "cidr block"
}

variable "protocol" {
  default = "HTTP"
}

# variable "subnets" {
#   type = map
#   default = {
#     subnet-1  = {
#       az = "az1"
#       cidr = "10.0.1.0/24"
#     }
#     subnet-2  = {
#       az = "az2"
#       cidr = "10.0.2.0/24"
#     }
#   }
# }

#create variable using count
