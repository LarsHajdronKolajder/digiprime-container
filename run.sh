#!/bin/bash

# Start mongo
echo "Starting MongoDB"
nohup mongod &

# Create default contract
cd /util
npm run create_contract

# Start Negotiation Engine
echo "Starting Negotiation Engine..."
cd /ne
nohup python3 -m flask run --host=0.0.0.0 &

# Start Digiprime
echo "Starting Digiprime..."
cd /digiprime
nohup node app.js &

# Start Caddy
cd /caddy
if [ "$USE_TSL" == "true" ]
then
    echo "Starting Caddy with HTTPS..."
    caddy reverse-proxy --from ${SITE_ADDRESS} --to 127.0.0.1:3000
else
    echo "Starting Caddy without HTTPS..."
    caddy run --config ./Caddyfile_no_tls
fi
