#!/bin/bash

# Nombre de tests
NUM_TESTS=5

# Container 3 (MySQL)
CONTAINER3_IP=10.0.3.100

echo "Mesure de la latence réseau pour le MySQL:"
total_time=0
for i in $(seq $NUM_TESTS); do
    start_time=$(date +%s%N)
    mysql -h $CONTAINER3_IP -P 3306 -u toto -ptoto -e 'SELECT 1;' > /dev/null 2>&1
    end_time=$(date +%s%N)
    execution_time=$((end_time-start_time))
    total_time=$((total_time+execution_time))
done
average_time=$(echo "scale=9; $total_time/($NUM_TESTS*1000000000)" | bc)
echo "bd :  La latence moyenne est: $average_time secondes."


# Container 1
CONTAINER1_IP=10.0.3.101

echo "Mesure de la latence réseau pour le backend container:"
total_time=0
for i in $(seq $NUM_TESTS); do
    start_time=$(date +%s%N)
    curl -s $CONTAINER1_IP:1993/users > /dev/null
    end_time=$(date +%s%N)
    execution_time=$((end_time-start_time))
    total_time=$((total_time+execution_time))
done
average_time=$(echo "scale=9; $total_time/($NUM_TESTS*1000000000)" | bc)
echo "back : La latence moyenne est: $average_time secondes."

# Container 2
CONTAINER2_IP=10.0.3.102

echo "Mesure de la latence réseau pour le frontend container:"
total_time=0
for i in $(seq $NUM_TESTS); do
    start_time=$(date +%s%N)
    curl -s $CONTAINER2_IP:3000 > /dev/null
    end_time=$(date +%s%N)
    execution_time=$((end_time-start_time))
    total_time=$((total_time+execution_time))
done
average_time=$(echo "scale=9; $total_time/($NUM_TESTS*1000000000)" | bc)
echo "front : La latence moyenne est: $average_time secondes."

