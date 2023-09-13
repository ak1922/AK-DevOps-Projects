output "BastionHost-privateIP" {
  value = aws_instance.ApacheApp-BastionHost.private_ip
}

output "BastionHost-publicIP" {
  value = aws_instance.ApacheApp-BastionHost.public_ip
}