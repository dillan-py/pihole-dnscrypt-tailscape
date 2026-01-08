
# Secure Pi Setup using Pi-hole, Pi-VPN with DNSCrypt
```mathematica
Clients → Pi-hole → DNSCrypt → Internet
VPN clients → PiVPN → Pi-hole → DNSCrypt → Internet
```
- Pi-hole = DNS filtering / DHCP (optional)
- dnscrypt-proxy = encrypted upstream DNS
- PiVPN (WireGuard) = secure remote access
- dnscrypt-proxy runs locally and encrypts DNS queries
- Pi-hole forwards DNS to dnscrypt-proxy

The Pi connects via ethernet (eth0) in this example (wlan0 also works).
Pi-hole does not replace DNSCrypt
DNSCrypt runs locally and forwards encrypted DNS

The Pi will connect to the router via ethernet in this example, however you can use wlan0 too.

## Step 1: Update and clean up any unused packages
```bash
sudo apt update && sudo apt upgrade -y
sudo apt autoremove && sudo apt autopurge -y
```

## Step 2: Set a Static IP (required)
Pi-hole and PiVPN require a fixed IP.
>Recommended:
>Reserve the IP on your router (DHCP reservation) using the MAC address of the Pi.
And if it lets you change the DNS, set it to the IP of the Pi, if your router doesn't allow you to do this, each device will only need to change their DNS setting to the IP of the Pi on the network

Edit:
```bash
sudo nano /etc/dhcpcd.conf
```
Edit or add: 
(Replace X with the IP of your Pi use 'ip a' to see the ip on eth0 or wlan0 whichever you use, if you use wlan0, ensure you are using that interface)
```ini
interface eth0
static ip_address=192.168.0.X/24
static routers=192.168.0.1
static domain_name_servers=127.0.0.1
```
Reboot:
```bash
sudo systemctl restart dhcpcd
sudo reboot
```
Confirm:
```bash
ip a
ip route
ip -6 addr show eth0
```

## Step 3: Install Pi-Hole and set
```bash
curl -sSL https://install.pi-hole.net | bash
```
**Alternative Install Methods**

Piping to bash is controversial, as it prevents you from reading code that is about to run on your system. Therefore, we provide these alternative installation methods which allow code review before installation:

Method 1: Clone our repository and run
```bash
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"
sudo bash basic-install.sh
```
Method 2: Manually download the installer and run - prefer this if curl fails
```bash
wget -O basic-install.sh https://install.pi-hole.net
sudo bash basic-install.sh
```
**Important choices during install:**

- **Upstream DNS:** Any (this is only temporary; later change to custom DNS: `127.0.0.1#5053` as DNSCrypt will use this)
- **Web interface:** Yes
- **Blocklists:** Default

After install, test it works:
```bash
pihole status
pihole setpassword <enter a password here>
```
Ignore if using normal IPV4 setup:

# Optional: Pi-hole DHCPv6 + RA (IPv6 users only)

Pi-hole UI → Settings → DHCP

Enable:

- DHCP Server
- Enable IPv6 Support (SLAAC + RA)
- Pi-hole as the only DHCP server
- 
  **IMPORTANT** (do not skip)
If Pi-hole provides IPv6:
- Disable IPv6 DHCP and RA on your router - SLAAC comes from RA, not DHCPv6 (DHCPv6 ≠ RA)
- Never run two RA servers
Failure to do this causes:
- IPv6 instability
- DNS leaks
- Random connectivity loss

## Step 4: Install and Configure DNSCrypt
Following this working guide: https://docs.pi-hole.net/guides/dns/dnscrypt-proxy/

**Installing dnscrypt-proxy:**
```bash
sudo apt install dnscrypt-proxy -y
```
>We use systemd socket activation (recommended).
Chatgpt says not to do this step yet?:
```bash
#sudo systemctl enable dnscrypt-proxy
#sudo systemctl start dnscrypt-proxy
```
**Configuring dnscrypt-proxy**

**Important: edit the file shown in the guide by creating an override to survive updates and reboots:**
This makes /etc/systemd/system/dnscrypt-proxy.socket.d/override.conf
```bash
sudo systemctl edit dnscrypt-proxy.socket
```
By default, FTLDNS listens on the standard DNS port 53, to avoid conflicts with FTLDNS, use port 5053 on localhost ensuring dnscrypt-proxy listens on a port that is not in use by other services and make sure you clear any vendor defaults, this setup uses includes IPv6 to avoid dnsleaks through IPV6:
```bash
[Socket]
# Clear vendor defaults before setting your own
ListenStream=
ListenDatagram=

# Listen on localhost (IPv4 and IPv6) at port 5053
ListenStream=127.0.0.1:5053
ListenStream=[::1]:5053
ListenDatagram=127.0.0.1:5053
ListenDatagram=[::1]:5053
```
> **Note:** Clear existing `ListenStream` and `ListenDatagram` entries before adding new ones to avoid multiple socket bindings.

Apply it:
```bash

# Reload systemd and restart the socket
sudo systemctl daemon-reload
sudo systemctl enable dnscrypt-proxy.socket
sudo systemctl restart dnscrypt-proxy.socket
```

Verify it’s listening only on 5053 (both IPv4/IPv6)

```bash
#With socket activation, this will often show inactive (dead), That is normal.
systemctl status dnscrypt-proxy.socket
journalctl -u dnscrypt-proxy
sudo ss -lntu | grep 5053    # TCP
sudo ss -lnpu | grep 5053    # UDP
```
# Configure dnscrypt-proxy upstreams
Edit /etc/dnscrypt-proxy/dnscrypt-proxy.toml, updating the following settings:
```bash
sudo nano /etc/dnscrypt-proxy/dnscrypt-proxy.toml
```
Use the following settings:
```bash
# Use systemd socket activation:
listen_addresses = []

# Populate `server_names` with desired DoH/DNSCrypt upstream DNS servers listed in https://dnscrypt.info/public-servers/.
# Example for Cloudflare malware-blocking DNS and bhrama-world DNS for redundancy
server_names = ['cloudflare-security', 'brahma-world']
ipv6_servers = true        # set false if not using IPv6
dnssec = true
require_dnssec = true
```
# Configuring Pi-hole Upstream DNS Servers
Uncheck all Upstream DNS Servers
Run the following command to set the upstream DNS server of Pi-hole to your local dnscrypt-proxy instance:
```bash
sudo pihole-FTL --config dns.upstreams '["127.0.0.1#5053","[::1]#5053"]'
```
> Use sudo pihole-FTL --config dns.upstreams '["127.0.0.1#5053"]' for ipv4 only

#Restarting Services
Run the following commands to restart dnscrypt-proxy and FTLDNS:
```bash
sudo systemctl restart dnscrypt-proxy.socket
sudo systemctl restart pihole-FTL
sudo pihole restartdns #different install uses #
reloaddns'
```

#Reviewing Service Status
Run the following commands to review the status of each restarted service:
```bash
systemctl status dnscrypt-proxy.socket
journalctl -u dnscrypt-proxy | tail
pihole status
```

Configuring Pi-hole after DNSCrypt
Optionally, confirm in the Pi-hole admin web interface that upstream DNS servers are configured correctly:

- **Log into the Pi-hole admin web interface.**
- **Navigate to "Settings" and from there to "DNS".**
- **Under "Upstream DNS Servers", uncheck all boxes for public DNS servers.**
- **Under "Upstream DNS Servers", ensure the box is filled with the IP address and port combination dnscrypt-proxy listens: 127.0.0.1#5053 and [::1]#5053.**
- **Click on Save at the bottom.**

# Link Pi-hole to dnscrypt-proxy

```bash
sudo nano /etc/pihole/setupVars.conf
```
Set:
```bash
PIHOLE_DNS_1=127.0.0.1#5053
PIHOLE_DNS_2=::1#5053
```
Restart:
```bash
pihole restartdns
```
Verify on a client by setting the DNS manually to the Pi-hole IP address (Windows):
```bash
ipconfig /all
resolvectl status
```
Test DNS:
```bash
dig @127.0.0.1 google.com +dnssec
```
Expected:

- NOERROR
- ad flag present

To update dnscrypt-proxy using this install via APT, is simply by updating your system as you usually would:
```bash
sudo apt update
sudo apt upgrade
```
Advice - You do not need:
systemctl start dnscrypt-proxy
systemctl enable dnscrypt-proxy
> **The socket handles it.**

## Step X: DDNS from FreeDNS
Do not point your DDNS hostname to 127.0.0.1 or ::1. This must point to your public IP.
/etc/hosts

# Create updater

```bash
sudo nano /usr/local/bin/freedns_update.sh
```
```bash
#!/bin/bash
curl -fsS "https://freedns.afraid.org/dynamic/update.php?YOUR_TOKEN" >/dev/null 2>&1
```
```bash
sudo chmod +x /usr/local/bin/freedns_update.sh
```
Cron automation for every 5 minutes to so hostname always maps to it's public IP:
```bash
*/5 * * * * /usr/local/bin/freedns_update.sh
```




## Install PiVPN (WireGuard)
```bash
curl -L https://install.pivpn.io | bash
# Follow the interactive installer to choose WireGuard or OpenVPN
```
Choose:

- WireGuard
- Interface: eth0
- Port: 51820 UDP
- DNS: Pi-hole
- Public endpoint: FreeDNS hostname
- Unattended upgrades: Yes

Create client:
```bash
pivpn add
```
Verify:
```bash
sudo wg show
```
## Firewall (UFW)
```bash
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 53
sudo ufw allow 51820/udp
sudo ufw allow 80/tcp

# Enable UFW
sudo ufw enable

# Ensure UFW starts at boot (optional)
sudo systemctl enable ufw
sudo systemctl status ufw
sudo ufw status verbose

```
Check for ipv6 filtering:
```bash
sudo nano /etc/default/ufw
```
For ipv6 filtering ensure:
```bash
IPV6=yes
```



# Final Boot Validation
```bash
sudo reboot
```
Post-boot checks:
```bash
pihole status
sudo wg show
ufw status
dig @127.0.0.1 google.com +dnssec
# should return NOERROR and 'ad' flag
journalctl -u dnscrypt-proxy | tail
```



## Verify Services
```bash
pihole status          # Check Pi-hole status
pivpn -d               # Run PiVPN debug
systemctl status dnscrypt-proxy # will sjow inactive but just incase you wanted to see the results this is the command
```

## Next Steps
- Open/forward the chosen VPN port on your router (default WireGuard: 51820/UDP).
- Add your client profiles and test connectivity.
