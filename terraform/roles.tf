data "aws_caller_identity" "current" {}

resource "aws_iam_role" "snowflake_role" {
  name               = "snowflake_s3_access_role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement":
    [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {"AWS": "${data.aws_caller_identity.current.account_id}"},
        "Condition": {"StringEquals": {"sts:ExternalId": "0000"}}
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "snowflake_s3_access_policy"
  description = "Policy for Snowflake to access S3 bucket"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        Resource = [
          "arn:aws:s3:::${var.project}-${local.data_lake_bucket}/*"
        ]
      },
      {
        Effect    = "Allow",
        Action    = [
            "s3:ListBucket",
            "s3:GetBucketLocation"
        ],
        Resource  = "arn:aws:s3:::${var.project}-${local.data_lake_bucket}",
        Condition = {
          StringLike = {
            "s3:prefix": ["*"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_policy_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.snowflake_role.name
}
