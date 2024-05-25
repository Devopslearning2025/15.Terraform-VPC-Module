variable "project_name" {
    type = string
}

 variable "environemnt" {
    type = string
    default = "dev"  
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}

variable "common_tags" {
     type = map
 }

variable "vpc_tags" {
    type = map
    default = {}   
}

variable "enable_dns_hostname" {
    type = bool 
    default = true
}

variable "ig_tags" {
    type = map 
    default = {}  
}

variable "public_subnet_cidrs" {
    type = list 
    validation {
      condition = length(var.public_subnet_cidrs) == 2
      error_message = "Please provide 2 public CIDR"
    }
  
}

variable "public_subnet_cidrs_tags" {
    type = map 
    default = {}  
}

variable "private_subnet_cidrs" {
    type = list 
    validation {
      condition = length(var.private_subnet_cidrs) == 2
      error_message = "Please provide 2 private CIDR"
    }  
}

variable "private_subnet_cidr_tags" {
    type = map 
    default = {}  
}

variable "database_subnet_cidrs" {
    type = list 
    validation {
      condition = length(var.database_subnet_cidrs) == 2
      error_message = "Please provide 2 database CIDR"
    }  
}

variable "database_subnet_cidr_tags" {
    type = map 
    default = {}  
}

variable "database_subnet_tags" {
    type = map 
    default = {}  
}

variable "ntw_tags" {
    type = map 
    default = {}  
}


#public route table
variable "databse_route_table_tags" {
    type = map 
    default = {}  
}

#private route table
variable "private_route_table_tags" {
    type = map 
    default = {}
}

#database route table
variable "public_route_table_tags" {
    type = map 
    default = {}
}

#perring connection
variable "is_peering_required" {
      type = bool 
      default = false
}

variable "acceptor_vpc_id" {
    type = string  
    default = "" 
}

variable "vpc_peering_tags"{
    type = map 
    default = {}
}