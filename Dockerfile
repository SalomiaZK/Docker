FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Met à jour les paquets et installe Python3, OCaml, curl et pip proprement
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-venv \
        python3-pip \
        curl \
        make \
        ocaml \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app.py .
COPY marina/ ./marina/

# Donne les droits d'exécution sur le binaire (s’il est déjà compilé)
RUN chmod +x ./marina/marina || true

# Installe Flask via pip
RUN pip3 install --no-cache-dir Flask

EXPOSE 8080

CMD ["python3", "app.py"]
