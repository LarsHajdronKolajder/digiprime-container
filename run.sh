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
NODE_ENV="production" node app.js
