FROM ubuntu:24.04

WORKDIR /app

# Copier les fichiers nécessaires
COPY app.py .
COPY marina/ ./marina/

# Installer les dépendances système
RUN apt update && \
    apt install -y \
        curl \
        make \
        ocaml \
        opam \
        python3 \
        python3-pip \
        python3-venv && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Initialiser OPAM et installer les paquets OCaml
RUN opam init -y --disable-sandboxing && \
    . /root/.opam/opam-init/init.sh > /dev/null 2>&1 && \
    opam install -y ocamlfind ounit2

# Compiler le code OCaml
RUN ocamlc ./marina/marina.ml -o ./marina/marina && \
    chmod +x ./marina/marina

# Créer et activer l'environnement virtuel Python
RUN python3 -m venv /app/venv

ENV PATH="/app/venv/bin:$PATH"

# Installer Flask
RUN pip install --no-cache-dir flask

EXPOSE 8080

# Démarrer l'application Flask
CMD ["python3", "app.py"]
