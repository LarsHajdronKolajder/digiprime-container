# Dockerfile for Digiprime with Auctions.
#
# The image is based on Ubuntu 20.04 and contains Digiprime with auctions, Negotiation Engine and a MongoDB
# database they both share.
FROM        ubuntu:20.04
RUN         apt-get update

# 1. Installing MongoDB following:
# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# -----------------------------------------------------------------------------
RUN         apt-get install -y curl gnupg
RUN         curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
RUN         echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
RUN         apt-get update
RUN         apt-get install -y mongodb-org
RUN         mkdir -p /data/db

# 2. Negotiation Engine dependencies
# -----------------------------------------------------------------------------
# Use Node v16
RUN         curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

WORKDIR     /ne
RUN         apt-get install -y python3 python3-pip
ARG         requirements="./NegotiationEngine/API PILOT 1/requirements.txt"
COPY        ${requirements} .
RUN         pip3 install -r requirements.txt

# 3. Digiprime dependencies
# -----------------------------------------------------------------------------
WORKDIR     /digiprime
RUN         apt-get install -y nodejs
COPY        ./Digiprime/package.json .
COPY        ./Digiprime/package-lock.json .
RUN         npm install

# 4. Negotiation Engine
# -----------------------------------------------------------------------------
WORKDIR     /ne
ARG         ne_path="./NegotiationEngine/API PILOT 1/"
COPY        ${ne_path} .

# 5. Digiprime source
# -----------------------------------------------------------------------------
WORKDIR     /digiprime
COPY        ./Digiprime .
EXPOSE      3000

# 6. Utility to create contracts
# -----------------------------------------------------------------------------
WORKDIR     /util
COPY        ./util .
RUN         npm install

# 7. Setting up environment required environment variables.
# -----------------------------------------------------------------------------
# Digiprime
ENV         DB_URL="mongodb://localhost:27017/offer-test"
ENV         SECRET="thisshouldbeabettersecret"
ENV         PORT="3000"
ENV         CLOUDINARY_CLOUD_NAME=""
ENV         CLOUDINARY_KEY=""
ENV         CLOUDINARY_SECRET=""
ENV         MAPBOX_TOKEN=""

# Negotiation Engine
ENV         DATABASE_URL="mongodb://localhost:27017/"

# 8. Copy & Run start script
# -----------------------------------------------------------------------------
WORKDIR     /
COPY        ./run.sh .
RUN         chmod +x ./run.sh
CMD         ./run.sh
