#!/bin/bash

# Lancement de docker-compose
echo "Lancement du service MySQL..."
docker-compose up -f compose-arm.yaml -d db

# Initialisation du temps
start_time=$(date +%s)

# Attente de la disponibilité de MySQL
echo "Attente de la disponibilité du service MySQL..."
while true; do
    if docker-compose exec -T mysql mysqladmin ping --silent; then
        break
    else
        # Pause avant de réessayer
        sleep 1
    fi
done

# Calcul du temps écoulé
end_time=$(date +%s)
time_elapsed=$((end_time - start_time))

echo "Le service MySQL est prêt. Temps écoulé : $time_elapsed secondes."
