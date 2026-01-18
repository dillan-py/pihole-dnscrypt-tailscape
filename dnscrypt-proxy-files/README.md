# These are all varients for the configuration file: 
# /etc/dnscrypt-proxy/dnscrypt-proxy.toml

The .toml files here are copy and paste ready files for you to use

# Using DNSCRYPT resolvers:

For IPv4 and IPv6:
- dnscrypt-proxy-ipv4+6.toml

For IPv4
- dnscrypt-proxy-ipv4.toml

# Using DOH resolvers:
This is not what I recommend but is here if you do decide you want DOH resolvers:

For IPv4 and IPv6:
- dnscrypt-proxy-doh-ipv4+6.toml

For IPv4
- dnscrypt-proxy-doh-ipv4.toml

If you want to change this file always do this straight after!

```bash
sudo systemctl restart dnscrypt-proxy
sudo systemctl status dnscrypt-proxy
```
