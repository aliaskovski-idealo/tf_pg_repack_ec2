locals {
  name = replace(lower("${var.namespace}-${var.stage}-${var.name}"), "_", "-")
}
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


resource "aws_iam_role_policy_attachment" "bastion_host_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_host.name
}

resource "aws_iam_role_policy_attachment" "logging_policy" {
  role       = aws_iam_role.bastion_host.name
  policy_arn = aws_iam_policy.logging_policy.arn
}

resource "aws_iam_policy" "logging_policy" {
  name        = "${local.name}-bastion-logging-policy"
  description = "Bastion host logging policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "*"
    ]
  }
 ]
}
EOF
}

resource "aws_iam_role" "bastion_host" {
  name               = "${local.name}-bastion_host"
  description        = "trusted entity of the role"
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "bastion_host_instance_profile" {
  name = "${local.name}-instance-profile"
  role = aws_iam_role.bastion_host.name
}

// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_host_instance_profile.name
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet[0]
  vpc_security_group_ids      = compact(concat([var.sg_rds_connect_id], aws_security_group.allow_ssh_pub.*.id))

  tags = {
    "Name" = "${local.name}-EC2-PUBLIC"
  }

  user_data = templatefile("${path.module}/templates/init.tpl", {
    region = var.region
    engine = var.rds_engine
  })
}

# ------------------------------------------------------------------------------
# policy for users allowing connection
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "instance_connect" {
  name        = "${local.name}-instance-connect"
  path        = "/allow_connect_access/"
  description = "Allows use of EC2 instance connect"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
  		"Effect": "Allow",
  		"Action": "ec2-instance-connect:SendSSHPublicKey",
  		"Resource": "${aws_instance.ec2_public.arn}",
  		"Condition": {
  			"StringEquals": { "ec2:osuser": "ec2-user" }
  		}
  	},
		{
			"Effect": "Allow",
			"Action": "ec2:DescribeInstances",
			"Resource": "*"
		}
  ]
}
EOF
}

// SG to allow SSH connections from anywhere
resource "aws_security_group" "allow_ssh_pub" {
  name        = "${local.name}-allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc

  # for db authentication using ssh tunnel only, without sessionmanager!
  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-allow_ssh_pub"
  }
}


data "template_file" "connect_script" {
  template = file("${path.module}/connect.sh.tpl")
  vars = {
    ec2_public_ip   = aws_instance.ec2_public.public_ip
    ec2_instance_id = aws_instance.ec2_public.id
    rds_port        = var.rds_port
    rds_endpoint    = var.rds_endpoint
    ec2_az          = aws_instance.ec2_public.availability_zone
    aws_region      = var.region
    OPTION          = "$${OPTION}"
    SELF            = "$${SELF}"
    ARGS            = ""
  }
}

resource "local_file" "connect_script" {
  content         = data.template_file.connect_script.rendered
  filename        = "connect.sh"
  file_permission = "0500"
}

