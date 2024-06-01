provider "aws" {
    access_key = #aws_access_key
    secret_key = #aws_secret_key
    region     = #bucket_region
}

# Create S3 bucket
resource "aws_s3_bucket" "bucket1" {
    bucket = # unique_bucket_name

    # Enable website hosting
    website {
        index_document = "index.html"
        error_document = "error.html"  # Optional: specify an error document
    }
}

# Upload an object to the bucket
resource "aws_s3_bucket_object" "object1" {
    depends_on = [aws_s3_bucket.bucket1]
    bucket     = aws_s3_bucket.bucket1.bucket
    key        = "index.html"
    source     = "./index.html"  
}

# Block public access to the S3 bucket (disabling all public access settings)
resource "aws_s3_bucket_public_access_block" "bucket-public-access" {
    depends_on = [aws_s3_bucket.bucket1]
    bucket     = aws_s3_bucket.bucket1.bucket
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

# Enable bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "own-change-acl-enable" {
    depends_on = [aws_s3_bucket.bucket1]
    bucket     = aws_s3_bucket.bucket1.bucket

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# Apply a policy to allow public read access to objects in the bucket
resource "aws_s3_bucket_policy" "my-policy-bucket" {
    bucket = aws_s3_bucket.bucket1.bucket
    depends_on = [
        aws_s3_bucket.bucket1,
        aws_s3_bucket_public_access_block.bucket-public-access
    ]
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "${aws_s3_bucket.bucket1.arn}/*"
            }
        ]
    })
}
