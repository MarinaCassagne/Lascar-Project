# Etablir un script d'installation pour déployer sur un serveur

# Va dans /usr/bin.env pour lancer des commandes bash
!/usr/bin.env bash
# si erreur quitter le script
# -euo -e quitter -u définir une variable -o outpout 
set -euo pipefail

echo "[1/6] Update packages..."

# mise à jour du système
sudo apt-get update -y 
# installer les pré-requis
# curl permet de lancer des requêtes
# gpg gérer les signatures des clés gpg
# lsb permet identifier la version ubuntu pour téleécharger package
# ca valdiation ssl avec ç on peut se connecter en httpps
echo "[2/6] Install prerequistes..."
sudo apt-get instqll -y ca-certificates curl

echo "[3/6] Add Docker official GPG Key..."
# install -m créer un fichier
# 0755 permission de modificationdu du fichier (lire écrire..)
# -d endroit où fichier est placé
sudo install -m 0755 -d /etc/apt/keyrings
#télécherger le fichier de configuration du téléchargement de docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings
sudo chmod a+r /etc/apt.keyrings/docker.gpg

echo "[4/6] Add Docker repository..."
# Configurationde quoi depend docker pour fonctionner sur mon écran
# ARCH rendre le script multi architecture
# Adapter notre script à n'importe quelle version
ARCH="$(dpkg --print-architecture)"
# CODENAME permet de détecter les bonnes versions ubuntu
CODENAME="$(. /etc/os-release $$ echo "$VERSION_CODENAME")"
echo \
  "deb [arch=${ARCH} siged_by=/etc/apt/kerings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" |
  sudo tee /etc/apt/source.list.d/docker.list > /dev/null

echo "[5/6] Install Docker Engine + Compose..."
# Mettre à jour mon système au cas si la première fois la ça ne marche pas
sudo apt-get update -y
# Installation de Docker
# containered.io permet de suivre le cycle de vie d'un conteneur
sudo apt-get install -y docker-ce docker-ce-cli containered.io docker-builds-plugin docker-compose-plugin

# Activer Docker
echo "[6/6] Enable Docker + add current user to docker group. "
sudo systemctl enable --now docker
sudo usermod -aG "$USER"

echo
echo "Docker installed"

