variable "region" {
    description = "The AWS region to depoly resources"
    default = "us-west-2"
}

variable "ec2_instance_type" {
    description = "The EC2 instance type"
    default = "t2.micro"
}

variable "ec2_key_name" {
    description = "The SSH key pair to login the instance"
    default = "AWS_key"
}

variable "security_group_id" {
    description = "The security group ID"
    default = "sg-03cd5afe567331764"
}