resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [var.security_group]

  tags = {
    Name = "app-instance"
  }
}

output "instance_id" {
  value = aws_instance.this.id
}
