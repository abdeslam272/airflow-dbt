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



# Comprendre un projet dbt et résoudre les erreurs

## 1. Ce dont un projet dbt a besoin  
Un projet **dbt (Data Build Tool)** fonctionne en transformant les données dans un entrepôt de données. Il a besoin de plusieurs éléments clés :

### a) Un fichier `dbt_project.yml`  
Ce fichier **définit la configuration** du projet :  
- Le nom du projet (ex: `my_dbt_project`)  
- L'emplacement des modèles (ex: `models/`)  
- Les configurations des modèles (matérialisation, tags, etc.)  

Exemple :  
```yaml
name: my_dbt_project
version: "1.0.0"
profile: default  # Référence au fichier profiles.yml
model-paths: ["models"]  # Dossier contenant les modèles

models:
  my_dbt_project:
    example_model:
      +materialized: table  # Matérialisation (table, view, incremental, ephemeral)
 ```

### b) Un fichier `profiles.yml`  
Ce fichier définit **la connexion à la base de données.** Il est stocké en dehors du projet dbt (souvent dans `~/.dbt/profiles.yml` ou défini via `DBT_PROFILES_DIR`).

Exemple de connexion PostgreSQL :
```yaml
default:
  target: dev
  outputs:
    dev:
      type: postgres
      host: postgres-dbt  # Nom du service Docker
      user: dbt-user
      password: dbt-password
      port: 5434
      dbname: dbt-db
      schema: public
      threads: 4
 ```
📌 Problème possible : Si dbt ne trouve pas ce fichier, il ne pourra pas se connecter à la base de données.

### c) Un dossier `models/` avec des fichiers `.sql`
C'est là que tu définis **tes transformations SQL.** Chaque fichier `.sql` est un modèle dbt.

Exemple :
```yaml
-- models/example_model.sql
SELECT 1 AS example_column
```

📌 Problème possible : Si le dossier models/ est vide, dbt ne trouve rien à exécuter.
