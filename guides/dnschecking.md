
Test DNSSEC correctness
On macOS/Linux (or Windows with WSL):
```bash
# Good domain with valid signatures should resolve:
dig @<pihole-100.x-ip> sigok.verteiltesysteme.net +dnssec

# Bad domain should fail validation:
dig @<pihole-100.x-ip> sigfail.verteiltesysteme.net +dnssec
```
> Expected: sigok works, sigfail fails. If both succeed or both fail, you’ve got a validation/bypass problem.

Test who’s answering & latency
```bash
# Who’s my resolver?
dig @<pihole-100.x-ip> whoami.cloudflare +short

# Timing:
dig @<pihole-100.x-ip> microsoft.com +stats
```
> Look at Query time — after the first warm lookup, it should be low double digits on a healthy, direct path.

Enable tailscale on Windows Firewall:
```powershell
# Allow Tailscale’s WireGuard UDP
New-NetFirewallRule -DisplayName "Tailscale UDP 41641 In"  -Direction Inbound  -Protocol UDP -LocalPort 41641 -Action Allow
New-NetFirewallRule -DisplayName "Tailscale UDP 41641 Out" -Direction Outbound -Protocol UDP -RemotePort 41641 -Action Allow

# Allow STUN and control-plane/DERP
New-NetFirewallRule -DisplayName "Tailscale STUN 3478 Out" -Direction Outbound -Protocol UDP -RemotePort 3478 -Action Allow
New-NetFirewallRule -DisplayName "Tailscale HTTPS 443 Out" -Direction Outbound -Protocol TCP -RemotePort 443 -Action Allow
New-NetFirewallRule -DisplayName "Tailscale HTTP 80 Out"  -Direction Outbound -Protocol TCP -RemotePort 80  -Action Allow

# (Optional) Ensure DNS to Pi-hole over Tailscale is allowed
# Replace 100.x.y.z with your Pi-hole’s Tailscale IP
New-NetFirewallRule -DisplayName "DNS to Pi-hole UDP 53" -Direction Outbound -Protocol UDP -RemoteAddress 100.x.y.z -RemotePort 53 -Action Allow
New-NetFirewallRule -DisplayName "DNS to Pi-hole TCP 53" -Direction Outbound -Protocol TCP -RemoteAddress 100.x.y.z -RemotePort 53 -Action Allow
```
