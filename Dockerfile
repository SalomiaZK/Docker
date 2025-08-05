
FROM ubuntu:24.04
WORKDIR /app

COPY app.py .
COPY marina /app/marina

RUN apt update && apt install -y ocaml opam && \
    opam init -y && \
    opam install -y ocamlfind ounit2 && \
    apt install -y python3 python3-pip python3-venv && \
    make && \
    apt clean && rm -rf /var/lib/apt/lists/



RUN chmod +x marina


RUN python3 -m venv venv  

ENV PATH="/app/venv/bin:$PATH"

RUN make && \
    pip install --no-cache-dir flask


EXPOSE 8080


CMD ["python", "app.py"]
