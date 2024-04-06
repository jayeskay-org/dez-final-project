# Data lake bucket
resource "aws_s3_bucket" "data-lake-bucket" {
    bucket = "${var.project}-${local.data_lake_bucket}"
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
    bucket = aws_s3_bucket.data-lake-bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}
