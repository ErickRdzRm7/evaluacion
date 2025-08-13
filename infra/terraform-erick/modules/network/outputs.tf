output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}
output "public_route_table_id" {
  value = aws_route_table.public.id
}
output "ecs_sg_frontend_id" {
  value = aws_security_group.ecs_sg_frontend.id
}