#!/bin/bash

# Lancement de podman-compose
echo "Lancement du service backend..."
podman rm -f backend
podman-compose  -f /home/toto/containers-comparison/compose-pod-arm.yml up -d backend

# Initialisation du temps
start_time=$(date +%s)

# Attente de la disponibilité de l'API
echo "Attente de la disponibilité du service API..."
while true; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:1993/users | grep -q "200"; then
        break
    else
        # Pause avant de réessayer
        sleep 1
    fi
done

# Calcul du temps écoulé
end_time=$(date +%s)
time_elapsed=$((end_time - start_time))

echo "Le backend est prêt. Temps écoulé : $time_elapsed secondes."
