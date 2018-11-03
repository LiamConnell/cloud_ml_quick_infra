provider "aws" {
  region     = "us-west-2"
}


resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "allow_all"
  }
}


resource "aws_eip" "ip" {
  instance = "${aws_instance.example.id}"
  provisioner "local-exec" {
    command = "echo \"alias ssh-terra='ssh -i ${var.ssh_key_private} ubuntu@${aws_instance.example.public_ip}'\" > script.sh && source script.sh && rm -rf source.sh"
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0231c1de0d92fe7a2"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids	= [
		"${aws_security_group.allow_all.id}"
			]
  key_name	= "liams_key"

  provisioner "remote-exec" {
    inline = ["sudo apt-get install python"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_private)}"
    }
  }
  provisioner "local-exec" {
    command = "echo \"alias ssh-terra='ssh -i ${var.ssh_key_private} ubuntu@${aws_instance.example.public_ip}'\" > script.sh && source script.sh && rm -rf source.sh"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.ssh_key_private} provision.yml"
  }
}
