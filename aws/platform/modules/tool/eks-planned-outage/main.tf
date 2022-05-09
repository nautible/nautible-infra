provider "aws" {
  region = var.region
}

data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "archive/lambda_function.zip"
}

resource "random_id" "nautible_eks_node_as_update_random" {
  byte_length = 8
}

resource "aws_lambda_function" "function" {
  function_name = "nautible-eks-node-as-update"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"

  filename         = data.archive_file.function_source.output_path
  source_code_hash = data.archive_file.function_source.output_base64sha256
}

resource "aws_iam_role" "lambda_role" {
  name               = "nautible-eks-node-as-update-role-${random_id.nautible_eks_node_as_update_random.dec}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lamdba_policy_attachment1" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lamdba_policy_attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_event_rule" "nautible_eks_node_as_stop" {
  name                = "nautible-eks-node-as-stop"
  schedule_expression = var.stop_schedule
}

resource "aws_cloudwatch_event_target" "nautible_eks_node_as_update_stop" {
  rule      = aws_cloudwatch_event_rule.nautible_eks_node_as_stop.name
  target_id = "nautible-eks-node-as-update-stop"
  arn       = aws_lambda_function.function.arn
  input     = "{\"AutoScalingGroupName\": \"${var.auto_scaling_group_name}\", \"MaxSize\": \"0\", \"MinSize\": \"0\", \"DesiredCapacity\": \"0\" }"
}

resource "aws_lambda_permission" "nautible_eks_node_as_update_stop_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.nautible_eks_node_as_stop.arn
}

resource "aws_cloudwatch_event_rule" "nautible_eks_node_as_start" {
  name                = "nautible-eks-node-as-start"
  schedule_expression = var.start_schedule
}

resource "aws_cloudwatch_event_target" "nautible_eks_node_as_update_start" {
  rule      = aws_cloudwatch_event_rule.nautible_eks_node_as_start.name
  target_id = "nautible-eks-node-as-update-start"
  arn       = aws_lambda_function.function.arn
  input     = "{\"AutoScalingGroupName\": \"${var.auto_scaling_group_name}\", \"MaxSize\": \"${var.max_size}\", \"MinSize\": \"${var.min_size}\", \"DesiredCapacity\": \"${var.desired_capacity}\" }"
}

resource "aws_lambda_permission" "nautible_eks_node_as_update_start_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.nautible_eks_node_as_start.arn
}

