# hosts/backup-box/configuration.nix
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "backup-box";
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;  # or set static IP

  time.timeZone = "UTC";

  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "us";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/sda2";
    preLVM = true;
    allowDiscards = true;
    keyFile = "/etc/secrets/keyfile.bin";
  };

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
  boot.initrd.network.ssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcXIDK5n+AIXExMo9nt1PRGcowyvyZUPvhBGRJRGMAl pervez@fedora"
  ];
  boot.initrd.network.postCommands = ''
    ip route add 100.64.0.0/10 via <tailscale-gateway-ip>
  '';

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "prohibit-password";

  users.users.root = {
    hashedPassword = $y$j9T$2JSxq/oj.r/lRB0dTYYP01$RmiuFEGciDGkdnKj2dU6B7b0zIy0JJNbKa6AhFAr2t3
  };

  programs.git.enable = true;
  programs.tailscale.enable = true;

  services.restic.backups = {
    b2 = {
      repository = "b2:your-bucket-name:path";
      passwordFile = "/etc/restic-password";
      environmentFile = "/etc/restic-env";
      paths = [ "/home" "/var/lib" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    nas = {
      repository = "/mnt/nas-backups";
      passwordFile = "/etc/restic-password";
      paths = [ "/home" "/var/lib" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };

  fileSystems."/mnt/nas-backups" = {
    device = "192.168.1.100:/volume1/backups";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };

  environment.systemPackages = with pkgs; [
    vim htop git curl wget restic tailscale nfs-utils
  ];

  system.stateVersion = "24.05";
}
