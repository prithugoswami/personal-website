---
title: "RPi server, wireguard mesh and iptable"
date: 2023-01-06T00:23:53+05:30
draft: true
---

A few months ago, I wanted to host files directly from a 1TB hard disk on the
public net. These files were just some photos and videos that I wanted to share
with some peeps. Nothing fancy, just a webdav server using
[rclone](https://rclone.org/commands/rclone_serve_webdav/) would do&mdash;a
very ad-hoc setup as you can see. I wanted it to be reachable at
`share.prithu.dev` to give it a short friendly remeberable name. I used the RPi
4 to be the host. I attached the 1TB hard drive to one of it's usb ports,
`mount`'d the drive at `/mount/hdd` and ran:

```
rclone serve webdav --user foo --pass secret --addr 0.0.0.0:8080 /mount/hdd/shared-dir
```

This is simple enough and now all I need to do is, using port-forwarding rules
on my router, expose this port to the world and and then point
`share.prithu.dev` to my home's IP address, and bob's your uncle … or is he?
Well, the glaring problem here is me exposing my home ip&mdash;which is, to say
the least, a bad practice and something that I want to avoid. Also, there's the
problem of dynamic IPs of home broadband, but that's a fairly easy problem to
solve by writing a script[^1] to update the dns records every X minutes.

[^1]: something like this: https://git.prithu.dev/dotfiles/blob/master/bin/scripts/update_home_dns.sh

I can setup a VPS with a public facing port that I can use as a proxy between
the RPi and the internet. I can listen on the VPS and forward the connection to
the RPi. The VPS acts as a relay server and routes packets to the rpi. One way
to do this is using good ol' ssh tunnels (port forwarding) using the `-R`
option to forward the remote port to my RPi. In my experience however, I have
found ssh tunnels to be a little unreliable, especially when it comes to spotty
home broadband connection; due to which the connection breaks and you will have
to either restart the client or write a script or a service to restart the
client automatically. I wanted the server to be reliablly hosted for as long as
it was required with minimum to no maintainance from my side so I thought to
try my hands on wireguard and in the process also learn more about it.


## The final setup

This is how the final setup is going to be:

{{< figure src="/img/mesh-setup.png" title="setup of rpi with vps" width="100%" >}}

Here's the wireguard network consisting of the RPi and VPS. I also have my laptop
and phone connected as well, but I left them out of the diagram for simplicity.
The devices are assigned private IP addresses in the subnet of `10.8.0.0/24`.
(an arbitrary choice; something different from the usual `10.0.0.0/24`)

## What is Wireguard?

[Wireguard](https://www.wireguard.com/), simply put, allows you create VPN
tunnels. You can also connect multiple hosts (Peers) and form a mesh of
interconnected devices within your private network.
Wireguard is very easy to setup, infact, it's one of their aims to be as easy
to setup as SSH. Here's a quote from the wireguard homepage:

> WireGuard aims to be as easy to configure and deploy as SSH. A VPN connection
> is made simply by exchanging very simple public keys – exactly like
> exchanging SSH keys – and all the rest is transparently handled by WireGuard.
> It is even capable of roaming between IP addresses, just like Mosh. There is
> no need to manage connections, be concerned about state, manage daemons, or
> worry about what's under the hood. WireGuard presents an extremely basic yet
> powerful interface.





```
Cover:

- add config for each device (laptop, phone, rpi and vps) to explain the mesh
  network and have a small diagram of the mesh network
- mini ups with link
- one photo of the whole setup 

The Class A range (`10.0.0.0 to 10.255.255.255`) is the most common one used.
It's easier on the eyes and also easy to remember (I mean what would you rather
prefer&mdash;`10.5.0.1` or `172.16.5.1`?); You also have a big range of values
to choose from.


[Interface]
Address = 10.24.0.1/24
ListenPort = 52499
PrivateKey = 6HTkKeOeHLb92PPQ4DYBNUC/TSZqqJLFXe8zWEEAf0Q=
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE

[Peer]
PublicKey = UB8PUnmfnF2e54651NF1rAbOcB/Ud5dVq49rJd4BNzE=
AllowedIPs = 10.24.0.3/32
Endpoint = 122.171.44.71:54035

[Peer]
PublicKey = kZPtUBJWwTNAkLWtfRxoe20UYToAV3brFBxbJRorEG4=
AllowedIPs = 10.24.0.4/32

[Peer]
PublicKey = COCePzCqoQHaaTlbniqGUJIZwpzRwTWjoaAt/puTc3g=
AllowedIPs = 10.24.0.2/32



links:

```
## Setting up the wireguard mesh

### On the VPS

1. **Install wireguard**. Wireguard is [available pretty much
   everywhere](https://www.wireguard.com/install/). You can also [compile it
   from source](https://www.wireguard.com/compilation/). The instructions on
   the website are pretty straighforward and easy to follow. On my ubuntu VPS
   it's just:

   ```
   sudo apt install wireguard
   ```

2. **Generate keypair**. Wireguard works with simple public and private key pair.
   Each peer in the wireguard network has a public-private key pair associated
   with it. The keys are what the pees use to authenticate themsevles and
   encrypt the packets. the `wg` utility can be used to generate these key
   pairs `setukp the`

   ```
   umask 077
   wg genkey | tee privatekey | wg pubkey > publickey
   ```
