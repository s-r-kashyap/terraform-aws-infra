variable "project_name"      { type = string }
variable "environment"       { type = string }
variable "vpc_id"            { type = string }
variable "subnet_id"         { type = string }
variable "instance_type"     { type = string; default = "t3.micro" }
variable "ami_id"            { type = string }
variable "key_name"          { type = string; default = "" }
variable "allowed_ssh_cidrs" { type = list(string); default = ["0.0.0.0/0"] }
