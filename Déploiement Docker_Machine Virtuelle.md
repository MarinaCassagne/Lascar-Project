# Déploiement du projet

## Déployer un environnement DOCKER
![alt text](docker.png)

L'**environnement** DOCKER est un environnement isolé et autonome qui encapsule une application ou un service, ainsi que toutes ses dépendances.

🛠️<u>Pré-requis :</u> 
* Installer le logiciel [Docker Desktop](https://docs.docker.com/desktop/)

### 🔵 Étapes pour créer un environnement DOCKER
1. Établir une architecture dossier client / serveur
2. Initialiser le projet
3. Établir les fichiers `Dockerfile`
4. Établir le fichier `docker-compose.yml`
5. Lancer docker compose : `docker compose up -d`

## Établir une architecture dossier client / serveur

```
Dossier <nom du projet>

  ↳ Dossier backend
    ↳ Fichier 'Dockerfile'

  ↳ Dossier frontend
    ↳ Fichier 'Dockerfile'

  ↳ Fichier docker-compose.yml

```
Le dossier backend nommé `symfony` pour notre projet LAS'CAR comprend le code source réalisé avec le framework `Symfony`.

Le dossier frontend nommé `react`pour notre projet LAS'CAR comprend le code source réalisé avec la librairie `React` et un bundler : outil de construction `Vite` pour l'affichage sur le navigateur.

Un conteneur sera créé pour chacun de ces dossiers.

## Initialiser projet

En début de projet, lancer la commande `docker init` dans chaque dossier (backend, frontend) du projet.
Ainsi 3 fichiers seront créés automatiquement : 
* Dockerfile
* .dockerignore
* compose.yaml

## Créer un fichier Dockerfile

`Dockerfile` est un fichier qui sert de support pour **créer une image personnalisée** afin de lancer des conteneurs possédant l’environnement nécessaire pour faire tourner notre application.

Dockerfile comprend des instructions en couche pour construire une image.

Ces instructions sont les suivantes *(liste non exhaustive)* :

**FROM** <image> - Cette instruction **spécifie l'image de base** à partir de laquelle la construction sera étendue. cf. [Docker Hub](https://hub.docker.com/) pour trouver l'image de base adéquate au projet.

🤔<u> Les questions à se poser :</u>
* Quel langage utilise mon projet ?
* Quelle version de ce langage ?

**WORKDIR** <chemin> - Cette instruction définit le "**répertoire de travail**", c'est-à-dire le chemin absolu dans l'image où les fichiers seront copiés et les commandes seront exécutées. 

Sur Linux, /var/www est le répertoire de travail conventionnel pour héberger les applications web servies par un serveur HTTP (Apache, Nginx). C'est pourquoi sur Symfony on écrira :
```Dockerfile
WORKDIR /var/www
```
Pour React, on utilisera par convention de conteneur Node.js :
```Dockerfile
WORKDIR /app
``` 

**COPY** <chemin-hôte> <chemin-image> - Cette instruction demande au builder de copier des fichiers depuis l'hôte et de les placer dans l'image du conteneur.
```Dockerfile
COPY . .
# Le premier point '.' correspond au chemin relatif de notre dossier courant du projet
# Le deuxième point correspond au chemin relatif de notre conteneur correspondant au final au chemin absolu renseigné dans l'instruction WORKDIR.
```

**RUN** <commande> - Cette instruction demande au builder d'exécuter la commande spécifiée.

🤔<u> Les questions à se poser :</u>
* Quelles sont les **dépendances** à installer nécessaires au fonctionnement du **système d'exploitation** (langage) ?

* Quelles sont les **dépendances** à installer nécessaires au fonctionnement de l'application ?


**EXPOSE** <numéro-de-port> - Cette instruction configure l'image pour indiquer un port que l'image souhaite exposer.
Se référer à la doc des languages/framework/librairie utilisés pour connaitre les port d'écoute par défaut. </br>
`Exemple` : </br>
[symfony](https://symfony.com/doc/current/setup.html) http://localhost:8000/ → EXPOSE 8000 </br>
react via [vite](https://vite.dev/config/server-options.html#server-port) http://localhost:5173/ → EXPOSE 5173

**CMD** ["<commande>", "<argument1>"] - Cette instruction définit la commande par défaut qu'exécutera un conteneur utilisant cette image.

🤔<u> Les questions à se poser :</u>
* Quelles sont les commandes pour installer les dépendances nécessaires au fonctionnement de l'application ?

```Dockerfile
<commande> -> npm
<argument1> -> run
<argument2> -> dev
```
❓***Définition:***
Une **image Docker** est un modèle de système, qui contient tous ce qui est nécessaire pour exécuter une application, y compris le code, les dépendances, les bibliothèques système et les fichiers de configuration.

Un **conteneur** est une instance exécutable d'une image Docker.

## Créer un fichier docker-compose.yml

Docker Compose permet de construire plusieurs images en même temps pour un même projet.

Le fichier `docker-compose.yml` permet de définir l'environnement de fonctionnement des conteneurs entre eux.

> ⚠️ Ce fichier étant un fichier `.yml`, les indentations doivent être respectées, auquel cas la construction pourrait échouer.

### Architecture du fichier

Le fichier est organisé autour de 4 **services** et d'un **volume** persistant :

---

#### `symfony` — Backend

- **build** : construit l'image depuis le dossier `./symfony` (où se trouve le `Dockerfile` Symfony)
- **ports** : expose le port `8000` (port machine hôte → port conteneur)
- **volumes** : monte le code source local dans le conteneur (`./symfony:/app`)
- **environment** : définit les variables d'environnement, notamment `DATABASE_URL` qui pointe vers le conteneur `db`
- **depends_on** : démarre uniquement après le service `db`

---

#### `react` — Frontend

- **build** : construit l'image depuis le dossier `./react`
- **ports** : expose le port `5173`, port par défaut de **Vite** (outil de dev server pour React)
- **volumes** : monte le code source et isole le dossier `node_modules` du conteneur pour éviter les conflits avec la machine hôte
- **stdin_open / tty** : maintient le terminal interactif actif (nécessaire pour que Vite reste en écoute)

---

#### `db` — Base de données MySQL

- **image** : utilise l'image officielle `mysql:8.0` (pas de `Dockerfile` custom)
- **environment** : crée automatiquement la base `lascar` avec le mot de passe `root`
- **ports** : expose le port `3306` (port standard MySQL)
- **volumes** : utilise le volume nommé `db_data` pour **persister les données** même si le conteneur est supprimé

---

#### `phpmyadmin` — Interface d'administration

- **image** : utilise l'image officielle `phpmyadmin:latest`
- **ports** : accessible depuis le navigateur sur le port `8081`
- **environment** : pointe automatiquement vers le service `db`
- **depends_on** : démarre après `db`

---

#### `volumes`
```yml
volumes:
  db_data:
```
## Intérargir avec les conteneurs

```powerShell
docker exec -it <nom_du_conteneur_php> <commande>
```

`Exemple` : pour intéragir la partie backend de Symfony :
```powerShell
docker exec -it symfony-api php bin/console
```

## Créer une Machine Virtuelle (VM)

🛠️<u>Pré-requis :</u> 
* Installer le logiciel [VirtualBox](https://www.virtualbox.org/) sur la machine local.
* Télécharger l'image ISO [Ubuntu Server](https://ubuntu.com/download/server).

### 🔵 Étapes pour créer une Machine Virtuelle

1. Ouvrir l'image ISO Ubuntu Server avec Virtual BOX
2. Établir un script d'installation nommé `install-docker.sh`
3. Établir configuration pour se connecter en SSH
4. Créer un dossier
5. Établir Docker Compose sur le serveur
6. Copier/coller le contenu du docker compose en local
7. Lancer docker compose `docker compose up -d`
8. Tester sur machine local (donc pas sur serveur)



