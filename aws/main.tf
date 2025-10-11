provider "aws" {
    region = "us-east-2"
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
    nohup busybox httpd -f -p 8080 &
    EOF

    user_data_replace_on_change = true
    
    vpc_security_group_ids = [aws_security_group.example_sg.id]
}

resource "aws_security_group" "example_sg" {
    name        = "example-instance-sg"
    description = "Allow HTTP traffic on port 8080"
    ingress {
        from_port   = 8080
        to_port     = 8080
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