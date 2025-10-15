# Standard outputs for vm-fleet compute type
output "instance_ips" {
  description = "Private IP addresses of VM instances"
  value       = data.aws_instances.vm_fleet.private_ips
}

output "loadbalancer_ip" {
  description = "Public DNS name of the load balancer"
  value       = aws_lb.vm_fleet.dns_name
}

output "ssh_private_key" {
  description = "SSH private key for accessing instances"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "ssh_username" {
  description = "SSH username for Ubuntu instances"
  value       = "ubuntu"
}