FROM ubuntu:24.04

WORKDIR /app

# Copier les fichiers
COPY app.py .
COPY marina/ ./marina/

# Installer les paquets nécessaires
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

# Donner les droits d'exécution au binaire OCaml
RUN chmod +x ./marina/marina || true

# Créer et activer l'environnement virtuel Python
RUN python3 -m venv /app/venv

ENV PATH="/app/venv/bin:$PATH"

# Installer Flask dans le venv
RUN pip install --no-cache-dir flask

EXPOSE 8080

# Lancer l'application Flask
CMD ["python3", "app.py"]
