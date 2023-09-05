# EC2_Automatisation_AWS
This repository is dedicated to the automatisation of the creation of EC2 instances on AWS. Such instances will be already pre-configured and pre-mounted with files and folders.

## Exercice 1
</br>

Le but de l'exercice 1 est de créer une nouvelle AMI sur AWS à l’aide de l’outil Packer. Cette AMI devra partir de l’AMI **ami-262e9f5b** et devra contenir un dossier nommé exercice1 dans le dossier */tmp*. Une fois l’AMI créé il faudra provisionner  une Vm  via la console  AWS et vérifier que le dossier */tmp/exercice1* existe bien dans la VM.

L'exercice va se décomposer en 2 parties : une partie concernant l'implémentation d'une AMI et une autre partie concernant la vérification de la présence du dossier en question.</br>
</br>

### Partie 1

</br>
Tout d'abord, on doit installer la librairie "Packer". Pour cela, on peut se rendre sur ce [lien](https://www.packer.io/downloads) où se trouve un fichier zip de Packer. Pour unzip le fichier, on peut le faire manuellement ou à l'aide de ligne de code.
</br>
</br>
Packer est un outil open source utilisé qui permet de créer des images machine pour plusieurs plates-formes à partir d'une configuration source unique. Il reste un outil léger qui fonctionne sur tous les principaux systèmes d'exploitation. Il crée donc essentiellement des images prêtes à l'emploi avec le système d'exploitation et les logiciels supplémentaires.
</br>
</br>
Maintenant il suffit de rajouter votre exécutable Packer à votre variable d'environnement nommée
`PATH`, c'est la variable système utilisée par Windows pour localiser les fichiers exécutables, ainsi vous pourrez exécuter le programme Packer depuis n'importe où en ligne de commande.
</br>
</br>
Pour cela, on va "Modifier les variables d'environnement système" depuis le menu "Démarrer" de l'ordinateur. Puis, on va modifier la variable système "Path" en lui ajoutant le chemin du dossier où se trouve le binaire **packer.exe**.

Pour vérifier que packer est bien installé, on peut directement taper la ligne de code :
```sh
$ packer
```
dans la commande (des informations concernants packer devrait apparaître).

On va par la suite initialiser le packer avec la commande :
```sh
$ packer init .
```
Enfin, on va devoir renseigner le fichier [vars.pkvars.hcl]() avec les paramètres suivants :
- "aws_access_key"
- "aws_secret_key"
- "region_key", la région où on souhaite héberger notre AMI
- "ami_name_key", correspondant au nom que l'on souhaite attribuer à de notre AMI
- "instance_type_key", le type d'instance
</br>
</br>
On est enfin prêt pour lancer notre AMI. On a juste à écrire la commande suivante :
```sh
$ packer build --var-file=vars.pkrvars.hcl final.pkr.hcl
```
Si aucune erreur n'apparaît et que le message **Builds finished** s'affiche cela signifie que l'AMI a été construite. Pour aller le vérifier, on doit se rendre sur notre compte AWS et dans les AMI, on retrouve notre AMI !

Si vous avez des difficultés, je vous invite à vous renseigner sur les sites suivants :
- Pour l'installation de Packer : https://devopssec.fr/article/decouverte-utilisation-packer
- Pour le code :
    https://learn.hashicorp.com/tutorials/packer/aws-get-started-build-image?in=packer/aws-get-started

    https://www.packer.io/docs/builders/amazon/ebs
</br>
</br>

### Partie 2
</br>
Dans cette partie, nous allons voir comment vérifier que notre AMI contient bien notre dossier que l'on a créé à partir d'un code "shell".
Pour cela, il suffit de créer une EC2 à partir de notre AMI sur la console AWS puis de s'y connecter et de voir si notre fichier est présent.
</br>
</br>
S'il y a un bug lorsqu'on souhaite se connecter à l'EC2, il faut passer par PuTTY. En effet, il nous faudra nous rendre tout d'abord dans l'Apache (qui se trouve en ligne) puis dans la machine Pilote (private) qui permet d'avoir accès à l'ensemble des Vm. Enfin, en utilisant un chemin ssh on va se rendre sur notre EC2 en rentrant l'adresse IP privée communiquée par la console AWS lorsque l'on a créé notre EC2 à partir de notre AMI.
</br>
</br>

## Exercice 2
</br>
Le but de l'exercice 2 est de remplacer le script de création du dossier /tmp/exercice1 par un script permettant l’installation d'un gestionnaire sur la VM. Pour installer ce gestionnaire, on a consulté la documentation Guide Patch Management qui explique dans un premier temps le script shell à introduire dans le "provisioner" de packer. Puis, dans un second temps, le guide explique les manipulations à réaliser directement sur la console AWS.
</br>
</br>
Tout  d'abord, la partie code a été simplifiée dans notre cas de figure (voir le script "install_ssm_agent.sh"), puisqu'au lieu d'aller récupérer le fichier "amazon-ssm-agent.rpm" dans la factory, on l'installe directement.
</br>
</br>
Enfin, concernant la partie manipulation, même si on ne retrouve pas les mêmes actions sur notre console (peut-être parce qu'on est sur un rôle différent et pas sous la bonne souscription), le guide explique plutôt bien ce qu'il faut réaliser.
</br>
</br>

## Exercice 3
</br>
L'exercice 3 avait pour objectif de remplacer le script shell d’installation du System Manager Gestionnaire écrit en Shell (exercice 2) par un Script Ansible.</br>
</br>
Pour cela, il a fallu changer le type du "provisioner" par "ansible". Le provisioner de packer prend la méthode :

```sh
$ playbook_file = "install_ssm_agent.yml"
```

Cela permet d'appeler le fichier YML depuis le provisioner. Dans le fichier "install_ssm_agent.yml", il est écrit le code Ansible qui permet d'installer le Amazone SSM Agent directement sur la Vm.
</br>
</br>

## Exercice 4
</br>
Dans cet exercice, nous allons créer des volumes ebs directement sur notre AMI afin d'avoir une EC2, une fois lancée, avec des disks pré-formatés. Pour cela, nous utilisons la méthode "launch_block_device_mappings" qui se trouve dans le block source{} et qui permet de prendre des snapshots des volumes instanciés. Cette méthode permet de spécifier le chemin de notre volume (qui correspond en réalité à l'ordre dans lequel Packer va créer les disks), le type et la taille du volume, ainsi que de déterminer si l'on souhaite supprimer le volume dès lors que l'EC2 est fermée (avec l'argument "delete_on_termination"). On peut aussi associer des titres aux différents disks en lui ajoutant des tags.

Une fois, les disks créés nous allons les formater et les peupler à l'aide d'un code shell (on pourra par la suite remplacer ce code shell par un code Ansible). Ce code shell ("disk.sh")est directement appeler depuis le block build{} à partir du "provisioner" de Packer. Dans ce code shell, tout d'abord on formate et créer un système de fichiers sur le disk en question, puis on le peuple en lui ajoutant des dossiers.

On peut vérifier que l'on a correctement créer et peupler ces disks en se connectant directement sur la Vm et en tapant la commande suivante :
```sh
$ lsblk
```
Cette commande permet de visualiser les disks présents sur la Vm. Enfin, il ne nous reste plus qu'à monter le disk pour avoir accès aux fichiers que l'on a pré-installé depuis le fichier shell "disk.sh" avec la commande :
```sh
$ sudo mount /dev/nvme1n1 /mnt/disk1
```
NB : Il y a tout de fois une erreur incompréhensible entre packer et l'EC2 crée. En effet, les disks créés entre packer et l'EC2 ne possèdent pas les mêmes chemins. Dès lors, lorsque l'on souhaite monter le même disk depuis l'EC2 que celui monter depuis Packer, il nous faut adapter la commande supérieure avec le chemin adéquat.
