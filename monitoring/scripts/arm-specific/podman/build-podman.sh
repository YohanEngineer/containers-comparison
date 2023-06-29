#!/bin/bash

# Vérification du nombre d'arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 image_name podmanfile_path"
    exit 1
fi

# Nom de l'image
image_name=$1

# Chemin vers le podmanfile
podmanfile_path=$2

# Lancement de la construction de l'image podman
echo "Construction de l'image podman..."
start_time=$(date +%s)

podman build --no-cache -t $image_name $podmanfile_path

end_time=$(date +%s)

# Calcul du temps écoulé
time_elapsed=$((end_time - start_time))

echo "L'image podman a été construite. Temps écoulé : $time_elapsed secondes."
