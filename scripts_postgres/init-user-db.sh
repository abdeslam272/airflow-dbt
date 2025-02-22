# 1. Build your images
docker-compose build

# 2. Start the containers
docker-compose up -d

# 3. Initialize the Airflow database (only once)
docker exec -it airflow-webserver airflow db init

# 4. Create an Airflow user (if needed)
docker exec -it airflow-webserver airflow users create \
    --username admin \
    --firstname First \
    --lastname Last \
    --role Admin \
    --email admin@example.com \
    --password admin