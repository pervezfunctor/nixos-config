# NixOS Backup Server

This repository provides a reproducible setup for a fully encrypted, headless NixOS server used for remote backups.

## Features

* 🛡️ Full-disk encryption with LUKS
* 🔓 Remote unlock via Dropbear SSH in initrd
* 🌐 Tailscale for remote access
* 💾 Restic backups to Backblaze B2 and optionally to a local NAS
* 📦 Declarative, reproducible NixOS configuration using flakes

## Setup Workflow

### 1. Boot Into NixOS Minimal ISO

* Boot the machine using the [NixOS minimal ISO](https://nixos.org/download).
* Ensure network is up (use `ip a` and `ping` to verify).

### 2. Clone This Repo and Run the Installer

```bash
nix-shell -p git
sudo git clone https://github.com/yourname/nixos-backup-box
cd nixos-backup-box
sudo ./install.sh /dev/sdX  # Replace sdX with your actual disk, e.g., /dev/sda
```

### 3. Post-Install

* System will install from flake and prompt for root password.
* Reboot the system.
* Dropbear SSH should allow you to unlock remotely.

### 4. Remote Unlock Example

```bash
ssh -i ~/.ssh/id_ed25519 root@<server-ip>
cryptroot-unlock
```

### 5. After Unlock

* Tailscale starts.
* Restic runs via systemd timer to B2 and NAS.

## Requirements

* B2 credentials stored in `/etc/restic-env`:

  ```bash
  export B2_ACCOUNT_ID=...
  export B2_ACCOUNT_KEY=...
  ```
* Restic password stored in `/etc/restic-password`

## Secrets and Notes

* You can optionally generate a keyfile and store it in `/etc/secrets/keyfile.bin`.
* Use `mkpasswd -m yescrypt` to generate a secure root password hash.

## License

MIT or CC0 (Public Domain) — your choice.
