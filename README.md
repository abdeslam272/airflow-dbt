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

```sh
docker exec -it airflow-webserver airflow users create \
    --username admin \
    --firstname First \
    --lastname Last \
    --role Admin \
    --email admin@example.com \
    --password admin
```



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

## Erreurs :
$ docker logs dbt
09:51:58  Running with dbt=1.9.0
09:51:59  Registered adapter: postgres=1.9.0
09:51:59  [WARNING]: Configuration paths exist in your dbt_project.yml file which do not apply to any resources.
There are 1 unused configuration paths:
- models.my_project.example_model
09:51:59  Found 1 model, 429 macros
09:51:59
09:51:59  Concurrency: 4 threads (target='dev')
09:51:59
09:51:59
09:51:59  Finished running  in 0 hours 0 minutes and 0.08 seconds (0.08s).
09:51:59  Encountered an error:
Database Error
  connection to server at "postgres-dbt" (172.18.0.3), port 5434 failed: Connection refused
        Is the server running on that host and accepting TCP/IP connections?

ce que j'ai fait, c'est changer le port dans le fichier profiles.yml pour utiliser 5432

j'ai ceci maintenant :
$ docker logs dbt
10:07:06  Running with dbt=1.9.0
10:07:06  Registered adapter: postgres=1.9.0
10:07:07  Unable to do partial parsing because profile has changed
10:07:09  Found 1 model, 429 macros
10:07:09
10:07:09  Concurrency: 4 threads (target='dev')
10:07:09
10:07:09  1 of 1 START sql table model public.example_model .............................. [RUN]
10:07:09  1 of 1 OK created sql table model public.example_model ......................... [SELECT 1 in 0.24s]
10:07:09
10:07:09  Finished running 1 table model in 0 hours 0 minutes and 0.53 seconds (0.53s).
10:07:09
10:07:09  Completed successfully
10:07:09
10:07:09  Done. PASS=1 WARN=0 ERROR=0 SKIP=0 TOTAL=1
10:07:13  Running with dbt=1.9.0
10:07:13  Registered adapter: postgres=1.9.0
10:07:14  Found 1 model, 429 macros
10:07:14
10:07:14  Concurrency: 4 threads (target='dev')
10:07:14
10:07:14  1 of 1 START sql table model public.example_model .............................. [RUN]


# Compréhension 
to execute sql file in the racine project inside a container
```bash
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db < init.sql
```
Make the Script Executable
Run this command in your terminal to make the script executable:

```bash
chmod +x import_data.sh
```

Run the Script
Execute the script with:

```bash
./import_data.sh
```

--> Ca pas marchée avec le fichier import_data mais ca marché avec les commads suivants :
✅ Recharger les tables et importer les données
1️⃣ Copier et exécuter le script corrigé

```sh
docker cp init.sql postgres-dbt:/init.sql
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db < init.sql
```
2️⃣ Vérifier les tables

```sh
docker exec -it postgres-dbt psql -U dbt-user -d dbt-db -c "\dt"
```
3️⃣ Importer les fichiers CSV

```sh
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy products FROM '/products.csv' WITH CSV HEADER;"
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy customers FROM '/customers.csv' WITH CSV HEADER;"
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy orders FROM '/orders.csv' WITH CSV HEADER;"
docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy order_items FROM '/order_items.csv
```


Le fichier sources.yml (dans le folder models) est utilisé dans DBT pour déclarer les sources de données externes (par exemple, les tables brutes dans un entrepôt de données). Il permet de :
✅ Définir les schémas et tables sources (ex. tables brutes dans un schéma raw)
✅ Ajouter des tests de qualité sur ces sources
✅ Faciliter la traçabilité des données et la documentation


la commande pour dbt run :
```sh
docker exec -it dbt dbt run
```
