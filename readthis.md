# Pi-hole + DNSSEC + Tailscale  
Secure, Private, Ad-Blocking DNS — Works at Home & Remotely

Lightweight, powerful setup using **Pi-hole** (blocks ads, trackers & malware), **DNSSEC** (verifies DNS answers are authentic), and **Tailscale** (zero-trust VPN for remote access).

**Real-world resource usage** (tested on Raspberry Pi 5):  
~300–400 MB RAM | Very low CPU usage  
→ Extremely efficient and rock-solid for long-term use.

## Quick DNSSEC Test (Do this first!)
Visit: https://wander.science/projects/dns/dnssec-resolver-test/

- **Passes** → You're already somewhat protected — this guide makes it much stronger  
- **Fails** → Your DNS can be easily forged → Follow this setup!

## How It Works (Simple Step-by-Step Flow)

1. Your device asks: "What's the IP of youtube.com?"
2. **Pi-hole** checks the request → Instantly blocks ads, trackers, or malware domains
3. Clean request → Forwarded to **dnscrypt-proxy** (encrypted transport + DNSSEC validation)
4. dnscrypt-proxy verifies cryptographic signatures → Rejects anything fake or tampered
5. Valid answer → Returned to your device
6. Away from home? **Tailscale** securely routes the request through your home Pi-hole → Same protection everywhere

→ You get clean, verified, ad-free internet — automatically.

## Key Features

- Full **DNSSEC validation** → Protects against DNS spoofing, phishing & man-in-the-middle attacks
- Network-wide ad, tracker & malware blocking (Pi-hole)
- Remote access with **Tailscale** zero-trust mesh VPN
- Balanced, stable blocklists (OISD + StevenBlack + custom telemetry blocks)
- Focus on reliability → Minimal breakage of legitimate sites

## Recommended Hardware & Setup Tips

- **Raspberry Pi 5** (2 GB minimum, 4–8 GB recommended — rarely exceeds 1 GB usage)
- Good case **with fan** for proper cooling
- Official Raspberry Pi power supply (5V/5A)
- **Raspberry Pi OS Lite 64-bit** (lightweight → fewer vulnerabilities)
- Connect via **Ethernet** (eth0) — Wi-Fi noticeably reduces performance
- Set up **SSH with public key authentication only** (disable password + root login)
- Keep the Pi in a cool, dry, safe location

## Important Tips & Warnings

- **Don't overload blocklists** — Too many lists = broken apps/websites = endless debugging  
  → Start with quality lists + whitelist when needed
- Some sites may load slowly or break with strict DNSSEC → Use clean (no extra filtering) resolvers
- **Choose ONE privacy method**: DNSCrypt **or** DoH — never mix them
- Pick resolvers close to your location (UK/Europe best for low latency)
- If a resolver stops working → Update the signer keys from the official list

## Recommended UK-Friendly DNSCrypt Resolvers (2026 – No-filter, DNSSEC-supporting)

Official list: https://github.com/DNSCrypt/dnscrypt-resolvers

Good choices for London/UK:
- `a-and-a` — Andrews & Arnold (UK), non-filtering, no-logging, DNSSEC
- European relays (`anon-cs-*` series) — Germany, France, Netherlands (excellent speed & privacy)

Example in `dnscrypt-proxy.toml`:
```toml
server_names = ['a-and-a', 'cloudflare', 'quad9-dnscrypt-ip4-filter-pri']

```text
Device (home or remote) ──► Tailscale (encrypted mesh) ──► Pi-hole
                                            │
                                            ▼
                                     dnscrypt-proxy (local)
                                            │
                                            ▼
                                 Public resolver (DNSSEC + encrypted)
```




Tailscale advantages:

Works behind CGNAT (no port forwarding needed)
Stable private IPs (100.x.x.x range)
Turns your Pi-hole into your global DNS resolver

→ No need for PiVPN — Tailscale is simpler, more reliable, and more modern.
Quick Setup Steps (High-level)

Flash Raspberry Pi OS Lite 64-bit using Raspberry Pi Imager
Enable SSH → Set up public key auth → Harden /etc/ssh/sshd_config
Connect via Ethernet
Install Pi-hole → Choose balanced blocklists
Install dnscrypt-proxy
→ Follow: https://docs.pi-hole.net/guides/dns/dnscrypt-proxy/
Edit dnscrypt-proxy.toml → Select UK/EU servers + enable DNSSEC
In Pi-hole → Settings → DNS → Set upstream to 127.0.0.1#5053 (or your dnscrypt port)
Install Tailscale on the Pi:
sudo tailscale up --accept-dns=false
In Tailscale admin console → Set Pi-hole as global DNS nameserver → Enable override
Pi-hole → Settings → DNS → Expert → Permit all origins
Test everything:
DNSSEC test site
Ad-blocking on phone/laptop (both locally & remotely)


Enjoy a cleaner, safer, faster internet — everywhere you go! 🛡️
