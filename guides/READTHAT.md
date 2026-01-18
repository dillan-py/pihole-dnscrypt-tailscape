# Pi-hole + DNSCrypt + Tailscale  
### Secure, Private, DNS Infrastructure — At Home and Everywhere

<img width="1553" height="893" alt="Architecture overview" src="https://github.com/user-attachments/assets/57493399-3db8-4fea-a6e0-ef071d2e6b92" />

**Pi-hole dashboard** — Blocking ~1 million domains is usually plenty for ads + malicious content.  
<img width="1401" height="150" alt="Pi-hole stats" src="https://github.com/user-attachments/assets/cf076436-84f6-4866-a835-15c2f5f90065" />

**Resource usage** — Typically 300–400 MB RAM and very low CPU. Lightweight yet powerful.  
<img width="624" height="283" alt="htop screenshot" src="https://github.com/user-attachments/assets/9c3c3a42-6bda-4d3d-b21c-bec449af485d" />

Most people focus on VPNs for traffic encryption but overlook DNS — the system that translates domain names (like github.com) to IP addresses. Once DNS leaves your control, your ISP, public Wi-Fi, or attackers can spy on it, tamper with it, or redirect you.

This setup creates a **fast, trustworthy, privacy-first DNS resolver** that works seamlessly:
- at home (local network), and  
- remotely (via zero-trust VPN).

### Core Components

- **Pi-hole**  
  A network-wide DNS sinkhole. It acts as your DNS server and blocks unwanted domains (ads, trackers, malware, telemetry) by returning fake/no answers for them. No software needed on client devices — protection happens at the network level.

- **dnscrypt-proxy**  
  A flexible DNS proxy client that encrypts DNS queries (using DNSCrypt v2, DoH, Anonymized DNS etc.) and — crucially — performs **DNSSEC validation**.  
  DNSSEC cryptographically verifies that DNS answers come from the legitimate source and haven't been tampered with in transit. This stops DNS spoofing, cache poisoning, and man-in-the-middle redirection attacks.

- **Tailscale**  
  A modern, zero-config mesh VPN built on WireGuard. It creates a private, encrypted virtual network between your devices (called a "tailnet"). This lets phones, laptops, etc. securely route DNS traffic back to your home Pi-hole — no port forwarding, no public exposure, works behind NAT/CGNAT.

### How It Works – Step by Step

1. Your device needs github.com → asks: “What’s its IP?”  
2. **Pi-hole** receives the query → checks blocklists  
   - Blocks ads/trackers/malware instantly → request ends here  
   - Allowed → forwards to dnscrypt-proxy  
3. **dnscrypt-proxy** encrypts the query (hides it from ISP/local network)  
   + performs **DNSSEC validation** → checks cryptographic signatures  
   - Invalid/forged → dropped  
   - Valid → returns authentic answer  
4. Clean, verified IP → returned to your device  
5. Away from home?  
   **Tailscale** tunnels the DNS request securely back to your home Pi-hole  
   → Same blocking + same DNSSEC checks + same privacy — on any network

**Result**: Ad-free, tracker-free, spoofing-resistant browsing that feels automatic and fast.

### Quick DNSSEC Check (Before You Start)

Test your current resolver here:  
→ https://wander.science/projects/dns/dnssec-resolver-test/

- **Passes** → You're already somewhat protected — this guide strengthens & centralizes it.  
- **Fails** → Your DNS can be forged. Follow along to fix it.

### Important Notes & Realistic Expectations

- **Blocklist caution** — Too aggressive = broken apps/sites. Whitelist liberally. Start conservative.  
- **YouTube / in-app ads** — Often delivered via HTTPS (not DNS) → Pi-hole can't block them all.  
- **DNSSEC strictness** — Some resolvers/domains have broken signatures. Use clean, no-filter DNSCrypt servers (from official list) if you hit issues.  
- **DoH vs DNSCrypt** — Pick one protocol type; mixing causes conflicts.  
- **Location matters** — Choose nearby/low-latency DNSCrypt resolvers (UK-friendly list included; find others if needed).  

Once set up, your DNS becomes:
- Network-wide & remote-capable  
- Cryptographically authenticated  
- Filtered at the edge  
- Almost maintenance-free  

Security isn't absolute, but this dramatically reduces your DNS attack surface.

### Features Summary

- **DNSSEC validation** — Prevents spoofing/tampering/MITM  
- **Network-wide blocking** — Ads, trackers, telemetry (OISD + StevenBlack + custom)  
- **Tailscale integration** → Global DNS via zero-trust mesh (MagicDNS optional)  
- **Lightweight & stable** — Runs great on Raspberry Pi 5 (2 GB+), low resources  

Ready to build it? → Jump to the [Installation / Setup Guide](#installation)
