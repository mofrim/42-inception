# { config, lib, pkgs, ... }:
{ config, lib, pkgs, ... }:
# let
#   home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/refs/heads/release-25.05.tar.gz";
# in
{
  # imports =
  #   [
  #     (import "${home-manager}/nixos")
  #     ./hardware-configuration.nix
  #   ];
  virtualisation = {
    memorySize = 4096;
    cores = 2;
    diskSize = 15360;
  };

  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;
 
  users = {
    users.root.hashedPassword = "$y$j9T$kSHZPi5yj71KzIHRera.H/$vxhVbUHlmxqvLNPuntsR.gv1tUBB42f06ZngiqAGaR7";
    users.fmaurer = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFG0nJF3ZMmkgkSAG42VOUyN65w0wSEPeZ+229UiZqW1 fmaurer@42" 
      ];
      hashedPassword = "$y$j9T$kSHZPi5yj71KzIHRera.H/$vxhVbUHlmxqvLNPuntsR.gv1tUBB42f06ZngiqAGaR7";
      extraGroups = [ "wheel" "docker" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  home-manager.users.fmaurer = {
    # main source of inspiration:
    # https://lafreniere.xyz/docs/nix-home-manager-sway.html
    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod1";
        keybindings = {
          "Mod1+d" = "exec --no-startup-id wofi --show drun,run";
          "Mod1+Shift+q" = "kill";
          "Mod1+h" = "focus left";
          "Mod1+j" = "focus down";
          "Mod1+k" = "focus up";
          "Mod1+l" = "focus right";
        };
        output = {
          "*" = {
            bg = "#6495ed solid_color";
        };
        };
      };
    };
    programs = {
      wofi = {
        enable = true;
        settings = {
          allow_markup = true;
          width = 250;
        };
        # source: https://github.com/dracula/wofi/blob/master/style.css
        style = ''
          window {
          margin: 0px;
          border: 1px solid #bd93f9;
          background-color: #282a36;
          }

          #input {
          margin: 5px;
          border: none;
          color: #f8f8f2;
          background-color: #44475a;
          }

          #inner-box {
          margin: 5px;
          border: none;
          background-color: #282a36;
          }

          #outer-box {
          margin: 5px;
          border: none;
          background-color: #282a36;
          }

          #scroll {
          margin: 0px;
          border: none;
          }

          #text {
          margin: 5px;
          border: none;
          color: #f8f8f2;
          } 

          #entry.activatable #text {
          color: #282a36;
          }

          #entry > * {
          color: #f8f8f2;
          }

          #entry:selected {
          background-color: #44475a;
          }

          #entry:selected #text {
          font-weight: bold;
          }
        '';
      };
      foot = {
        enable = true;
        settings = {
          main = {
            term = "xterm-256color";
            # font = "monospace:size=8";
          };
        };
      };
      bash = {
        enable = true;
        profileExtra = ''
          exec sway
        '';
      };
    };
    home = {
      stateVersion = "25.05";
      packages = with pkgs; [
        vim
        gnumake
        brave
        alacritty
      ];
      shellAliases = {
        "cd.." = "cd ..";
      };
    };
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  services.getty = {
    autologinUser = "fmaurer";
    autologinOnce = true;
  };

  services.openssh.enable = true;
  virtualisation = {
    containers.enable = true;
    docker.enable = true;
  };

  networking.hosts = {
    "127.0.0.1" = ["fmaurer.42.fr"];
  };

  fileSystems."/home/fmaurer/inception" = {
    device = "shared";
    fsType = "9p";
    options = [
      "_netdev"
      "trans=virtio"
      "msize=524288"
    ];
  };

  # Enable X11 and Xfce

  services.dbus.enable = true;
  services.printing.enable = false;
  services.pipewire.enable = false;
 
  # deactivate sudo pw
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
