#!/bin/bash
# Script to test latency of active DNSCrypt resolvers from your dnscrypt-proxy.toml config
# Assumes dnscrypt-proxy is listening on 127.0.0.1 port 5053 (adjust PORT if different)

CONFIG_FILE="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"   # ← your actual path
PORT=5053                                               # ← change if your listen port differs (check listen_addresses or systemd socket)

DOMAIN="example.com"  # Change to anything, e.g. bbc.co.uk for more realistic  test

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

# Improved extraction: grab everything between = [ ... ] , ignore comments/lines starting with #
# Handles multi-line arrays better and strips quotes/whitespace
RESOLVERS_STR=$(awk '
    /^[[:space:]]*server_names[[:space:]]*=/ { in_array=1; next }
    in_array && /\]/ { in_array=0; exit }
    in_array {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "");
        gsub(/,/," ");
        gsub(/'\''|"/,"");
        if ($0 != "") print $0
    }
' "$CONFIG_FILE" | tr -s ' ')
##
# Convert to array
RESOLVERS=($RESOLVERS_STR)

if [[ ${#RESOLVERS[@]} -eq 0 ]]; then
    echo "No server_names found or parsing failed in $CONFIG_FILE"
    echo "Raw extracted string was: '$RESOLVERS_STR'"
    echo "Check if server_names is commented out or formatted unusually."
    exit 1
fi

echo "Found ${#RESOLVERS[@]} resolvers:"
printf '  - %s\n' "${RESOLVERS[@]}"
echo ""
echo "Testing resolution latency for: $DOMAIN  (via local proxy @127.0.0.1:$PORT)"
echo "Make sure dnscrypt-proxy is running and healthy (systemctl status dnscrypt-proxy)"
echo "----------------------------------------"

for server in "${RESOLVERS[@]}"; do
    start=$(date +%s%3N)
    # +dnssec ensures we test validation (should show AD flag if working)
    # +short minimizes output; redirect errors
    dig_output=$(dig +short +dnssec "$DOMAIN" @127.0.0.1 -p "$PORT" 2>/dev/null)
    end=$(date +%s%3N)

    elapsed=$((end - start))

    if [[ -n "$dig_output" ]]; then
        status="OK"
    else
        status="FAILED (check proxy logs or if server is reachable)"
    fi

    echo "Resolver: $server → RTT: ${elapsed}ms  [$status]"
done

echo "----------------------------------------"
echo "Run multiple times for averages. Lowest consistent OK RTT wins."
