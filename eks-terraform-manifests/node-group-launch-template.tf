# Launch Template
resource "aws_launch_template" "node_launch_template" {
  name_prefix   = "${var.cluster_name}-node-"
  image_id      = var.node_image_id != "" ? var.node_image_id : data.aws_ssm_parameter.eks_ami.value
  instance_type = var.node_instance_types[0] # For simplicity, using the first instance type from the list
  key_name      = "node-key-pair"

  iam_instance_profile {
    name = aws_iam_instance_profile.node_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.node_disk_size
      volume_type = var.node_volume_type
      delete_on_termination = true
    }
  }

  network_interfaces {
    security_groups = [aws_security_group.node_sg.id]
  }

  user_data = base64encode(<<EOT
#!/bin/bash
set -o xtrace
export AWS_DEFAULT_REGION=${var.aws_region}
/etc/eks/bootstrap.sh ${var.cluster_name} ${var.bootstrap_arguments}
  --apiserver-endpoint ${local.cluster_endpoint} \
  --b64-cluster-ca ${local.cluster_ca}
EOT
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = var.disable_imdsv1 ? "required" : "optional"
    http_put_response_hop_limit = 2
  }
}

# SSM Parameter for EKS optimized AMI
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.k8s_version}/amazon-linux-2/recommended/image_id"
}

# Auto Scaling Group
resource "aws_autoscaling_group" "node_group_asg" {
  desired_capacity = var.node_asg_desired_capacity
  max_size         = var.node_asg_max_size
  min_size         = var.node_asg_min_size
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  launch_template {
    id      = aws_launch_template.node_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-${var.node_group_name}-Node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}