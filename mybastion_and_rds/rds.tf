resource "aws_rds_cluster" "my-test-rds-cluster-dev" {
  cluster_identifier  = "my-test-rds-cluster-dev"
  engine              = "aurora-mysql"
  engine_version      = "5.7.12"
  database_name       = "mytestdb"
  master_username     = "myuser"
  master_password     = "mypassword"
  db_cluster_parameter_group_name = "customized-aurora-mysql57"

  skip_final_snapshot = true
  vpc_security_group_ids     = ["${aws_security_group.my-aurora-sg.id}"]
  snapshot_identifier             = "my-test-rds-cluster-dev-snapshot-20200504"
#   lifecycle {
#     prevent_destroy = true
#   }
}

resource "aws_rds_cluster_instance" "my-test-rds-instance-dev" {
  count               = 1
  identifier          = "my-test-rds-cluster-dev${count.index}"
  cluster_identifier  = aws_rds_cluster.my-test-rds-cluster-dev.id
  engine              = "aurora-mysql"
  engine_version      = "5.7.12"
  instance_class      = "db.t2.small"
  publicly_accessible = false
  db_parameter_group_name = "customized-aurora-mysql57"
#   db_parameter_group_name = "my-aurora-mysql57"
#   vpc_security_group_ids = ["${aws_security_group.my-aurora-sg.id}"]
#   lifecycle {
#     prevent_destroy = true
#   }
}

resource "aws_rds_cluster_endpoint" "my-test-rds-instance-dev-read-replica" {
  cluster_identifier  = aws_rds_cluster.my-test-rds-cluster-dev.id
  cluster_endpoint_identifier = "my-test-rds-instance-ro-dev"
  custom_endpoint_type        = "READER"

  excluded_members = [
    "${aws_rds_cluster_instance.my-test-rds-instance-dev.0.id}",
  ]
}

# resource "aws_rds_cluster" "my-test-rds-cluster-dev-read-replica" {
#   cluster_identifier              = "my-test-rds-cluster-dev-read-replica"
#   engine                          = "aurora-mysql"
#   engine_version                  = "5.7.12"
#   database_name       = "mytestdb"
#   master_username     = "myuser"
#   master_password     = "mypassword"
# #   db_subnet_group_name            = "my-main"
# #   db_cluster_parameter_group_name = "my-aurora-mysql57"
#   vpc_security_group_ids     = ["${aws_security_group.my-aurora-sg.id}"]
#   # "snapshot_identifier" is needed for this operation:
# #   snapshot_identifier             = "need-snapshot???"
#   skip_final_snapshot             = true
#     snapshot_identifier             = "my-test-rds-cluster-dev-snapshot-20200504"
# }

# resource "aws_rds_cluster_instance" "my-test-rds-cluster-dev-read-replica" {
#   count                   = 1
#   identifier              = "my-test-rds-cluster-dev-read-replica"
#   cluster_identifier      = "${aws_rds_cluster.my-test-rds-cluster-dev-read-replica.id}"
#   engine                  = "aurora-mysql"
#   engine_version          = "5.7.12"
#   instance_class          = "db.t2.small"
# #   db_subnet_group_name            = "my-main"
# #   db_parameter_group_name = "my-aurora-mysql57"
#   publicly_accessible     = true
# }


resource "aws_security_group" "my-aurora-sg" {
  name   = "aurora-security-group"
  vpc_id = "${aws_default_vpc.default.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}
