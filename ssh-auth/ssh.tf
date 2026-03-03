resource "aws_key_pair" "this" {
  key_name   = "cmtr-bgxc7tqb-keypair"
  public_key = var.ssh_key

  tags = {
    Project = "epam-tf-lab"
    ID      = "cmtr-bgxc7tqb"
  }
}