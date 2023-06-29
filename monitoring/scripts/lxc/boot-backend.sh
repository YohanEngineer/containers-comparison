#!/bin/bash

# Lancement du service backend
echo "Lancement du service backend..."
sudo lxc-start -n backend
sudo lxc-attach -n backend -- sh -c 'nohup java -jar /usr/lib/backend-0.0.1-SNAPSHOT.jar &'

# Initialisation du temps
start_time=$(date +%s)

# Attente de la disponibilité de l'API
echo "Attente de la disponibilité du service API..."
while true; do
    if curl -s -o /dev/null -w "%{http_code}" http://10.0.3.101:1993/users | grep -q "200"; then
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
