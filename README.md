# Comparaison de conteneurs 🛳️

Ce guide README fournit des instructions sur la réalisation des benchmarks sur des applications web de type microservices en utilisant différentes technologies de conteneurisation, spécifiquement Docker, LXC, et Podman. Dans notre étude, nous avons testé la performance sur deux systèmes:

- Un ordinateur x86 avec un processeur à 4 cœurs et 16Go de RAM exécutant Ubuntu 22.04.
- Un Raspberry Pi 4 Model B avec 8Go de RAM, utilisant l'architecture ARM64, exécutant également Ubuntu 22.04.

Nous allons exécuter la même application, qui se compose d'une base de données, d'un backend, et d'un frontend, chacun dans un conteneur séparé.

Voici les étapes pour reproduire les benchmarks sur les deux systèmes.

## Docker 🐳

### Installation de Docker

Pour installer Docker sur Ubuntu, suivez les instructions officielles [ici](https://docs.docker.com/engine/install/ubuntu/).

### Construction des images Docker

Pour construire une image Docker, il faut d'abord créer un fichier `Dockerfile` dans le répertoire de l'application. Ce fichier contient les instructions pour construire l'image Docker. Voici un exemple de `Dockerfile` avec le backend:

```dockerfile
FROM amazoncorretto:17
WORKDIR /app
COPY target/backend-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Dans ce fichier on retrouve d'abord une instruction FROM qui indique l'image de base à utiliser. Ensuite, on retrouve une instruction WORKDIR qui définit le répertoire de travail dans le conteneur. Ensuite, on retrouve une instruction COPY qui copie le fichier JAR du backend dans le répertoire de travail du conteneur. Enfin, on retrouve une instruction ENTRYPOINT qui définit la commande à exécuter lorsque le conteneur est démarré.

La construction de l'image se fait de manière assez similaire sur les deux architectures à la différence près que pour l'ARM on va utiliser la commande <b>buildx</b> en lieu et place de <b>build</b>.
#### Sur X86

On se place d'abord dans à la racine du projet puis on lance les commandes suivantes:

```shell
cd frontend/
docker build -t yohanengineer/frontend-thesis:1.0.0 .
docker push yohanengineer/frontend-thesis:1.0.0
cd ..
cd backend/
docker build -t yohanengineer/backend-thesis:1.0.0 .
docker push yohanengineer/backend-thesis:1.0.0
cd ..
cd db/
docker build -t yohanengineer/db-thesis:1.0.0 .
docker push yohanengineer/db-thesis:1.0.0
```

La commande de push permet de pousser l'image sur [DockerHub](https://hub.docker.com/u/yohanengineer) dans les répertoires dédiés créés au préalable sur le site.

A savoir que la construction de l'image db ne sera pas nécessaire si on utilise une base de données déjà existante que l'on agrémente de paramètre dans un docker-compose (choix qui a été fait).
#### Sur ARM64

On se place d'abord dans à la racine du projet puis on lance les commandes suivantes:

```shell
docker buildx create --name mybuildeer
docker buildx use mybuildeer
docker buildx inspect --bootstrap
docker buildx build --platform linux/arm64 -t yohanengineer/backend-thesis:1.0.0-arm64 . --push
docker buildx build --platform linux/arm64 -t yohanengineer/frontend-thesis:1.0.0-arm64 . --push
docker buildx build --platform linux/arm64 -t yohanengineer/db-thesis:1.0.0-arm64 . --push
```

On instancie d'abord un builder puis on l'utilise. On inspecte ensuite le builder pour vérifier qu'il est bien utilisé. Enfin, on construit les images en spécifiant la plateforme ARM64 et on les pousse sur DockerHub.

### Démarrage des conteneurs

Pour simplifier l'usage de trois conteneurs en même temps qui fonctionnent de pair, on va utiliser un docker-compose. Pour cela, on va créer un fichier [`compose.yml`](https://github.com/YohanEngineer/containers-comparison/blob/main/compose.yml) dans le répertoire de l'application. Ce fichier contient les instructions pour démarrer les conteneurs. Le fichier Docker compose doit définir trois services: `backend`, `frontend`, et `db`. Chaque service utilisera l'image respective construite précédemment à l'exception de la base de données.

On se place à la racine du projet puis on lance ensuite la commande suivante pour démarrer les conteneurs:

```shell
docker-compose -f compose.yml up --detach
```

ou

```shell
docker-compose -f compose-arm.yml up --detach
```

selon l'architecture utilisée.


### Benchmarking

*Toutes ces commandes sont réalisées en étant à la racine du projet.*

Pour mesurer le temps de construction d'une image Docker, On utilise le script [`build.sh`](https://github.com/YohanEngineer/containers-comparison/blob/main/monitoring/scripts/build.sh) qui permet de construire les images en indiquant le nom de l'image et le chemin du Dockerfile. On lance donc la commande suivante pour construire l'image du backend par exemple:

```shell
sh monitoring/scripts/build.sh yohanengineer/backend-thesis:1.0.0 backend/Dockerfile
```


Pour mesurer le temps de démarrage d'un conteneur Docker, on utilise les scripts suivants (boot-backend.sh, boot-front.sh, boot-sql.sh). On lancera donc la commande suivante pour le backend par exemple :

```shell
sh monitoring/scripts/boot-backend.sh
```

Pour mesurer la latence des trois applications, on utilise la commande suivante:

```shell
sh monitoring/scripts/latency.sh
```



## LXC 📦

### Construction et démarrage des conteneurs LXC

La construction des conteneurs sur LXC se fait de manière moins aisée et bien plus manuelle. Le démarrage va de pair avec la construction. 

Pour créer le backend, il faut lancer les commandes suivantes : 

```shell
sudo lxc-create -t download -n backend -- -d ubuntu -r focal -a arm64
sudo lxc-start -n backend
sudo lxc-attach -n backend
cd /usr/lib/
wget https://corretto.aws/downloads/resources/17.0.7.7.1/amazon-corretto-17.0.7.7.1-linux-aarch64.tar.gz
# Décommenter pour AMD64
# curl -LO https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz
tar -xvf amazon-corretto-17.0.7.7.1-linux-aarch64.tar.gz
nano ~/.bashrc
export JAVA_HOME=/usr/lib/amazon-corretto-17.0.7.7.1-linux-aarch64
export PATH=$JAVA_HOME/bin:$PATH
source ~/.bashrc
curl -LJO https://github.com/YohanEngineer/containers-comparison/releases/download/test/backend-0.0.1-SNAPSHOT.jar
java -jar backend-0.0.1-SNAPSHOT.jar
sudo lxc-stop -n backend
```

Pour créer le frontend, il faut lancer les commandes suivantes : 

```shell
sudo lxc-create -t download -n frontend -- -d ubuntu -r focal -a arm64
sudo lxc-start -n frontend
sudo lxc-attach -n frontend
apt-get install -y curl
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs
mkdir -p /usr/src/app
cd /usr/src/app
apt install git
git clone https://github.com/YohanEngineer/containers-comparison.git
cd frontend/
npm install 
npm start
```

Pour créer la base de données, il faut lancer les commandes suivantes : 


```shell
sudo lxc-create -t download -n bd -- -d ubuntu -r focal -a arm64
sudo lxc-start -n bd
sudo lxc-attach -n bd
apt-get update
apt-get install -y mysql-server
service mysql start
nano /etc/mysql/mysql.conf.d/mysqld.cnf
# Set bind-address = 0.0.0.0
service mysql restart
mysql -u root
# Lancer les commandes suivantes 
CREATE USER 'toto'@'%' IDENTIFIED BY 'toto';
GRANT ALL PRIVILEGES ON *.* TO 'toto'@'%';
FLUSH PRIVILEGES;
create database testdb;
CREATE TABLE users (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(255),
  email VARCHAR(255),
  PRIMARY KEY (id)
);
```

Pour que les trois conteneurs puissent communiquer entre eux, il est nécessaire de configurer le réseau. Pour se faire, on doit se connecter dans chaque conteneur et modifier le fichier de configuration netplan en ajoutant les lignes suivantes:

```shell
apt install nano
sudo nano /etc/netplan/10-lxc.yaml : 
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [10.0.3.100/24]
      gateway4: 10.0.3.1
      nameservers:
        addresses: [8.8.8.8]

sudo netplan apply
```

Les addresses doivent être différentes pour chaque conteneur :
- db : 10.0.3.100
- backend : 10.0.3.101
- frontend : 10.0.3.102

Pour rendre le frontend accessible depuis l'extérieur, il faut modifier la configuration réseau de la machine hôte :

```shell
sudo nano /etc/sysctl.conf
# décommenter cette ligne : net.ipv4.ip_forward=1
sudo sysctl -p
sudo iptables -t nat -A PREROUTING -p tcp --dport 3000 -j DNAT --to-destination 10.0.3.102:3000
sudo iptables -A OUTPUT -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
```	

### Benchmarking

Afin de mesurer le temps de démarrage des conteneurs, on utilise les scripts suivants (boot-backend.sh, boot-frontend.sh, boot-bd.sh). On lancera donc la commande suivante pour le backend par exemple :

```shell
sh monitoring/scripts/lxc/boot-backend.sh
```

Pour mesurer la latence des trois applications, on utilise la commande suivante:

```shell
sh monitoring/scripts/lxc/latency.sh
```

## Podman 🦦

### Installation de Podman

Pour installer Podman sur Ubuntu, suivez les instructions officielles [ici](https://podman.io/getting-started/installation).

Sur ARM64, il faut installer Podman avec la commande suivante:

```shell
sh install-podman.sh
```
### Construction des images Podman

La construction des images avec Podman est très similaire à celle de Docker, pour cause l'outil Podman est un fork de Docker. La seule différence est qu'il faut utiliser la commande `podman` au lieu de `docker`.

On a aussi créé des fichiers Containerfile pour chaque application. Ces fichiers sont similaires aux Dockerfile mais avec une syntaxe légèrement différente. Voici un exemple de `Containerfile` avec le backend:

```dockerfile
FROM docker.io/amazoncorretto:17
WORKDIR /app
COPY target/backend-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```	

La seule différence avec le Dockerfile est la première ligne qui indique l'image de base à utiliser. En effet, il faut préciser le registre d'image utilisé.
### Démarrage des conteneurs

En ce qui concerne le démarrage des conteneurs on utilise [`podman-compose`](https://github.com/containers/podman-compose) qui est l'équivalent de `docker-compose` pour Podman. On se place à la racine du projet puis on lance la commande suivante pour démarrer les conteneurs:

```shell
podman-compose -f compose-pod.yml up --detach
```

ou

```shell
podman-compose -f compose-pod-arm.yml up --detach
```

selon l'architecture utilisée.

### Benchmarking

*Toutes ces commandes sont réalisées en étant à la racine du projet.*

Pour mesurer le temps de construction d'une image Podman, On utilise le script [`build-podman.sh`](https://github.com/YohanEngineer/containers-comparison/blob/main/monitoring/scripts/podman/build-podman.sh) qui permet de construire les images en indiquant le nom de l'image et le chemin du Containerfile. On lance donc la commande suivante pour construire l'image du backend par exemple:

```shell
sh monitoring/scripts/podman/build-podman.sh yohanengineer/backend-thesis:1.0.0 backend/Containerfile
```


Pour mesurer le temps de démarrage d'un conteneur Podman, on utilise les scripts suivants (boot-backend.sh, boot-front.sh, boot-sql.sh). On lancera donc la commande suivante pour le backend par exemple :

```shell
sh monitoring/scripts/podman/boot-backend.sh
```

Pour mesurer la latence des trois applications, on utilise la commande suivante:

```shell
sh monitoring/scripts/podman/latency.sh
```



## Benchmarking des performances

Les mesures de performances CPU et mémoire ont été réalisées à l'aide de cAdvisor, Prometheus et Grafana.

### Installation de cAdvisor

cAdvisor est installée sur la machine hôte.

Pour installer cAdvisor, on va sur la page de [release](https://github.com/google/cadvisor/releases) Github du projet pour télécharger les binaires.

On peut ensuite lancer cAdvisor avec la commande suivante:

```shell
sudo ./cadvisor
```

Pour accéder à l'interface web de cAdvisor, il faut se rendre sur l'adresse suivante: http://localhost:8080

### Installation de Prometheus et Grafana

Prometheus et Grafana sont installés dans un conteneur Docker sur une autre machine que la machine de test.

Pour installer Prometheus et Grafana, on va utiliser Docker. On se place à la racine du projet puis on lance la commande suivante:

```shell
docker-compose -f monitoring/compose.yml up --detach
```

Dans le dossier monitoring/docker/prometheus se trouve la configuration pour scraper les données exposées par cAdvisor.

La marche à suivre pour utiliser Grafana est explicitée sur ce [site](https://blog.eleven-labs.com/fr/monitorer-ses-containers-docker/).

### Charge du système

Afin de charger le système et de pouvoir observer les performances, on utilise jmeter. 

La procédure d'installation est disponible [ici](https://jmeter.apache.org/usermanual/get-started.html#running).

On charge ensuite les conteneurs en envoyant des milliers de requêtes de manière simultanée.

Une autre manière de faire est d'utiliser le script load.py qui permet de lancer des requêtes en parallèle. Pour l'utiliser, il faut lancer la commande suivante:

```shell
python3 monitoring/scripts/load.py
```

### IOPS 

Pour mesurer les performances d'IOPS, on utilise l'outil fio qu'il faut installer en se connectant directement dans les conteneurs. 

Pour installer fio, on lance les commandes suivantes:

```shell
sudo apt-get update
sudo apt-get install fio
```

On peut ensuite lancer les tests avec la commande suivante:

#### Ecriture
```shell
fio --name=writefile --size=2G --filesize=2G --ioengine=libaio --rw=write --bs=1M --numjobs=1 --time_based --runtime=30s --end_fsync=1
```
#### Lecture

```shell
fio --name=readfile --size=2G --filesize=2G --ioengine=libaio --rw=read --bs=1M --numjobs=1 --time_based --runtime=30s --end_fsync=1
```