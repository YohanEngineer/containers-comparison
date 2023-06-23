#!/bin/bash

# Lancement de docker-compose
echo "Lancement du service frontend..."
docker-compose up -f compose-arm.yaml -d frontend

# Initialisation du temps
start_time=$(date +%s)

# Attente de la disponibilité du frontend
echo "Attente de la disponibilité du service frontend..."
while true; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
        break
    else
        # Pause avant de réessayer
        sleep 1
    fi
done

# Calcul du temps écoulé
end_time=$(date +%s)
time_elapsed=$((end_time - start_time))

echo "Le service frontend est prêt. Temps écoulé : $time_elapsed secondes."
