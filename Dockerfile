# Dockerfile for Digiprime with Auctions.
#
# The image is based on Ubuntu 20.04 and contains Digiprime with auctions, Negotiation Engine and a MongoDB
# database they both share.
FROM        ubuntu:20.04
RUN         apt-get update

# 1. Install MongoDB
# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# -----------------------------------------------------------------------------
RUN         apt-get install -y curl gnupg
RUN         curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
RUN         echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
RUN         apt-get update
RUN         apt-get install -y mongodb-org
RUN         mkdir -p /data/db

# 2. Install Caddy
# https://caddyserver.com/docs/install#debian-ubuntu-raspbian
# -----------------------------------------------------------------------------
RUN         apt install -y debian-keyring debian-archive-keyring apt-transport-https
RUN         curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | tee /etc/apt/trusted.gpg.d/caddy-stable.asc
RUN         curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
RUN         apt update
RUN         apt install caddy

# 3. Install Keycloak
# -----------------------------------------------------------------------------
WORKDIR     /keycloak
RUN         apt install -y default-jdk
RUN         curl -1sLf https://github.com/keycloak/keycloak/releases/download/17.0.1/keycloak-17.0.1.tar.gz | tee keycloak-17.0.1.tar.gz
RUN         tar -xvzf keycloak-17.0.1.tar.gz
RUN         mv keycloak-17.0.1 keycloak
RUN         chmod +x keycloak/bin
EXPOSE      8080

# 4. Negotiation Engine dependencies
# -----------------------------------------------------------------------------
WORKDIR     /ne
RUN         apt-get install -y python3 python3-pip
ARG         requirements="./NegotiationEngine/API PILOT 1/requirements.txt"
COPY        ${requirements} .
RUN         pip3 install -r requirements.txt

# 5. Digiprime dependencies
# -----------------------------------------------------------------------------
WORKDIR     /digiprime

# Use Node v16
RUN         curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

RUN         apt-get install -y nodejs
COPY        ./Digiprime/package.json .
COPY        ./Digiprime/package-lock.json .
RUN         npm install

# 6. Negotiation Engine
# -----------------------------------------------------------------------------
WORKDIR     /ne
ARG         ne_path="./NegotiationEngine/API PILOT 1/"
COPY        ${ne_path} .

# 7. Digiprime source
# -----------------------------------------------------------------------------
WORKDIR     /digiprime
COPY        ./Digiprime .
EXPOSE      3000

# 8. Utility to create contracts
# -----------------------------------------------------------------------------
WORKDIR     /util
COPY        ./util .
RUN         npm install

# 9. Setup caddy
# -----------------------------------------------------------------------------
# Expose Caddy
EXPOSE      80
EXPOSE      443

# 10. Setting up required environment variables.
# -----------------------------------------------------------------------------
# General
ENV         SITE_ADDRESS="localhost"
ENV         USE_TLS="false"

# Keycloak
ENV         KEYCLOAK_HOST="http://localhost:3000/"
ENV         KEYCLOAK_REALM="digiPrime"
ENV         KEYCLOAK_CLIENT_ID="digiPrime-web"
ENV         KEYCLOAK_CLIENT_SECRET="Hs2Oc9h4il883PusIr49DEvqsASonYTc"
ENV         KEYCLOAK_ADMIN="admin"
ENV         KEYCLOAK_ADMIN_PASSWORD="changeme"
ENV         AUTH_KEYCLOAK="http://localhost:8080/"
ENV         SITE_URL="http://localhost:3000/auth/callback"
WORKDIR     /keycloak
COPY        ./realm.json .

# Digiprime
ENV         DB_URL="mongodb://localhost:27017/offer-test"
ENV         SECRET="thisshouldbeabettersecret"
ENV         PORT="3000"
ENV         CLOUDINARY_CLOUD_NAME=""
ENV         CLOUDINARY_KEY=""
ENV         CLOUDINARY_SECRET=""
ENV         MAPBOX_TOKEN=""
ENV         NODE_ENV="development"

# Negotiation Engine
ENV         DATABASE_URL="mongodb://localhost:27017/"

# 11. Copy & Run start script
# -----------------------------------------------------------------------------
WORKDIR     /
COPY        ./run.sh .
RUN         chmod +x ./run.sh
CMD         ./run.sh
