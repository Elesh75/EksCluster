provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "instance_role" {
  name = "instance_role"
  
  assume_role_policy = <<EOF 
  {
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" = "sts:AssumeRole"
        "Effect" = "Allow"
        "Sid"    = ""
        "Principal" = {
          "Service" = "ec2.amazonaws.com"
          "AWS"     = "914590072217"
        }
      },
    ]
    EOF
  }


resource "aws_iam_role_policy" "policy" {
  name = "instance_role_policy"

  policy = <<EOF 
  {
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" = [
          "ec2:Describe*", "s3:Get*", "s3:List*"
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      },
    ]
    EOF
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_instance_profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_policy_attachment" "instance_policy-attach" {
  name       = "instance_rolepolicy-attachment"
  role      = aws_iam_role.instance_role.name
  policy_arn = aws_iam_role_policy.policy.arn
}

# create an AMI
data "aws_ami" "amzlinux2" {
  executable_users = ["self"]
  most_recent      = true
  name_regex       = "^myami-\\d{3}"
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.amzlinux2.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.test_profile.id
  key_name = "DEMO1"

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your AMI
    private_key = file("../Demo1.pem")
    host        = self.public_ip  # Public IP of the instance
  }


  tags = {
    Name = "Test_Instance"
  }
}