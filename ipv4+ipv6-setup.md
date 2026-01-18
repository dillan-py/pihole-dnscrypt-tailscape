
# Secure Pi Setup using Pi-hole, Pi-VPN with DNSCrypt
```mathematica
Clients → Pi-hole → DNSCrypt → Internet
VPN clients → Tailscape → Pi-hole → DNSCrypt → Internet
```
Pi-hole does not replace DNSCrypt
DNSCrypt runs locally and forwards encrypted DNS

The Pi will connect to the router via ethernet in this example, however you can use wlan0 too.

## Step 1: Update and clean up any unused packages
```bash
sudo apt update && sudo apt upgrade -y
sudo apt autoremove && sudo apt autopurge -y
```

## Step 2: Set a Static IP (required)
Pi-hole will break without this.

Before installing Pi-Hole, ensure that you have set a static ip for your Pi on your router, most routers will let you reserve an IP address if you provide a name, MAC and IP. This will prevent the Pi changing to another IP by DHCP over time.

And if it lets you change the DNS, set it to the IP of the Pi, if your router doesn't allow you to do this, each device will only need to change their DNS setting to the IP of the Pi on the network
> Later we will use 'nmcli' to set the static IP including the DNS, till then we need the router to be used so the Pi can resolve domains for installs and testing.

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
**Important choices during install:**

- **Upstream DNS:** Any (this is only temporary; later change to custom DNS: `127.0.0.1#5053` as DNSCrypt will use this)
- **Web interface:** Yes
- **Blocklists:** Default is fine

After install, test it works:
```bash
pihole status
pihole setpassword <enter a password here>
```
If using Pi-hole for DHCP6 + RA (ignore if using normal IPV4)
In Pi-hole UI:
Settings -> DHCP
Enable:
- DHCP Server
- Enable Ipv6 Support (SLAAC + RA)] - Diable DHCP6 if you want to use ipv6 completely i nthe network
- "Pihole as the only DHCP server"
Save

## Step 4: Install and Configure DNSCrypt
Following this working guide: https://docs.pi-hole.net/guides/dns/dnscrypt-proxy/

**Installing dnscrypt-proxy:**
```bash
sudo apt install dnscrypt-proxy -y

#sudo systemctl enable dnscrypt-proxy
#sudo systemctl start dnscrypt-proxy
```
**Configuring dnscrypt-proxy**

**Important: edit the file shown in the guide by creating an override to survice updates and reboots:**
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
sudo systemctl restart dnscrypt-proxy.socket

# If the service is running, restart it too
sudo systemctl restart dnscrypt-proxy
```

Verify it’s listening only on 5053 (both IPv4/IPv6)

```bash

systemctl status dnscrypt-proxy.socket
sudo ss -lntu | grep 5053    # TCP
sudo ss -lnpu | grep 5053    # UDP
```
Also edit /etc/dnscrypt-proxy/dnscrypt-proxy.toml, updating the following settings:
```bash
sudo nano /etc/dnscrypt-proxy/dnscrypt-proxy.toml
```
Use the follwing settings:
```bash
# Use systemd socket activation:
listen_addresses = []

# Populate `server_names` with desired DoH/DNSCrypt upstream DNS servers listed in https://dnscrypt.info/public-servers/.
# Example for Cloudflare malware-blocking DNS and bhrama-world DNS for redundancy
server_names = ['cloudflare-security', 'bhrama-world']
ipv6_servers = true # delete/false if you are not using ipv6
dnssec = true
require_dnssec = true
```
#Configuring Pi-hole Upstream DNS Servers
Uncheck all Upstream DNS Servers
Run the following command to set the upstream DNS server of Pi-hole to your local dnscrypt-proxy instance:
```bash
sudo pihole-FTL --config dns.upstreams '["127.0.0.1#5053","[::1]#5053"]'
```
#Restarting Services
Run the following commands to restart dnscrypt-proxy and FTLDNS:
```bash
sudo systemctl restart dnscrypt-proxy.socket
sudo systemctl restart dnscrypt-proxy.service
sudo systemctl restart pihole-FTL.service
sudo pihole restartdns
```

#Reviewing Service Status
Run the following commands to review the status of each restarted service:
```bash
sudo systemctl status dnscrypt-proxy.socket
sudo systemctl status dnscrypt-proxy.service
sudo systemctl status pihole-FTL.service
sudo pihole status
```

Configuring Pi-hole after DNSCrypt
Optionally, confirm in the Pi-hole admin web interface that upstream DNS servers are configured correctly:

- **Log into the Pi-hole admin web interface.**
- **Navigate to "Settings" and from there to "DNS".**
- **Under "Upstream DNS Servers", uncheck all boxes for public DNS servers.**
- **Under "Upstream DNS Servers", ensure the box is filled with the IP address and port combination dnscrypt-proxy listens on, such as 127.0.0.1#5053.**
- **Click on Save at the bottom.**

- **Upstream DNS:** Any (this is only temporary; later change to custom DNS: `127.0.0.1#5053` as DNSCrypt will use this)
- **Web interface:** Yes
- **Blocklists:** Default is fine

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

nmcli

 nmcli device show | grep DNS
 292  nmcli -t -f NAME,DEVICE,TYPE,STATE connection show --active
 293  sudo nmcli connection modify netplan-eth0 ipv4.dns 127.0.0.1
 294  sudo nmcli connection modify netplan-eth0 ipv4.ignore-auto-dns yes
 295  sudo nmcli connection modify netplan-eth0 ipv6.dns ::1
 296  sudo nmcli connection modify netplan-eth0 ipv6.ignore-auto-dns yes
 297  sudo nmcli device reapply eth0
 298  nmcli device show | grep DNS
 299  cat /etc/resolv.conf
 300  dig dnssec-failed.org
 301  dig -6 dnssec-failed.org
 302  sudo ss -lunpt | grep :53

check:

 304  sudo journalctl -u dnscrypt-proxy.service -n 50 --no-pager
 sudo pihole -t
 sudo tcpdump -i any port 53

dig dnssec-failed.org

 LORD HAVE MERCY IT WORKS:
 sudo systemctl status dnscrypt-proxy
 327  sudo systemctl status dnscrypt-proxy.socket
 328  sudo systemctl status dnscrypt-proxy.service
 

Verify on a client by setting the DNS manually to the Pi-hole IP address (Windows):
```bash
ipconfig /all
resolvectl status
```
To update dnscrypt-proxy using this install via APT, is simply by updating your system as you usually would:
```bash
sudo apt update
sudo apt upgrade
```

Enable and start these services
```bash

sudo systemctl enable dnscrypt-proxy
sudo systemctl enable pi-hole-FTL
sudo systemctl start pi-hole-FTL
```
Advice - You do not need:
systemctl start dnscrypt-proxy
systemctl enable dnscrypt-proxy
> **The socket handles it.**

Test with:
```bash
dig @127.0.0.1 google.com +dnssec
```
## Install Tailscape (VPN)

On the Pi:
```
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```
On your phone/laptop:
- 	Install Tailscale app
- 	Sign in
- 	Done

You now have a working VPN.

## Firewall 
```bash
# 1. Allow loopback traffic (critical)
iptables -A OUTPUT -o lo -j ACCEPT

# 2. Allow Pi-hole → dnscrypt-proxy (localhost:5053)
iptables -A OUTPUT -p udp --dport 5053 -m owner --uid-owner pihole -j ACCEPT
iptables -A OUTPUT -p tcp --dport 5053 -m owner --uid-owner pihole -j ACCEPT

# 3. Allow dnscrypt-proxy to do DNS bootstrap/fallback
iptables -A OUTPUT -p udp --dport 53 -m owner --uid-owner dnscrypt-proxy -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -m owner --uid-owner dnscrypt-proxy -j ACCEPT

# 4. Allow established connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

# Final Boot Validation
```bash
sudo reboot
```
Post-boot checks:
```bash
#Pi-hole
pihole status
#Dnscrypt-proxy
systemctl status dnscrypt-proxy
#Tailscape:
systemctl status tailscaled
#########
sudo wg show
ufw status
dig @127.0.0.1 google.com +dnssec
# should return NOERROR and 'ad' flag
'ad' = Authenticated Data
journalctl -u dnscrypt-proxy | tail
```



## Verify Services
```bash
pihole status          # Check Pi-hole status
pivpn -d               # Run PiVPN debug
systemctl status dnscrypt-proxy
```

## Next Steps
- Open/forward the chosen VPN port on your router (default WireGuard: 51820/UDP).
- Add your client profiles and test connectivity.

As you have finished reading this guide and you now have an idea of protecting your DNS traffic, I will reward you with the next step to further enhance the priacy of this setup by using anonymised relays, the current setup encrypts the DNS records from your ISP but they can still see your IP, so to prevent that we use anon relays and the setup for ipv4+6 is in the anon_relays_setup.toml

All you need to do to use my working file is save your current .toml file:

sudo su #(be root)

cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml > /etc/dnscrypt-proxy/dnscrypt-proxy.bak

#then rewite the whole file into the .toml file:

cat > /etc/dnscrypt-proxy/dnscrypt-proxy.toml

#(Copy the whole file then paste it here then do Ctrl D two times)

#lastly

sudo systemctl restart dnscrypt-proxy

sudo systemctl status dnscrypt-proxy

If it has an issue reading the cache file enter the command in the file i provided, if you still get errors, your favourite LLM can help as it may be a different error to what I had

Despite it adds latency, now you have a very very secure setup for your DNS traffic.
If you want better latency, just drop back to the normal file without the relays and customise the resolvers which is best suited for your area and latency.

Hope this gives you a solid basis, now I understand you may come across errors especially with updates changing how each service works, any good LM will help you resolve these issues and remember to keep the setup simple as you can.

Open to any criticism and advise, I would love to hear how this could be improved or seen from a better perspective if I have missed something.
