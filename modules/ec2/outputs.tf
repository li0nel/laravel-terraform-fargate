output "ssh_key_path" {
  value = local.private_key_filename
}

output "instance_id" {
  value = aws_instance.vm.id
}