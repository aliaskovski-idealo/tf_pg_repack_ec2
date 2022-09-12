output "public_ip" {
  value = aws_instance.pg_repack_ec2_public.public_ip
}

output "public_availability_zone" {
  value = aws_instance.pg_repack_ec2_public.availability_zone
}

output "public_instance_id" {
  value = aws_instance.pg_repack_ec2_public.id
}