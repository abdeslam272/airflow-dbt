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


# 📁 Dossiers principaux dans un projet dbt

| Dossier              | Description |
|----------------------|------------|
| `models/`           | Contient les modèles SQL qui transforment les données. |
| `models/staging/`   | Contient les modèles de staging, qui préparent les données brutes pour les transformations finales. |
| `models/marts/`     | Contient les modèles finaux, souvent agrégés, prêts pour l'analyse. |
| `macros/`           | Contient des fonctions réutilisables écrites en Jinja pour automatiser des transformations SQL. |
| `logs/`             | Contient les fichiers de log des exécutions de dbt (`dbt run`, `dbt test`, etc.). |
| `target/`           | Contient les fichiers compilés et les résultats des exécutions dbt (SQL transformés, logs, documentation générée). |
| `snapshots/`        | Contient les définitions des snapshots, qui permettent de suivre l'évolution des données au fil du temps. |
| `tests/`            | Contient des tests SQL définis pour valider la qualité des données. |
| `seeds/`            | Contient des fichiers CSV qui peuvent être chargés comme tables dans la base de données. |

---

# 📄 Fichiers importants dans un projet dbt

| Fichier              | Description |
|----------------------|------------|
| `dbt_project.yml`    | Fichier de configuration du projet dbt (nom, dossiers utilisés, paramètres, etc.). |
| `profiles.yml`       | Fichier qui configure la connexion à la base de données (nom du profil, hôte, utilisateur, etc.). |
| `.user.yml`         | Configuration spécifique à l'utilisateur local, pas toujours présente. |

# 📄 Commande pour lancer des tests

| Commande                             | Action                                           |
|--------------------------------------|--------------------------------------------------|
| `dbt test`                          | Exécute tous les tests                          |
| `dbt test --select order_items`     | Exécute les tests sur `order_items`            |
| `dbt test --select staging`         | Exécute les tests des modèles dans `/models/staging/` |
| `dbt test --select test_type:not_null` | Exécute tous les tests `not_null`               |
| `dbt test --select order_items.id`  | Exécute les tests sur `id` de `order_items`    |


## 🧭 Résumé du projet

Ce projet suit un pipeline de données complet, de l'ingestion à l'orchestration, en utilisant **PostgreSQL**, **dbt**, **Airflow** et **Docker**. Voici les grandes étapes :

### 1. 📥 Ingestion des données

Les fichiers CSV suivants sont disponibles dans le dossier `data/` :
- `customers.csv`
- `order_items.csv`
- `orders.csv`
- `products.csv`

Avant d'ingérer les données, il est nécessaire d'**initialiser les tables** dans la base PostgreSQL avec les noms et types de colonnes appropriés.  
Ensuite, le script `import_data.sh` permet d'**insérer les données** dans ces tables.

### 2. 🛠️ Transformations & tests avec dbt

Une fois les données ingérées, nous utilisons **dbt** pour :
- Appliquer les **transformations** sur les données brutes
- Effectuer des **tests de qualité** des données

Les modèles dbt génèrent des tables transformées dans le **schéma cible** désigné.

### 3. ⏱️ Orchestration avec Airflow

Enfin, l'ensemble du pipeline est orchestré via **Airflow**, avec des **DAGs** qui automatisent :
- L'ingestion
- Les transformations
- Les validations

### 4. 🐳 Environnement Dockerisé

Tout le projet fonctionne à l'intérieur de **conteneurs Docker**, ce qui garantit un environnement reproductible et facile à déployer.

# Error: Is the docker daemon running?
![image](https://github.com/user-attachments/assets/a94905a4-21dd-4c67-82c1-0f488b3c9145)

🧠 Pourquoi cette erreur ?
Cette erreur signifie que le conteneur dbt n’était pas en cours d’exécution au moment où la commande a été exécutée.
La commande docker exec ne peut être utilisée que sur un conteneur actif. Si le conteneur est arrêté (ex: crash ou fin du processus), cette erreur apparaît.

🔍 Cause probable
Dans le Dockerfile ou docker-compose.yml, la commande de démarrage du conteneur était quelque chose comme :

```sh
CMD ["bash", "-c", "dbt deps --profiles-dir profiles && sleep infinity"]
```
Si le dossier profiles n’est pas monté correctement ou mal configuré, la commande dbt deps échoue → le conteneur s’arrête immédiatement sans exécuter sleep infinity.

✅ Solution
Étapes pour corriger le problème :
Vérifier que le volume du profil est bien monté dans le docker-compose.yml :
```sh
volumes:
  - ./profiles:/usr/app/profiles
```
Corriger la commande de lancement dans le service dbt :

```yaml
command: ["bash", "-c", "dbt deps --profiles-dir profiles && dbt build --profiles-dir profiles && sleep infinity"]
```

🔒 Le sleep infinity est essentiel pour garder le conteneur actif et pouvoir y accéder avec docker exec.

🟢 Résultat
Une fois ces changements faits, le conteneur reste actif et tu peux exécuter :
```
docker exec -it dbt dbt run
```
ou
```
docker exec -it dbt bash
```


🧠 Résumé en une phrase
Cette erreur venait du fait que le conteneur DBT crashait au démarrage (souvent à cause d’un profil manquant ou mal configuré), et ne restait donc pas actif. Pour résoudre cela, il faut s'assurer que dbt deps fonctionne bien et terminer la commande par sleep infinity pour garder le conteneur actif.



### 🐛 Problème rencontré : Could not find profile named 'default'
Lors de l'exécution de la commande dbt run, l'erreur suivante est apparue :
```
Runtime Error: Could not find profile named 'default'
```

### 🎯 Cause
dbt recherche par défaut son fichier de configuration profiles.yml dans le chemin suivant à l’intérieur du conteneur Docker :
```
/root/.dbt/profiles.yml
```
Or, dans ce projet, le fichier profiles.yml se trouvait à un emplacement personnalisé :

```
./dbt/profiles/profiles.yml
```

Et dans le docker-compose.yml, seul le dossier ./dbt était monté vers /usr/app/dbt, sans inclure explicitement le fichier profiles.yml au bon endroit.

### ✅ Solution
Ajouter un volume pour monter directement profiles.yml dans le chemin attendu par dbt :
```
services:
  dbt:
    ...
    volumes:
      - ./dbt:/usr/app/dbt
      - ./dbt/profiles/profiles.yml:/root/.dbt/profiles.yml
```

###  📌 Importance du fichier profiles.yml
Le fichier profiles.yml contient les informations de connexion à la base de données (type, hôte, port, identifiants, schéma, etc.).
C’est essentiel pour que dbt puisse se connecter au bon environnement cible.

Voici un exemple de structure :
```
default:
  target: dev
  outputs:
    dev:
      type: postgres
      host: postgres-dbt
      user: dbt-user
      password: dbt-password
      port: 5432
      dbname: dbt-db
      schema: raw
      threads: 4
```

### ✅ Résultat après correction
Après avoir corrigé la configuration, l'exécution de dbt run fonctionne parfaitement 🎉 :
```
Completed successfully
PASS=5 WARN=0 ERROR=0 SKIP=0 TOTAL=5
```


### ✅ Nettoyer l’environnement (optionnel mais recommandé)

```bash
docker-compose down -v  # arrête et supprime les volumes
docker system prune -f  # nettoie les conteneurs/volumes/images inutilisés
```
