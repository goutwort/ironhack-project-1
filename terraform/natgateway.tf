resource "aws_eip" "tiffany_nat_gateway" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "tiffany_nat_gateway" {
  allocation_id = aws_eip.tiffany_nat_gateway.id
  subnet_id = aws_subnet.tiffany_public_subnet_1.id
  tags = {
    "Name" = "tiffany-DummyNatGateway"
  }
  depends_on = [aws_eip.tiffany_nat_gateway]
}