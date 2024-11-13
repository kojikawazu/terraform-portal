# --------------------------------------------- 
# IAMロール
# ---------------------------------------------
resource "aws_iam_role" "s3_access_role" {
  name = "${var.project}-${var.environment}-bk-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-bk-access-role"
    Environment = var.environment
    Project     = var.project
  }
}

# --------------------------------------------- 
# IAMポリシー
# ---------------------------------------------
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.project}-${var.environment}-bk-access-policy"
  description = "Policy to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = "arn:aws:s3:::${var.project}-${var.environment}-bucket/*"
      }
    ]
  })
}

# --------------------------------------------- 
# IAMポリシーをIAMロールにアタッチ
# --------------------------------------------- 
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
