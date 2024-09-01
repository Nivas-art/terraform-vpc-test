##vpc variables##

variable "cidr_vpc" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "hostname"{
    type = bool
    default = true
}

##tags##

variable "common_tags"{
    type = map
}

variable "project_name"{
    type = string
}

variable "environment"{
    type = string
}

##public subnet##

variable "public_subnet_cidrs"{
   type = list
   validation{
       condition = length(var.public_subnet_cidrs) == 2
       error_message = "2 cidrs are needed only"
   }
}

##private subnet##

variable "private_subnet_cidrs"{
   type = list
   validation{
       condition = length(var.private_subnet_cidrs) == 2
       error_message = "2 cidrs are needed only"
   }
}

##database subnet##

variable "database_subnet_cidrs"{
   type = list
   validation{
       condition = length(var.database_subnet_cidrs) == 2
       error_message = "2 cidrs are needed only"
   }
}

##peering connection###

variable "is_peering_required"{
    type = bool
    default = false
}

variable "accepter_vpc_id"{
    default = ""
}
