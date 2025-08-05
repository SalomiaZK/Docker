FROM ubuntu:24.04

WORKDIR /app

# Installer dépendances de base
RUN apt update && apt install -y \
    curl \
    make \
    ocaml \
    opam \
    python3 \
    python3-pip \
    python3-venv \
    git && \
    apt clean && rm -rf /var/lib/apt/lists/

# Initialiser opam correctement
RUN opam init -y --disable-sandboxing && \
    eval $(opam env) && \
    opam install -y ocamlfind ounit2

# Copier les fichiers
COPY app.py .
COPY marina/ ./marina/

# Compilation du code OCaml
WORKDIR /app/marina
RUN make

# Revenir dans /app
WORKDIR /app

# Rendre le binaire exécutable
RUN chmod +x ./marina/marina

# Créer et activer venv
RUN python3 -m venv venv
ENV PATH="/app/venv/bin:$PATH"

# Installer Flask
RUN pip install --no-cache-dir flask

EXPOSE 8080

CMD ["python", "app.py"]
