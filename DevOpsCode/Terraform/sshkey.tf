resource "tls_private_key" "web" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_web" {
  key_name   = "Web-Key-${var.region}"
  public_key = tls_private_key.web.public_key_openssh
  lifecycle {
    ignore_changes = [public_key]
  }
}