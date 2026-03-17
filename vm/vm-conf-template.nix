{ lib, pkgs, ... }:
let
  home-manager = (builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/refs/heads/release-25.11.tar.gz";
  });
  inherit (lib) mkDefault mkForce;

  commonHmOpts = {
    home = {
      stateVersion = "25.11";
      shellAliases = {
        "cd.." = "cd ..";
        "ciao" = "sudo shutdown -h now";
        "la" = "ls -alh";
        "ll" = "ls -lh";
      };
    };
    programs.bash.enable = true;
    programs.vim = {
      enable = true;
      extraConfig = ''
        set nocp
        syntax on
        set clipboard=unnamed
        set noswapfile
        set nobackup
        set number
        set smartindent
        set showmatch
        set showmode
        set modeline
        set expandtab
        set shiftwidth=2
        set tabstop=2
        set wrap
        set showbreak=+++
        nnoremap <Space> <Nop>
        let mapleader=" "
        map <leader>w :w<cr>
        map <leader>q :q<cr>
        map L :tabnext<cr>
        map H :tabprevious<cr>
        map <leader>ff :tabedit 
        map <leader>td :tabdelete<cr>
        cabbr te tabedit
        map <leader>te :te
      '';
    };
  };
in
  {
  imports =
    [
      (import "${home-manager}/nixos")
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  # all the software i need
  environment.systemPackages = with pkgs; [
    st-snazzy
    xorg.xinput
    xorg.xf86inputevdev
    xorg.xauth
    xrandr
    gnumake
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

  home-manager.users.root = commonHmOpts;

  home-manager.users.fmaurer = lib.recursiveUpdate commonHmOpts  {
    xsession.enable = true;
    xsession.windowManager.fluxbox = {
      enable = true;
      menu = ''
        [begin] (fmaurer's 42-Inception-Box)
        [encoding] {UTF-8}
        [exec] (st) {st}
        [exec] (firefox) {firefox}
        [separator]
        [exec] (ciao!) {sudo shutdown -h now}
        [endencoding]
        [end]
      '';
      init = ''
        session.screen0.iconbar.usePixmap:           true
        session.screen0.iconbar.iconTextPadding:               10
        session.screen0.iconbar.iconWidth:           128
        session.screen0.iconbar.alignment:           Relative
        session.screen0.iconbar.mode:     {static groups} (workspace)
        session.screen0.slit.placement: RightBottom
        session.screen0.slit.autoHide:   false
        session.screen0.slit.acceptKdeDockapps: true
        session.screen0.slit.onhead:       0
        session.screen0.slit.layer:         Dock
        session.screen0.slit.alpha:         255
        session.screen0.slit.maxOver:     false
        session.screen0.toolbar.placement:           BottomCenter
        session.screen0.toolbar.layer:   Dock
        session.screen0.toolbar.autoHide:             false
        session.screen0.toolbar.widthPercent:     100
        session.screen0.toolbar.height: 0
        session.screen0.toolbar.onhead: 1
        session.screen0.toolbar.visible:               true
        session.screen0.toolbar.tools:   prevworkspace, workspacename, nextworkspace, iconbar, systemtray, clock
        session.screen0.toolbar.maxOver:               false
        session.screen0.toolbar.alpha:   255
        session.screen0.menu.alpha:         255
        session.screen0.clientMenu.usePixmap:     true
        session.screen0.tabs.usePixmap: true
        session.screen0.tabs.maxOver:     false
        session.screen0.tabs.intitlebar:               true
        session.screen0.titlebar.left:   Stick 
        session.screen0.titlebar.right: Minimize Maximize Close 
        session.screen0.tab.placement:   TopLeft
        session.screen0.tab.width:           64
        session.screen0.window.focus.alpha:         255
        session.screen0.window.unfocus.alpha:     255
        session.screen0.menuDelay:           200
        session.screen0.noFocusWhileTypingDelay:               0
        session.screen0.defaultDeco:       NORMAL
        session.screen0.fullMaximization:             false
        session.screen0.workspacewarping:             true
        session.screen0.focusSameHead:   false
        session.screen0.workspaceNames: Workspace 1,Workspace 2,Workspace 3,Workspace 4,
        session.screen0.maxIgnoreIncrement:         true
        session.screen0.showwindowposition:         false
        session.screen0.rowPlacementDirection:   LeftToRight
        session.screen0.workspaces:         4
        session.screen0.focusModel:         ClickFocus
        session.screen0.strftimeFormat: %k:%M
        session.screen0.tooltipDelay:     500
        session.screen0.edgeSnapThreshold:           10
        session.screen0.maxDisableMove: false
        session.screen0.autoRaise:           true
        session.screen0.tabFocusModel:   ClickToTabFocus
        session.screen0.colPlacementDirection:   TopToBottom
        session.screen0.opaqueMove:         true
        session.screen0.allowRemoteActions:         false
        session.screen0.windowMenu:         /home/fmaurer/.fluxbox/windowmenu
        session.screen0.maxDisableResize:             false
        session.screen0.clickRaises:       true
        session.screen0.focusNewWindows:               true
        session.screen0.windowPlacement:               RowMinOverlapPlacement
        session.autoRaiseDelay: 250
        session.tabsAttachArea: Window
        session.forcePseudoTransparency:               false
        session.styleOverlay:     /home/fmaurer/.fluxbox/overlay
        session.menuFile:             ~/.fluxbox/menu
        session.colorsPerChannel:             4
        session.keyFile:               ~/.fluxbox/keys
        session.menuSearch:         itemstart
        session.styleFile:           ${pkgs.fluxbox.outPath}/share/fluxbox/styles/Meta
        session.doubleClickInterval:       250
        session.configVersion:   13
        session.cacheLife:           5
        session.slitlistFile:     /home/fmaurer/.fluxbox/slitlist
        session.tabPadding:         0
        session.cacheMax:             200
        session.appsFile:             /home/fmaurer/.fluxbox/apps
        session.ignoreBorder:     false
      '';
    };
    home.keyboard.options = [
      "caps:swapescape"
    ];
    programs = {
      bash = {
        enable = true;
        # FIXME: startx should not be started on ssh login!
        profileExtra = ''
          # ln -sf /tmp/shared /home/fmaurer/inception
          mkdir -p /home/fmaurer/data/wp_{data,db}
          cd /home/fmaurer/inception
          if [ -z "$(pidof xinit)" ]; then
          touch /home/fmaurer/.Xauthority
          startx /etc/xinitrc-fluxbox
          fi
        '';
        bashrcExtra = ''
          echo "Welcome to the Inception VM :)"
          echo
          echo "* run 'ciao' to shutdown vm"
          echo "* have fun!"
          if [ ! -e ~/.notfirstrun ]; then
          touch ~/.notfirstrun
          echo "* the inception show starts in"
          echo -n "  -> "
          for ((i=3; i>=0; i--)); do echo -n "$i " && sleep 1; done
          echo "\o/"
          make
          fi
        '';
      };
      firefox = {
        enable = true;
        profiles.default = {
          settings = {
            "browser.startup.homepage" = "https://fmaurer.42.fr";
            "browser.toolbars.bookmarks.visibility" = "always";
            "browser.rights.3.shown" = true;
            "app.normandy.first_run" = false;
            "browser.newtabpage.pinned" = [{
              title = "fmaurer42";
              url = "https://fmaurer.42.fr";
            }];
          };
          bookmarks = {
            force = true;
            settings = [
              {
                name = "Toolbar";
                toolbar = true;
                bookmarks = [
                  {
                    name = "fmaurer.42.fr";
                    tags = [ "42" ];
                    url = "https://fmaurer.42.fr";
                  }
                  {
                    name = "wp-admin";
                    tags = [ "42" ];
                    url = "https://fmaurer.42.fr/wp-admin";
                  }
                ];
              }
            ];
          };
        };
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


  security.pki.certificates = [
    ''
      CERT_GOES_HERE
    ''
  ];

  # deactivate sudo pw
  security.sudo.wheelNeedsPassword = false;

  # Minimal dbus (required for Firefox and modern apps)
  services = {
    dbus.enable = true;
    libinput.enable = true;
    openssh.enable = true;
    xserver.enable = true;
    xserver.resolutions = [
      {
        x = 1920;
        y = 1080;
      }
    ];
    xserver.displayManager.startx = {
      enable = true;
      generateScript = true;
    };
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

  # no swap
  swapDevices = [ ];

  environment.etc."xinitrc-fluxbox".text = ''
    #!/bin/sh
    exec st &
    exec fluxbox
  '';

  # enable necessary hardware support??
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = lib.mkForce false;

  # docker support & hack to have my volumes where subject wants them
  # all possible dockerd options: https://docs.docker.com/reference/cli/dockerd
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      data-root = "/home/fmaurer/data";
    };
  };

  networking = {
    firewall.enable = false;
    hostName = "inception-vm";
    networkmanager.enable = false;  # Keep it minimal
    useDHCP = true;
    hosts = {
      "127.0.0.1" = ["fmaurer.42.fr"];
    };
  };

  documentation = {
    enable = mkForce false;
    doc.enable = mkForce false;
    info.enable = mkForce false;
    man.enable = mkForce false;
    nixos.enable = mkForce false;
  };

  environment = {
    # Perl is a default package.
    defaultPackages = mkForce [ ];
    stub-ld.enable = mkForce false;
  };

  programs = {
    command-not-found.enable = mkForce false;
    fish.generateCompletions = mkForce false;
  };

  services = {
    logrotate.enable = mkForce false;
    udisks2.enable = mkForce false;
    speechd.enable = mkForce false;
    pipewire.enable = mkForce false;
  };

  xdg = {
    autostart.enable = mkForce false;
    mime.enable = mkForce false;
    sounds.enable = mkForce false;
  };

  # Minimal system settings
  system.stateVersion = "25.11";  # Adjust to your NixOS version
}
