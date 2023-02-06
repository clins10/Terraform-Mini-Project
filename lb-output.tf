#load balancer output
output "elb_target_group_arn" {
  value = aws_lb_target_group.mini-proj_target_group.arn
}

output "elb_load_balancer_dns_name" {
  value = aws_lb.mini-proj_alb.dns_name
}

output "elastic_load_balancer_zone_id" {
  value = aws_lb.mini-proj_alb.zone_id
}