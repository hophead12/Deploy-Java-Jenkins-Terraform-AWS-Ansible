resource "tls_private_key" "db" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_db" {
  key_name   = "DB-Key-${var.region}.pem"
  public_key = tls_private_key.db.public_key_openssh
}

resource "tls_private_key" "web" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_web" {
  key_name   = "Web-Key-${var.region}.pem"
  public_key = tls_private_key.web.public_key_openssh
}