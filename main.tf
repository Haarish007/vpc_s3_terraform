resource "aws_vpc" "myvpc"{
    cidr_block= var.cidr
}
resource "aws_subnet" "sub1"{
    vpc_id =aws_vpc.myvpc.id
    cidr_block= "10.0.0.0/24"
    availability_zone="us-east-1a"
    map_public_ip_on_launch = true

}
resource "aws_subnet" "sub2"{
    vpc_id =aws_vpc.myvpc.id
    cidr_block= "10.0.1.0/24"
    availability_zone="us-east-1b"
    map_public_ip_on_launch = true

}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "RT"{
    vpc_id = aws_vpc.myvpc.id
    route{
        cidr_block="0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}
resource "aws_route_table_association" "rta1"{
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
}
resource "aws_route_table_association" "rta2"{
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "webSg" {
  name        = "webSg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "webSg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.myvpc.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_s3_bucket" "example" {
  bucket = "hari@123"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.example.id
  acl    = "public -read"
}

resource "aws_instance" "webserver1" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  vpc_security_group_ids=[aws_security_group.webSg]
  subnet_id =aws_subnet.sub1.id 
 
}

resource "aws_instance" "webserver2" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  vpc_security_group_ids=[aws_security_group.webSg]
  subnet_id =aws_subnet.sub2.id 
 
}
