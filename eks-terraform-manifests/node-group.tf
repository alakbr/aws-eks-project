# Security Group for nodes
resource "aws_security_group" "node_sg" {
  name   = "${var.cluster_name}-node-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Node security group ingress/egress rules
# Nodes can talk to each other
resource "aws_security_group_rule" "node_to_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  self                     = true
  security_group_id         = aws_security_group.node_sg.id
  description              = "Allow node-to-node communication"
}

# Nodes -> Control Plane
resource "aws_security_group_rule" "node_to_cp" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.node_sg.id
  description              = "Allow pods to communicate with cluster API Server"
}

# Control plane -> Nodes
resource "aws_security_group_rule" "cp_to_nodes" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
}

resource "aws_security_group_rule" "cp_to_nodes_on_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
}

resource "aws_security_group_rule" "node_to_eks_api" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node_sg.id
  description       = "Allow nodes outbound access"
}
