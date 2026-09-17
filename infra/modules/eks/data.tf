data "aws_iam_session_context" "current" {
  arn = var.caller_arn
}
