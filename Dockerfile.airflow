FROM apache/airflow:2.10.4

# Install dbt
RUN pip install dbt-core dbt-postgres

# Set working directory
WORKDIR /opt/airflow

# Copy the DAGs folder
COPY dags /opt/airflow/dags

# Set entrypoint (optional, defined in docker-compose)
ENTRYPOINT ["airflow"]
