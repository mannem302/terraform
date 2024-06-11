provider "aws" { 
 region = "eu-west-3" 
} 
terraform {
  cloud {
    organization = "GSowmya"

    workspaces {
      name = "gatla"
    }
  }
} 

resource "aws_instance" "interns1" { 
 ami = "ami-0326f9264af7e51e2" 
 instance_type = "t2.micro"  
 availability_zone = "eu-west-3a"
 
 vpc_security_group_ids =["sg-0f4aa0545ddc5ba5c"]
 tags = { 
 Name = "Instance-2" 
 } 
}


 