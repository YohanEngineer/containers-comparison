#!/bin/bash

# Lancement de podman-compose
echo "Lancement du service MySQL..."
podman-compose -f /home/toto/containers-comparison/compose-pod.yml down
podman-compose -f /home/toto/containers-comparison/compose-pod.yml up -d db

# Initialisation du temps
start_time=$(date +%s)

# Attente de la disponibilité de MySQL
echo "Attente de la disponibilité du service MySQL..."
while true; do
    if podman exec my-mysql-container mysql -p'toto' -e 'select 1' > /dev/null 2>&1; then
        break
    else
        echo 'Not ready'
        # Pause avant de réessayer
        sleep 1
    fi
done


# Calcul du temps écoulé
end_time=$(date +%s)
time_elapsed=$((end_time - start_time))

echo "Le service MySQL est prêt. Temps écoulé : $time_elapsed secondes."
