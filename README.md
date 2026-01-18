#  Pi‑hole + DNSCrypt + Tailscale (VPN)  
### A Secure, Private, Zero‑Trust DNS Infrastructure

<img width="1553" height="893" alt="pic5" src="https://github.com/user-attachments/assets/57493399-3db8-4fea-a6e0-ef071d2e6b92" />

**Pi-hole Interface:** Under 1M domains is enough for blocking ads and malicous content.

<img width="1401" height="150" alt="image" src="https://github.com/user-attachments/assets/cf076436-84f6-4866-a835-15c2f5f90065" />
**Htop result:** 300-400 MB of RAM and low CPU usage makes this setup super lightweight and powerful.

DNS traffic is often left out the conversation when it comes to securing your network, mostly resorting to using VPNs without actually knowing how traffic regarding DNS is resolved and handled once it leaves your network.

This repository imlements a DNS security stack built around **Pi‑hole**, **DNSCrypt**, and **Tailscale**.

The goal is simple:
- Create a fast, trustworthy, privacy‑focused DNS resolver that works both on a home local network and remotely through a zero‑trust VPN mesh.

I have spent countless hours testing this concept through trial and error and what I have to show you worked best for me in the mind of keeping it long term.



Before configuring anything, verify whether your current DNS resolver actually validates DNSSEC:
# Run the test:
https://wander.science/projects/dns/dnssec-resolver-test/
- If the test passes:
You’re already protected. This guide will help you strengthen and modernize what you have.
- If the test fails:
Your system in your network is vulnerable to DNS forgery. Attackers can spoof DNS responses, redirect you to phishing sites, or poison your cache.
After following this guide, your resolver will correctly validate DNSSEC signatures and block forged DNS data.

# Why DNSSEC Validation Matters
When a DNS record is signed, your resolver can verify its cryptographic signature and confirm:
- The record originated from the authoritative server, and
- The data was not modified en‑route,
- Therefore preventing forged responses commonly used in spoofing, phishing, and MITM attacks.
DNSSEC doesn’t encrypt DNS traffic — it **authenticates** it. That authentication is what stops attackers from silently rewriting your internet.



## How It Works – Simple Step-by-Step

This setup gives you **ad-free, tracker-free, and spoofing-resistant DNS** — at home and everywhere else — automatically.

1. Your device wants to visit youtube.com  
   → It asks: “What’s the IP address of youtube.com?”

2. **Pi-hole** (your local DNS filter) checks the request first  
   → Instantly **blocks** ads, trackers, malware, or anything on your blocklists  
   → If blocked → request dies here (no internet traffic wasted)

3. Clean request → forwarded to **dnscrypt-proxy**  
   → Encrypts the DNS query (hides it from ISP & local network)  
   → Performs **DNSSEC validation** (checks cryptographic signatures)

4. dnscrypt-proxy verifies everything  
   → Makes sure the answer is **genuine**, not forged or tampered with  
   → Rejects fake / altered responses (protection against DNS spoofing & MITM)

5. Valid & signed answer → sent back to your device  
   → Your browser / app now connects using a **trusted, verified IP**

6. Away from home?  
   → **Tailscale** securely tunnels your DNS traffic back to your home Pi-hole  
   → Same filtering + same DNSSEC validation + same privacy — everywhere  
   → Coffee shop, hotel, mobile data → still protected

### What You Actually Experience

You just open YouTube, Spotify, email…  
→ No ads  
→ No trackers  
→ No DNS spoofing or silent redirections  
→ Everything loads faster and cleaner — automatically

All the filtering, encryption, signature checking and secure routing happens invisibly in the background.

# WARNING!!!
Be careful what you add to your blocklist, too many can block functionality of applications which means spending more time debugging it. So if you are going to go crazy with the blocklists, ensure to add whitelists so you regain access to legitimate domains.
Home users may report some sites wont load correctly/slowly when requiring dnssec for all traffic, so my reccomendation is to use a dnscrypt resolver that has no filters.
You can use DOH resolvers however, best not to mix with dnscrypt resolvers, keep it to one as it can only use one at a time (can't use both) as they are two different types of privacy.
Use the resolvers from the ones in the resolvers link, if you get an error that it cant find it, you need to replace the signers key as it should read all the ones you use from the list.
Find some more resolvers for dnsscrypt if your location is different to the UK

Once Pi‑hole, DNSSEC, and Tailscale are aligned, your DNS threat surface shrinks dramatically:
- 	Local devices resolve through a trusted, validated DNS pipeline
- 	Remote devices use the same resolver through a zero‑trust mesh
- 	DNS forgery attempts fail silently
- 	Ads, trackers, and malicious domains get filtered at the network edge
You don’t need to babysit or need to tweak it weekly.
You get a stable, predictable DNS foundation that just keeps working.
Security is an illusion, we cannot guarantee 100% security in all areas but we can always try our best to get what we can right, that way we are better prepared for what's to come.
---

##  Features

###  DNSSEC Validation
All DNS responses are cryptographically validated to prevent spoofing, tampering, or MITM attacks.

###  Network‑wide Ad & Tracker Blocking
Pi‑hole filters:
- Advertising networks  
- Telemetry endpoints  
- Cross‑site trackers  
- High‑risk analytics domains  

All curated to avoid breaking essential services like Signal, Tailscale, or OS updates.

###  Tailscale Mesh VPN Integration
Tailscale provides:
- Encrypted connectivity  
- Stable 100.x.x.x addressing  
- Remote DNS routing  
- Optional MagicDNS  

This allows Pi‑hole to act as a **global DNS resolver** for all devices.

### Clean, Minimal Blocklists
Uses:
- OISD  
- Steven Black (base)  
- Custom deny‑lists for telemetry and tracking  

Balanced for privacy and stability.

---

## 🏗️ Architecture Overview




# My reccomendations
Use the Pi 5 with a minimum of 2GB (The more the better, although since I have ran mine it hasn't even gone past 1GB RAM, you can still use it for other purposes later on.
Use a secure case with a fan ensuring good cooling, and kept away from any areas of high static/humidity/leaking/water exposure/ extreme temperatures etc.
Ensure to use the Pi power supply, which powers the Pi at it's reccomended 5V and 5A.
Use Raspberry Pi OS lite (64-Bit) - using the Raspberry Pi Imager app - Extremely lightweight OS, less to go wrong therefore less vulnerabilities will develop on the OS overtime compared to most OS' and has a quick reboot.
Enter a username and password for initial configuration, for the wifi, as we will be using eth0, remove any inputs for it and continue, only if you cannot connect your pi to your router via a rj45 cable use Wifi - performance will be impacted
Once you have powered on your Pi and connected a keyboard and monitor to it, login and configure ssh using a public key:

Ensure ssh is enabled and running, 
Type whoami and hostnamectl -I
Use that to ssh into it:
whoami@ip_address
Simply put, generate the keys oon your client (windows pc/mac/linux), then transfer it to the pi 
Now once you can ssh without a password, set the /etc/ssh/sshd_config to no root login, passwordless etc etc
A guide for this...
Can use termius on your phone if you want easy access.

This way you can access the cli remotely without having to constantly connect a keyboard and monitor to work on it as you will have to paste some commands in ans is not a GUI.


Connect the Pi to your router (router-enabled-switch)
Route all traffic via eth0
You can attempt to use pivpn although if you are behind a CGNAT this will not work as intended which tailscape effectivaly bypassses and makes our life easier.

