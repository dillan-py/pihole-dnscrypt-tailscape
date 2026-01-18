#!/bin/bash

# List of your DNSCrypt servers
#Replace this with the chosen ones in your /etc/dnscrypt-proxy/dnscrypt-proxy.toml file:
RESOLVERS=(
'dnscry.pt-london', 'dnscry.pt-redditch-ipv4', 'cs-london', 'dnscry.pt-paris-ipv4', 'dnscry.pt-paris-ipv6', 'cs-manchester']
)


# Domain to test
DOMAIN="example.com"

echo "Testing latency and DNSSEC for $DOMAIN..."
echo "----------------------------------------"

for server in "${RESOLVERS[@]}"; do
    # Resolve using dnscrypt-proxy locally
    start=$(date +%s%3N)
    dig $DOMAIN @127.0.0.1 -p 5053 +dnssec +short >/dev/null
    end=$(date +%s%3N)
    elapsed=$((end - start))
    echo "Resolver: $server → RTT: ${elapsed}ms"
done
