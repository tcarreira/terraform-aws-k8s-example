
resource "aws_db_subnet_group" "eks" {
  name       = "main"
  subnet_ids = aws_subnet.eks[*].id

  tags = {
    Name = "EKS Database Subnet"
  }
}

resource "aws_db_instance" "commentapi" {
  identifier_prefix      = "commentapi"
  engine                 = "postgres"
  engine_version         = "11.8"
  instance_class         = "db.t2.micro"
  storage_type           = "gp2"
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_subnet_group_name   = aws_db_subnet_group.eks.id
  vpc_security_group_ids = [aws_security_group.eks-cluster.id]
  # multi_az = true

  backup_retention_period = 7
  backup_window           = "05:00-06:00"         # UTC 
  maintenance_window      = "Mon:06:15-Mon:07:00" # UTC 

  name     = var.POSTGRES_DB
  username = var.POSTGRES_USER
  password = var.POSTGRES_PASSWORD
}
