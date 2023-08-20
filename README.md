# Comparaison de conteneurs

Ce guide README fournit des instructions sur la réalisation des benchmarks sur des applications web de type microservices en utilisant différentes technologies de conteneurisation, spécifiquement Docker, LXC, et Podman. Dans notre étude, nous avons testé la performance sur deux systèmes:

- Un ordinateur x86 avec un processeur à 4 cœurs et 16Go de RAM exécutant Ubuntu 22.04.
- Un Raspberry Pi 4 Model B avec 8Go de RAM, utilisant l'architecture ARM64, exécutant également Ubuntu 22.04.

Nous allons exécuter la même application, qui se compose d'une base de données, d'un backend, et d'un frontend, chacun dans un conteneur séparé.

Voici les étapes pour reproduire les benchmarks sur les deux systèmes.

## Docker

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

## LXC 

### Construction des conteneurs LXC

### Démarrage des conteneurs

### Benchmarking

## Podman

### Construction des images Podman

### Démarrage des conteneurs

### Benchmarking