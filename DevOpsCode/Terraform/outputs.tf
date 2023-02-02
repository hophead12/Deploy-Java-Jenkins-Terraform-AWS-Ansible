#output "webserver_instance_id" {
#  value = aws_instance.web
#}


output "Webserver_public_ip_address" {
  value = aws_eip.web.public_ip
}
output "DBserver_public_ip_address" {
  value = aws_eip.db.public_ip
}
output "webserver_sg_id_web" {
  value = aws_security_group.web.id
}

output "webserver_sg_id_db" {
  value = aws_security_group.db.id
}



output "private_key_db" {
  value     = tls_private_key.db.private_key_pem
  sensitive = true
}

output "key_name_db" {
  value     = aws_key_pair.generated_key_db.key_name
  
}


output "private_key_web" {
  value     = tls_private_key.web.private_key_pem
  sensitive = true
}

output "key_name_web" {
  value     = aws_key_pair.generated_key_web.key_name
  
}