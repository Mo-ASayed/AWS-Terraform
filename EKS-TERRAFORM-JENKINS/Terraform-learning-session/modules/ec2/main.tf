resource "aws_instance" "Coderco_terraform_session" {
    ami = var.ami_id
    instance_type = var.instance_type

    tags = {
      name = "Coderco_tag"
    }

    
}


