---
title: installing nixos on oracle cloud arm instance
date: 2024-11-06T12:03:00Z
slug: installing-nixos-on-oracle-cloud-arm-instance
tags:
- nixos
- oracle cloud
---

1. Download netboot efi 

   ```
   wget https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi
   ```
2. Move it to `/boot/efi/`
3. Open cloud shell connection from the instance page. On the instance page it's labeled "Console Connection" under "Resources"
4. "Reboot" the instance
5. Continuously press Esc in the cloud shell. EFI boot manager pops up. Then open the EFI shell and type `fs0:netboot.xyz-arm64.efi`
6. Select NixOS from the netboot menu
7. Install nix os (follow wiki)

