# Pi is #53, DNSCrypt is the upstream 5053:
```mathematica
Client → Pi‑hole (port 53) → dnscrypt‑proxy (port 5053) → encrypted DNS upstream
```
```bash
sudo curl -sSL https://install.pi-hole.net | bash
sudo pihole setpassword
sudo pihole enable
  151  sudo pihole-FTL --config dns.upstreams '["127.0.0.1#5053","[::1]#5053"]'
  152  sudo pihole-FTL --config dns.upstreams '["127.0.0.1#5053","::1#5053"]'

   153  sudo systemctl restart dnscrypt-proxy.socket
  154  sudo systemctl restart pihole-FTL
  155  sudo pihole reloaddns #if it fails use 'sudo pihole reloaddns'


 sudo apt install dnscrypt-proxy -y
  259  sudo mkdir -p /etc/systemd/system/dnscrypt-proxy.socket.d
  260  sudo nano /etc/systemd/system/dnscrypt-proxy.socket.d/override.conf
  261  sudo systemctl daemon-reload
  262  sudo systemctl restart dnscrypt-proxy.socket
  263  sudo systemctl restart dnscrypt-proxy.service
  264  systemctl cat dnscrypt-proxy.socket
  265  ss -lunpt | grep 5053
  266  sudo nano /etc/dnscrypt-proxy/dnscrypt-proxy.toml

  dig @127.0.0.1 -p 5053 example.com
  275  sudo journalctl -u dnscrypt-proxy.service -n 50 --no-pager
  276  dig @127.0.0.1 -p 5053 cloudflare.co
```
    285  sudo pihole-FTL --config dns.upstreams
# check your dns upstream:
  sudo pihole -t

    288  dig @127.0.0.1 -p 5053 dnssec-failed.org
  289  dig dnssec-failed.org -----should not show 127.0.0.1

#  ###LIFE SAVER:::
 ```bash
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
```
 ** IF THE ABOVE AIN'T GREEN, i hate to say it but it aint workin..., FULL STOP.!**
  
  

  
