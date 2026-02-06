resource "aws_s3_bucket" "tf_state" {
  bucket = "aliakber-terraform-state-backend"
  force_destroy = true
}
