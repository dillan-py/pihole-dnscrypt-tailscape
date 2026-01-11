# pihole-dnscrypt-pivpn
Collection of working configurations and guides

<img width="1401" height="150" alt="image" src="https://github.com/user-attachments/assets/cf076436-84f6-4866-a835-15c2f5f90065" />
Htop result: 300-400 MB of RAM and low CPU usge makes this setup super lightweight and powerful.
#  Pi‑hole + DNSSEC + Tailscale (VPN)  
### A Secure, Private, Zero‑Trust DNS Infrastructure

DNS traffic is often left out the conversation when it comes to securing your network, mostly resorting to using VPNs without actually knowing how traffic regarding DNS is resolved and handled once it leaves your network.
This guide documents my personal DNS security stack built around **Pi‑hole**, **DNSSEC**, and **Tailscale**. The goal is simple:
Create a fast, trustworthy, privacy‑focused DNS resolver that works both on a home local network and remotely through a zero‑trust VPN mesh.
I have spent countless hours testing this concept through trial and error and what I have to show you worked best for me in the mind of keepinng it long term.



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



#################################

Why This Stack Works So Well
This setup is designed to be “configure once, trust forever.”
To really appreciate what’s happening under the hood, let’s walk through a real‑world moment.
You’re on your computer.
You open YouTube to play music from your favourite artist, and at the same time you draft an email to a friend on Yahoo Mail.
Behind the scenes, this is what actually happens:

🎯 1. Your Device Makes DNS Requests
Before loading anything, your computer needs to translate domain names into IP addresses:
• 	
• 	
These aren’t websites yet—they’re just names.
Your device asks your configured DNS resolver (your Pi‑hole) to look them up.

🧱 2. Pi‑hole Intercepts and Filters
Pi‑hole becomes the first checkpoint:
• 	It blocks known ad, tracker, and malicious domains
• 	It logs and filters requests at the network edge
• 	It ensures nothing shady slips through before DNSSEC even enters the picture
If a domain is on a blocklist, the request dies here—never reaching the internet.

🔐 3. DNSSEC Validation Kicks In
For allowed domains, Pi‑hole forwards the request to your upstream resolver (e.g., Unbound or DNSCrypt).
This resolver performs DNSSEC validation:
• 	It checks the cryptographic signatures attached to DNS records
• 	It verifies the chain of trust from the root → TLD → authoritative server
• 	It rejects anything forged, altered, or injected en‑route
If the signature doesn’t match, the response is dropped.
If it does match, the resolver returns a validated, authentic DNS answer.
This is what protects you from DNS spoofing, phishing redirections, and MITM tampering.

🌐 4. Tailscale Extends This Security Everywhere
If you’re away from home—coffee shop, hotel, mobile hotspot—your device still routes DNS through your Pi‑hole using Tailscale’s zero‑trust mesh.
That means:
• 	Same DNS filtering
• 	Same DNSSEC validation
• 	Same privacy guarantees
• 	No exposure to the local network’s DNS resolver
Your DNS stays inside your own trusted infrastructure, no matter where you are.

🚀 5. Your Browser Finally Connects
Only after all of this:
• 	YouTube loads using a verified IP
• 	Yahoo Mail loads using a verified IP
• 	No ads, no trackers, no forged DNS, no silent redirections
You just see your music and your email.
Everything else—the filtering, validation, cryptography, routing—is invisible and automatic.

# WARNING!!!
Be careful what you add to your blocklist, too many can block functionality of applications which means spending more time debugging it. So if you are going to go crazy with the blocklists, ensure to add whitelists so you regain access to legitimate domains.

Once Pi‑hole, DNSSEC, and Tailscale are aligned, your DNS threat surface shrinks dramatically:
• 	Local devices resolve through a trusted, validated DNS pipeline
• 	Remote devices use the same resolver through a zero‑trust mesh
• 	DNS forgery attempts fail silently
• 	Ads, trackers, and malicious domains get filtered at the network edge
You don’t need to babysit it. You don’t need to tweak it weekly.
You get a stable, predictable DNS foundation that just keeps working.
Security is an illusion, we cannot guarantee 100% security in all areas but we can always try our best to get what we can right, that way we are better prepared for what's to come
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
