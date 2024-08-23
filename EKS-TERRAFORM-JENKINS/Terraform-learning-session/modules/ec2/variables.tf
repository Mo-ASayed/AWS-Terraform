variable "Coderco_session" {
    description = "Coderco_terraform_session"
    type = list(string)
}

variable "ami_id" {
  description = "Linux AMI" 
  type = string
}

variable "instance_type" {
    description = "Our EC2 Instance type"
    type = string
}