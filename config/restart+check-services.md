## Commands to restart and check the status of the services

# Pi-hole:
```bash
sudo systemctl restart pihole-FTL.service
sudo systemctl status pihole-FTL.service
sudo pihole reload dns
sudo pihole status
sudo pihole -t
```
# DNSCrypt:
```bash
sudo systemctl restart dnscrypt-proxy
sudo systemctl status dnscrypt-proxy
#For specifically the socket:
sudo systemctl restart dnscrypt-proxy.service
sudo systemctl status dnscrypt-proxy.service
```
# Tailscape:
```bash
sudo systemctl restart tailscaled
sudo systemctl status tailscaled
```
