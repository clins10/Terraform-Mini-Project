# create public key pair
resource "aws_key_pair" "terra-key" {
  key_name   = "terra-key"
  public_key = tls_private_key.rsa-key.public_key_openssh
}

# create aws RSA key
resource "tls_private_key" "rsa-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# create file to store the private key
resource "local_file" "privatekey" {
  filename = "terra_privatekey"
  content  = tls_private_key.rsa-key.private_key_pem
}