# Le bloc packer {} contient les paramètres Packer, notamment la spécification de la version Packer requise
# Des plugins sont prérequis pour construire l'AMI
# Les attributs "version" et "source" sont obligatoires
# On met une condition sur la version des plugins qui est tout le temps vérifiée  

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# On crée ici les diverses variables qui vont être instanciées dans un autre script : vars.pkrvars.hcl
variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "ami_name_key" {
  type = string
}

variable "instance_type_key" {
  type = string
}

variable "region_key" {
  type = string
}

# C'est dans ce block que l'on va formater notre AMI
# Tout d'abord on renseigne les paramètres de l'AMI
# Puis dans source_ami_filter {} on spécifie à partir de quelle AMI on souhaite partir
source "amazon-ebs" "centos" {
  access_key    =  var.aws_access_key
  secret_key    =  var.aws_secret_key
  ami_name      =  var.ami_name_key
  instance_type =  var.instance_type_key
  region        =  var.region_key
  # Les 3 blocks suivants permettent de créer des volumes ebs   
  launch_block_device_mappings {
    device_name = "/dev/sdb"
    # virtual_name = "DOCKER"
    delete_on_termination = false
    volume_type = "gp2"
    volume_size = "100"
  }
  launch_block_device_mappings {
    device_name = "/dev/sdc"
    # virtual_name = "OKD_PERSISTENT"
    delete_on_termination = false
    volume_type = "gp2"
    volume_size = "40"
  }
  launch_block_device_mappings {
    device_name = "/dev/sdd"
    # virtual_name = "SWAP"
    delete_on_termination = false
    volume_type = "gp2"
    volume_size = "4"
  }
  source_ami_filter {
    filters = {
      name                = "CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4" # cette donnée se trouve directement sur AWS lorsqu'on veut créer une EC2
      # Sinon, on peut lancer une EC2 avec l'AMI en question et voir l'emplacement de l'EC2
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["aws-marketplace"] # cela correspond à où est-ce qu'on a trouvé notre name (paramètre au-dessus) 
  }
  ssh_username = "centos"
}

# C'est ici que l'on construit notre AMI
# On appelle le block supérieur où l'on a formaté notre AMI avec la commande source = []
# Le provisioner "ansible" permet d'appeler un fichier .yml depuis le provisioner
build {
  sources = [
    "source.amazon-ebs.centos"# packer construit à partir de cette source
    # "sources.amazon-ebsvolume.basic-example"
  ]
  provisioner "ansible" {
    playbook_file = "install_ssm_agent.yml" # On exécute un script qui se trouve dans le fichier install_ssm_agent.yml permettant l'installation du ssm_agent
  } 
  provisioner "shell" {
    script = "./disk.sh" # Code permettant de monter un disk et de créer un fichier dedans
  }
}








