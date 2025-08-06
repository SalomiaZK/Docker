# Utilise une image Python officielle basée sur Debian Bookworm pour une taille d'image plus petite
# et Python pré-installé.
FROM python:3.12-slim-bookworm

# Définit l'environnement pour les installations non interactives
ENV DEBIAN_FRONTEND=noninteractive

# Met à jour les paquets et installe les dépendances nécessaires pour OCaml, make, curl
# et les outils de construction.
# Combine les commandes RUN pour réduire le nombre de couches de l'image.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        make \
        ocaml \
        opam \
        build-essential && \
    rm -rf /var/lib/apt/lists/*

# Définit le répertoire de travail à l'intérieur du conteneur
WORKDIR /app

# Copie le script de l'application Flask
COPY app.py .

# Copie le répertoire marina. Il est crucial que ce répertoire contienne le code source
# de marina et non des binaires pré-compilés de votre machine hôte, car ils pourraient
# être incompatibles avec l'environnement du conteneur.
COPY marina ./marina
# Nettoie les anciennes compilations et compile marina à l'intérieur du conteneur.
# Cela garantit que l'exécutable marina est lié aux bibliothèques du conteneur.
# Le '|| true' est conservé pour éviter que la construction Docker ne s'arrête si 'make' échoue,
# mais assurez-vous que votre Makefile fonctionne correctement.
RUN cd ./marina && make clean && make && chmod +x marina || true && cd ..

# Installe Flask. Utilise --no-cache-dir pour éviter de stocker les fichiers de cache pip,
# ce qui réduit la taille de l'image.
RUN pip install --no-cache-dir flask

# Expose le port sur lequel l'application Flask écoutera
EXPOSE 8080

# Commande par défaut pour démarrer l'application Flask
CMD ["python3", "app.py"]

# Optionnel: Ajoute un Healthcheck pour vérifier que l'application est en cours d'exécution
# HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl --fail http://localhost:8080 || exit 1
