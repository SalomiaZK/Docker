# Base image avec OCaml et Make
FROM ubuntu:24.04

# Variables d'environnement pour éviter les interactions
ENV DEBIAN_FRONTEND=noninteractive

# Installation des dépendances nécessaires
RUN apt-get update && apt-get install -y \
    ocaml \
    make \
    build-essential \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Crée le dossier de travail
WORKDIR /app

# Copie le code Flask et le dossier marina (avec le code OCaml)
COPY app.py .
COPY marina/ ./marina/

# Donne les droits d'exécution sur le binaire (au cas où)
RUN chmod +x ./marina/marina || true

# Installe Flask
RUN pip3 install --no-cache-dir Flask

# Expose le port 8080
EXPOSE 8080

# Commande de démarrage
CMD ["python3", "app.py"]
