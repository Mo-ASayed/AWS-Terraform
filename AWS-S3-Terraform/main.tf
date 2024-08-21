provider "aws" {
  region = "us-west-2"  # Specify your desired AWS region
}

resource "random_pet" "bucket_name" {
  length = 2
}

resource "aws_s3_bucket" "example" {
  bucket = random_pet.bucket_name.id
}

resource "random_pet" "image_name" {
  length = 2
}

resource "aws_s3_bucket_object" "upload" {
  bucket = aws_s3_bucket.example.bucket
  key    = "${random_pet.image_name.id}.jpg"

  # Replace this path with the path to your local image
  source = "D:/Learning/Images/terraform_path.jpg"
}

output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "image_url" {
  value = "https://${aws_s3_bucket.example.bucket}.s3.amazonaws.com/${aws_s3_bucket_object.upload.key}"
}
