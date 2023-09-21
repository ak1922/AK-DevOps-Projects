output "BastionHost-privateIP" {
  value = aws_instance.ApacheApp-BastionHost.private_ip
}

output "BastionHost-publicIP" {
  value = aws_instance.ApacheApp-BastionHost.public_ip
}

output "LoadBalancerURL" {
  value = aws_lb.ApacheApp-LoadBalancer.dns_name
}