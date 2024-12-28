---
title: Setting up wireguard VPN
date: 2023-11-27T15:23:00Z
slug: wireguard-vpn-setup
tags:
- linux
- wireguard
---
### Server Setup

```
[Interface]
PrivateKey = yMvNoQjJrhKBi9BM1GVDOgp12002CBsafprcucOLNXM=
Address = 10.0.0.1/24
PostUp = iptables -A FORWARD -i wg1 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg1 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE
ListenPort = 52498

[Peer]
PublicKey = VikFbA8ELVftC2Hzz7ukYCxTT229g2GxkwXmXMwqZhw=
AllowedIPs = 10.0.0.2/32

[Peer]
PublicKey = oIHBz1u1kCu+5UnDmPCQ5kyQmGpHup3YIISPOK1B21Y=
AllowedIPs = 10.0.0.3/32

```

### Client Setup

```
[Interface]
Address = 10.0.0.2/32
PrivateKey = GY37SEG1RHkdxaxoj+fz3GwE/EqJxDbRK/684pRS13M=
DNS = 1.1.1.1

# Server info
[Peer]
PublicKey = Xwf/2RaaGu4rvvMxJx8oebFMx1LPSU49bUtYsAhGQUU= 
Endpoint = {SERVER_PUBLIC_IP}:52498
# Reach out to the Wireguard Server for every IPv4 address
# All our IPv4 traffic will be "routed" through the server
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25

```

- `ListenPort` can be any random port number. Make sure the UDP port is allowed by the firewall on the server
- replace `ens3` with an actual interface name available on the server
