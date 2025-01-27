# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "web_logs" {
  name = "/ecs/web-server-logs"
}

# Set up a CloudWatch Log Stream for the Web Server
resource "aws_cloudwatch_log_stream" "web_log_stream" {
  log_group_name = aws_cloudwatch_log_group.web_logs.name
  name           = "web-server-stream"
}

# CloudWatch Alarm for Web Server 5xx errors
resource "aws_cloudwatch_metric_alarm" "web_server_5xx" {
  alarm_name          = "web-server-5xx-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    LoadBalancer = var.alb-name
  }

  alarm_actions = []  # Add SNS or other actions here if needed
  ok_actions    = []  # Same for OK actions
}

# CloudWatch Alarm for Web Server instance status
resource "aws_cloudwatch_metric_alarm" "web_server_instance_health" {
  alarm_name          = "web-server-instance-health"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    InstanceId = aws_instance.web_server.id
  }

  alarm_actions = []  # Add actions as needed
  ok_actions    = []  # Add actions for when the alarm is resolved
}
