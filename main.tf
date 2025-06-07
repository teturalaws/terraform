provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "example" {
    ami           = "ami-0c55b159cbfafe1f0" # Ubuntu Server 22.04 LTS (us-east-2)
    instance_type = "t2.micro"

    tags = {
        Name = "example-instance",
        second_tag = "my_second_tag"
    }
}