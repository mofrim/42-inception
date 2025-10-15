{ lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/refs/heads/release-25.05.tar.gz";
in
{
  imports =
    [
      (import "${home-manager}/nixos")
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # all the software i need
  environment.systemPackages = with pkgs; [
    labwc

    st-snazzy
    brave
    gnumake
    
    vim
  ];

  users = {
    users.root.hashedPassword = "PW_GOES_HERE";
    users.fmaurer = {
      isNormalUser = true;
      uid = 42;
      openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFG0nJF3ZMmkgkSAG42VOUyN65w0wSEPeZ+229UiZqW1 fmaurer@42" 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlhRzDpd+8nwaDMnAeXjpyM/M0RhCA7LYZCEFKHWYI7 mofrim@posteo.de"
      ];

      hashedPassword = "PW_GOES_HERE";
      extraGroups = [ "wheel" "docker" ];
    };
  };

  # autologin fmaurer on first boot
  services.getty = {
    autologinUser = "fmaurer";
    autologinOnce = true;
  };

  home-manager.users.fmaurer = {
    home = {
      stateVersion = "25.05";
      shellAliases = {
        "cd.." = "cd ..";
        "ciao" = "sudo shutdown -h now";
      };

    };
    programs = {
      bash = {
        enable = true;
        profileExtra = ''
          # ln -sf /tmp/shared /home/fmaurer/inception
          mkdir -p /home/fmaurer/data/wp_{data,db}
          cd /home/fmaurer/inception
          startx /etc/xinitrc-fluxbox
        '';
      };
    };
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };


  # deactivate sudo pw
  security.sudo.wheelNeedsPassword = false;

  # Minimal dbus (required for Firefox and modern apps)
  services.dbus.enable = true;

  services.libinput.enable = true;

  services.openssh.enable = true;

  # fileSystems."shared" = {
  #   device = "shared";
  #   fsType = "9p";
  #   options = [
  #     "_netdev"
  #     "trans=virtio"
  #     "msize=524288"
  #   ];
  # };

  fileSystems."/home/fmaurer/inception" = {
    device = "shared";
    fsType = "9p";
    options = [
      "_netdev"
      "trans=virtio"
      "msize=524288"
    ];
  };

  # no swap
  swapDevices = [ ];

  # enable necessary hardware support??
  hardware.graphics.enable = true;

  # docker support
  virtualisation.docker.enable = true;

  # # vm-specific settings
  # virtualisation.vmVariant = {
  #   virtualisation = {
  #     memorySize = 4096;
  #     cores = 2;
  #     diskSize = 8192;  # 8GB - adjust as needed for minimal size
  #   };
  # };
  #
  # # for being able to connect to vm via ssh on port localhost:2222 from host
  # virtualisation.forwardPorts = [
  #   { from = "host"; host.port = 2222; guest.port = 22; }
  # ];

  networking = {
    hostName = "inception-vm";
    networkmanager.enable = false;  # Keep it minimal
    useDHCP = true;
    hosts = {
      "127.0.0.1" = ["fmaurer.42.fr"];
    };
  };

  # disable a bit more stuff
  documentation.enable = false;
  documentation.nixos.enable = false;
  programs.command-not-found.enable = false;

  # Minimal system settings
  system.stateVersion = "25.05";  # Adjust to your NixOS version
}
