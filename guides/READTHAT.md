# Pi-hole + DNSCrypt + Tailscale  
### Secure, Private, DNS Infrastructure — At Home and Everywhere

This setup creates a **fast, trustworthy, privacy-first DNS resolver** that works seamlessly:
- At home (local network)
- Remotely (via zero-trust VPN)

<img width="1553" height="893" alt="Architecture overview" src="https://github.com/user-attachments/assets/57493399-3db8-4fea-a6e0-ef071d2e6b92" />

**Pi-hole dashboard** — Blocking ~1 million domains is usually plenty for ads + malicious content.  
<img width="1401" height="150" alt="Pi-hole stats" src="https://github.com/user-attachments/assets/cf076436-84f6-4866-a835-15c2f5f90065" />

**Resource usage** — Typically 300–400 MB RAM and very low CPU. Lightweight yet powerful.  
<img width="624" height="283" alt="htop screenshot" src="https://github.com/user-attachments/assets/9c3c3a42-6bda-4d3d-b21c-bec449af485d" />

Most people focus on VPNs for traffic encryption but overlook DNS — the system that translates domain names (like github.com) to IP addresses. Once DNS leaves your control, your ISP, public Wi-Fi, or attackers can spy on it, tamper with it, or redirect you.

This setup creates a **fast, trustworthy, privacy-first DNS resolver** that works seamlessly:
- At home (local network)
- Remotely (via zero-trust VPN)

## Core Components

### Pi-hole
- Network-wide DNS sinkhole  
- Acts as your DNS server  
- Blocks ads, trackers, malware, and telemetry by returning fake/no DNS answers  
- No software required on client devices  
- Protection happens at the network level  

### dnscrypt-proxy
- Flexible DNS proxy that encrypts DNS queries  
- Supports DNSCrypt v2, DoH, and Anonymized DNS  
- **Performs full DNSSEC validation locally**  
- Ensures DNS answers are authentic and untampered  
- Protects against DNS spoofing, cache poisoning, and MITM attacks  

### Tailscale
- Zero‑config mesh VPN built on WireGuard  
- Creates a private, encrypted network between your devices (“tailnet”)  
- Allows remote devices to securely use your home Pi-hole  
- No port forwarding or public exposure required  
- Works behind NAT and CGNAT  

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

#### Why use DNSCrypt resolvers instead of DoH/DoT?
- DNSCrypt v2 provides **stronger metadata protection** than DoH/DoT (no SNI, no ALPN fingerprinting)  
- Supports **Anonymized DNS**, hiding your IP from the upstream resolver  
- Resolver lists are **curated, transparent, and community‑audited**  
- Many DNSCrypt resolvers explicitly commit to **no logging**, **no filtering**, and **DNSSEC support**  
- dnscrypt-proxy handles DNSSEC **locally**, so you don’t rely on upstream validation  

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
