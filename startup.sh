#!/bin/bash

# Start SSH service
service ssh start

# Set up SSH authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Install and start cloudflared service if CLOUDFLARED_TOKEN is provided
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    # Ensure CLOUDFLARED_HOSTNAME is set
    if [ -z "$CLOUDFLARED_HOSTNAME" ]; then
        echo "Error: CLOUDFLARED_HOSTNAME environment variable is not set."
        exit 1
    fi

    # Login to Cloudflare using the token
    cloudflared tunnel --no-autoupdate login --token "$CLOUDFLARED_TOKEN"

    # Create a tunnel named server
    cloudflared tunnel create server

    # Create the cloudflared config file
    mkdir -p /etc/cloudflared
    cat > /etc/cloudflared/config.yml <<EOF
tunnel: my-tunnel
credentials-file: /root/.cloudflared/my-tunnel.json
ingress:
  - hostname: ${CLOUDFLARED_HOSTNAME}
    service: http://localhost:8888
  - service: http_status:404
EOF

    # Start the tunnel
    cloudflared tunnel --config /etc/cloudflared/config.yml run my-tunnel &
fi

# Keep the container running
tail -f /dev/null
