#!/bin/bash

# Start mongo
echo "Starting MongoDB"
nohup mongod &

# Start Keycloak
echo "Starting Keycloak"
cd /keycloak/keycloak/bin
nohup ./kc.sh -Dkeycloak.profile.feature.upload_scripts=enabled start-dev &

echo "Creating Realm"
# Repeat this until the keycloak sever is up and running.
while ! ./kcadm.sh config credentials --server http://localhost:8080 --realm master --user "${KEYCLOAK_ADMIN}" --password "${KEYCLOAK_ADMIN_PASSWORD}"
do
    sleep 5
done
./kcadm.sh create realms -f ../../realm.json

# Create default contract
cd /util
npm run create_contract

# Start Negotiation Engine
echo "Starting Negotiation Engine..."
cd /ne
nohup python3 -m flask run --host=0.0.0.0 &

if [ "${USE_TLS}" == "true" ]
then
    # Start Digiprime
    echo "Starting Digiprime..."
    cd /digiprime
    nohup node app.js &

    # Start Caddy
    cd /
    echo "Starting Caddy with HTTPS..."
    caddy reverse-proxy --from ${SITE_ADDRESS} --to 127.0.0.1:3000
else
    # Start Digiprime
    echo "Starting Digiprime..."
    cd /digiprime
    node app.js
fi
