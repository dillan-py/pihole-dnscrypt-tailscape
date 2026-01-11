# pihole-dnscrypt-pivpn
Collection of working configurations and guides

<img width="1401" height="150" alt="image" src="https://github.com/user-attachments/assets/cf076436-84f6-4866-a835-15c2f5f90065" />

#  Pi‑hole + DNSSEC + Tailscale (VPN)  
### A Secure, Private, Zero‑Trust DNS Infrastructure

This project documents my personal DNS security stack built around **Pi‑hole**, **DNSSEC**, and **Tailscale**. The goal is to create a fast, trustworthy, privacy‑focused DNS resolver that works both on my local network and remotely through a zero‑trust VPN mesh.
I have spent countless hours testing this concept through trial and error and what I have to show you worked best for me in the mind of keepinng it long term.

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
