FROM apache/airflow:2.10.4

# Install dbt-core and adapters
RUN pip install dbt-core dbt-postgres
