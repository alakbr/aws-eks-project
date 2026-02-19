resource "aws_s3_bucket" "tf_state" {
  bucket        = "aliakber-terraform-state-backend2"
  force_destroy = true
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "node-key-pair"
  public_key = file("node-key-pair.pub")
}