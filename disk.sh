sudo mkfs.ext4 /dev/nvme1n1 # FORMATER ET CRÉER UN SYSTÈME DE FICHIERS EXT4
sudo mkdir /mnt/disk1 # On crée un fichier disk1
sudo mount /dev/nvme1n1 /mnt/disk1 # On rattache le disk à notre système
sudo mkdir /mnt/disk1/Exercice4 # On crée le fichier Exercice4