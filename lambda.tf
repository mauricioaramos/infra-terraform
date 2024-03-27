#data "archive_file" "lambda_code" {
#  type        = "zip"
#  source_dir  = "main"
#  output_path = "lambda_function"
#}

#resource "aws_lambda_function" "lambda" {
#  filename      = data.archive_file.lambda_code.output_path
#  function_name = "lambda_function"
#  role          = aws_iam_role.lambda_role.arn
#  handler       = "main.handler"
#  runtime       = "java11"
#  timeout       = 60
#  memory_size   = 128
#}
