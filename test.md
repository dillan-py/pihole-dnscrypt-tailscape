
# Secure Pi Setup using Pi-hole, Pi-VPN with DNSCrypt
```mathematica
Clients → Pi-hole → DNSCrypt → Internet
VPN clients → PiVPN → Pi-hole → DNSCrypt → Internet
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
Pi-hole and PiVPN break without this.

Before installing Pi-Hole, ensure that you have set a static ip for your Pi on your router, most routers will let you reserve an IP address if you provide a name, MAC and IP. This will prevent the Pi changing to another IP by DHCP over time.

And if it lets you change the DNS, set it to the IP of the Pi, if your router doesn't allow you to do this, each device will only need to change their DNS setting to the IP of the Pi on the network

Edit:
```bash
sudo nano /etc/dhcpcd.conf
```
Edit or add: (replace X with the IP of your Pi use 'ip a' to see the ip on eth0 or wlan0 whichever you use, if you use wlan0, ensure you are using that interface)
```ini
interface eth0
static ip_address=192.168.0.X/24
static routers=192.168.0.1
static domain_name_servers=127.0.0.1
```
Reboot:
```bash
sudo reboot
```
Confirm:
```bash
ip a
ip route
```

## Step 3: Install Pi-Hole
```bash
curl -sSL https://install.pi-hole.net | bash
```

After install:
```bash
pihole status
```

```bash
curl -sSL https://install.pi-hole.net | bash
```


**Important choices during install:**

- **Upstream DNS:** Any (this is only temporary; later change to custom DNS: `127.0.0.1#5353` as DNSCrypt will use this)
- **Web interface:** Yes
- **Blocklists:** Default is fine





## Install PiVPN (WireGuard/OpenVPN)
```bash
curl -L https://install.pivpn.io | bash
# Follow the interactive installer to choose WireGuard or OpenVPN
```

## Configure DNSCrypt
```bash
sudo apt install -y dnscrypt-proxy
sudo systemctl enable dnscrypt-proxy
sudo systemctl start dnscrypt-proxy
```

## Verify Services
```bash
pihole status          # Check Pi-hole status
pivpn -d               # Run PiVPN debug
systemctl status dnscrypt-proxy
```

## Next Steps
- Configure Pi-hole upstream DNS to point to `127.0.0.1#53` if using DNSCrypt as local resolver.
- Open/forward the chosen VPN port on your router (default WireGuard: 51820/UDP).
- Add your client profiles and test connectivity.
