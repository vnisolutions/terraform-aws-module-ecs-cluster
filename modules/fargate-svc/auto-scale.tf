resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.max_scale
  min_capacity       = var.min_scale
  resource_id        = "service/${var.cluster_name}/${var.cluster_name}-${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "memory_policy" {
  name               = "${var.cluster_name}-${var.service_name}-memory-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.target_scale_mem
  }
}

resource "aws_appautoscaling_policy" "cpu_policy" {
  name               = "${var.cluster_name}-${var.service_name}-cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.target_scale_cpu
  }
}

resource "aws_appautoscaling_policy" "memory_policy_custom" {
  name               = "${var.cluster_name}-${var.service_name}-memory-policy-custom"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "cpu_policy_custom" {
  name               = "${var.cluster_name}-${var.service_name}-cpu-policy-custom"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_usage_high" {
  alarm_name          = "${var.cluster_name}-${var.service_name}-cpu-usage-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60" // in seconds
  statistic           = "Maximum"
  threshold           = "65" // in %
  alarm_description   = "This metric monitors the cluster for high CPU usage"
  alarm_actions = [
    aws_appautoscaling_policy.cpu_policy_custom.arn
  ]
  dimensions = {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${var.service_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_usage_high" {
  alarm_name          = "${var.cluster_name}-${var.service_name}-memory-usage-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60" // in seconds
  statistic           = "Maximum"
  threshold           = "65" // in %
  alarm_description   = "This metric monitors the cluster for high CPU usage"
  alarm_actions = [
    aws_appautoscaling_policy.memory_policy_custom.arn
  ]
  dimensions = {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${var.service_name}"
  }
}