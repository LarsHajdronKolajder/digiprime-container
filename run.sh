#!/bin/bash

# Start mongo
echo "Starting MongoDB"
nohup mongod &

# Start Negotiation Engine
echo "Starting Negotiation Engine..."
cd /ne
nohup python3 -m flask run --host=0.0.0.0 &

# Start Digiprime
echo "Starting Digiprime..."
cd /digiprime
node app.js
