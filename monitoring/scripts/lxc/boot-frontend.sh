#!/bin/bash

# Lancement du service frontend
echo "Lancement du service frontend..."
sudo lxc-start -n frontend

# Lancement de l'application Node.js
echo "Lancement de l'application Node.js..."
sudo lxc-attach -n frontend -- sh -c '/usr/bin/env node /usr/src/app/server.js'

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
