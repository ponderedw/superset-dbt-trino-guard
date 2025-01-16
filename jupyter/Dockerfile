FROM jupyter/scipy-notebook:notebook-6.4.11

USER root

# Install Java (e.g., OpenJDK 11)
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get install -y wget && \
    apt-get clean;

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.11 python3.11-distutils

# Install pip for Python 3.11
RUN wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py && \
    python3.11 get-pip.py && \
    rm get-pip.py

# Install pyspark and ipykernel for Python 3.11
RUN python3.11 -m pip install dbt-core==1.8.8 dbt-trino==1.8.3 dbt-postgres==1.8.2
RUN python3.11 -m pip install ipykernel

# Register Python 3.11 kernel in Jupyter
RUN python3.11 -m ipykernel install --user --name=python3.11 --display-name "Python 3.11"

RUN chown -R jovyan:users /home/jovyan/.local

