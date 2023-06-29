#!/bin/bash

# Vérification du nombre d'arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 image_name dockerfile_path"
    exit 1
fi

# Nom de l'image
image_name=$1

# Chemin vers le Dockerfile
dockerfile_path=$2

# Lancement de la construction de l'image Docker
echo "Construction de l'image Docker..."
start_time=$(date +%s)

podman build --no-cache -t $image_name $dockerfile_path

end_time=$(date +%s)

# Calcul du temps écoulé
time_elapsed=$((end_time - start_time))

echo "L'image Docker a été construite. Temps écoulé : $time_elapsed secondes."
