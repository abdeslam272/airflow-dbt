from airflow import DAG
from airflow.providers.docker.operators.docker import DockerOperator
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": days_ago(1),
    "retries": 1,
}

dag = DAG(
    "dbt_dag",
    default_args=default_args,
    schedule_interval="@daily",  # Exécuter tous les jours
    catchup=False,
)

# 1️⃣ Copier les fichiers CSV vers PostgreSQL
copy_data = BashOperator(
    task_id="copy_data",
    bash_command="""
    docker cp /opt/airflow/dags/init.sql postgres-dbt:/init.sql
    docker cp /opt/airflow/data/products.csv postgres-dbt:/products.csv
    docker cp /opt/airflow/data/customers.csv postgres-dbt:/customers.csv
    docker cp /opt/airflow/data/orders.csv postgres-dbt:/orders.csv
    docker cp /opt/airflow/data/order_items.csv postgres-dbt:/order_items.csv
    """,
    dag=dag,
)

init_db = BashOperator(
    task_id="init_db",
    bash_command='docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -f /init.sql',
    dag=dag,
)


# 2️⃣ Charger les fichiers CSV dans PostgreSQL (schéma RAW)
load_data = BashOperator(
    task_id="load_data",
    bash_command="""
    docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy raw.products FROM '/products.csv' WITH CSV HEADER;"
    docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy raw.customers FROM '/customers.csv' WITH CSV HEADER;"
    docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy raw.orders FROM '/orders.csv' WITH CSV HEADER;"
    docker exec -i postgres-dbt psql -U dbt-user -d dbt-db -c "\copy raw.order_items FROM '/order_items.csv' WITH CSV HEADER;"
    """,
    dag=dag,
)

# 3️⃣ Exécuter dbt run
dbt_run = BashOperator(
    task_id="dbt_run",
    bash_command="docker exec -i dbt dbt run",
    dag=dag,
)

# 4️⃣ Exécuter dbt test (qualité des données)
dbt_test = BashOperator(
    task_id="dbt_test",
    bash_command="docker exec -i dbt dbt test",
    dag=dag,
)

# 5️⃣ Générer la documentation dbt
dbt_docs = BashOperator(
    task_id="dbt_docs",
    bash_command="docker exec -i dbt dbt docs generate",
    dag=dag,
)

# 6️⃣ Servir la documentation dbt
dbt_docs_serve = BashOperator(
    task_id="dbt_docs_serve",
    bash_command="docker exec -d dbt dbt docs serve --port 8088",
    dag=dag,
)

# Définition des dépendances
copy_data >> init_db >> load_data >> dbt_run >> dbt_test >> dbt_docs >> dbt_docs_serve
