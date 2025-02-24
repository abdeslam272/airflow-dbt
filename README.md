# airflow-dbt

https://github.com/konosp/dbt-airflow-docker-compose/blob/master/docker-compose.yml


Introduction

This project sets up a sample environment using Docker, Airflow, dbt, and PostgreSQL. Each service runs in its own container, allowing for an isolated and reproducible development setup.


In the docker compose we got this services :
Postgres for Airflow on the ports 5433:5432
Postgres for dbt on the ports 5434:5432
airflow-webserver on the ports 8080:8080 Build on the dockerfile when we install dbt-core dbt-postgres
airflow-scheduler Build on the dockerfile when we install dbt-core dbt-postgres
dbt build on the image ghcr.io/dbt-labs/dbt-postgres:latest

Also when we create the containers we need to add an airflow user by :


docker exec -it airflow-webserver airflow users create \
    --username admin \
    --firstname First \
    --lastname Last \
    --role Admin \
    --email admin@example.com \
    --password admin

  
