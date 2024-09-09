resource "aws_db_instance" "this" {
  allocated_storage    = var.allocated_storage
  storage_type         = "gp2"
  engine               = var.engine
  instance_class       = var.instance_class
  name                 = "mydb"
  username             = var.username
  password             = var.password
  publicly_accessible  = var.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  tags = {
    Name = "rds-instance"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [var.db_subnet_group]

  tags = {
    Name = "DB Subnet Group"
  }
}
