# Base image with VS Code setup
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Install dependencies for OCaml
RUN apt-get update && apt-get install -y \
    opam \
    m4 \
    pkg-config \
    git \
    curl \
    build-essential && \
    opam init -y && \
    eval $(opam env) && \
    opam switch create 4.14.0 && \
    opam install -y dune utop ocaml-lsp-server && \
    opam install -y odoc csv sqlite3 ptime cohttp-lwt-unix ounit2 lwt_ssl

USER vscode

COPY postCreate.sh /home/vscode/postCreate.sh
USER root
RUN chmod +x /home/vscode/postCreate.sh