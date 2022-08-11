resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.region}b"

  tags = {
    Name = "Default subnet for ${var.region}b"
  }
}


resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.region}c"

  tags = {
    Name = "Default subnet for ${var.region}c"
  }
}
