resource "aws_appautoscaling_target" "target" {
  max_capacity = var.autoscaling_max
  min_capacity = var.desired_count
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  # role_arn = aws_iam_service_linked_role.autoscale.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}


resource "aws_appautoscaling_policy" "policy" {
  name = "autoscale"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.target.resource_id
  scalable_dimension = aws_appautoscaling_target.target.scalable_dimension
  service_namespace = aws_appautoscaling_target.target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_target
    scale_in_cooldown = 30
    scale_out_cooldown = 120

    predefined_metric_specification {
      predefined_metric_type = var.autoscaling_type
      # resource_label = "${aws_alb.main.arn_suffix}/${aws_alb_target_group.app.arn_suffix}"
    }
  }
}

# resource "aws_iam_service_linked_role" "autoscale" {
#   aws_service_name = "ecs.application-autoscaling.amazonaws.com"
# }
