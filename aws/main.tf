provider "aws" {
    region = "us-east-2"
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type       = number
    default    = 8080
}

resource "aws_instance" "example" {
    ami           = "ami-0c55b159cbfafe1f0" # Ubuntu Server 22.04 LTS (us-east-2)
    instance_type = "t2.micro"

    tags = {
        Name = "Instance01",
    } 

    user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" > index.html
    nohup busybox httpd -f -p ${var.server_port} &
    EOF

    user_data_replace_on_change = true
    
    vpc_security_group_ids = [aws_security_group.example_sg.id]
}

resource "aws_security_group" "example_sg" {
    name        = "example-instance-sg"
    description = "Allow HTTP traffic on port 8080"
    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output instance_public_ip {
  value       = aws_instance.example.public_ip
  sensitive   = false
  description = "The public IP address of the instance"
  depends_on  = [aws_instance.example]
}
