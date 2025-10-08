{ lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/refs/heads/release-25.05.tar.gz";
in
{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  environment.systemPackages = with pkgs; [
    xorg.xorgserver
    xorg.xinit
    xorg.xinput
    xorg.xauth
    xorg.setxkbmap
    xorg.xf86inputevdev
    
    fluxbox
    st-snazzy
    brave
    
    vim
  ];

  users = {
    users.root.hashedPassword = "$y$j9T$kSHZPi5yj71KzIHRera.H/$vxhVbUHlmxqvLNPuntsR.gv1tUBB42f06ZngiqAGaR7";
    users.fmaurer = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFG0nJF3ZMmkgkSAG42VOUyN65w0wSEPeZ+229UiZqW1 fmaurer@42" 
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlhRzDpd+8nwaDMnAeXjpyM/M0RhCA7LYZCEFKHWYI7 mofrim@posteo.de"
      ];

      hashedPassword = "$y$j9T$kSHZPi5yj71KzIHRera.H/$vxhVbUHlmxqvLNPuntsR.gv1tUBB42f06ZngiqAGaR7";
      extraGroups = [ "wheel" "docker" ];
    };
  };

  # autologin fmaurer on first boot
  services.getty = {
    autologinUser = "fmaurer";
    autologinOnce = true;
  };

  home-manager.users.fmaurer = {
    xsession.enable = true;
    xsession.windowManager.fluxbox = {
      enable = true;
      menu = ''
        [begin] (fmaurer's 42-Inception-Box)
        [encoding] {UTF-8}
              [exec] (st) {st}
              [exec] (brave) {brave}
              [separator]
              [exit] (Exit)
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
    home = {
      stateVersion = "25.05";
      packages = with pkgs; [
        vim
        gnumake
        brave
        foot
      ];
      shellAliases = {
        "cd.." = "cd ..";
        "ciao" = "sudo shutdown -h now";
      };

    };
    programs = {
      bash = {
        enable = true;
        profileExtra = ''
          ln -sf /tmp/shared /home/fmaurer/inception
          mkdir -p /home/fmaurer/data/wp_{data,db}
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

  # Xorg configuration for input devices
  environment.etc."X11/xorg.conf.d/40-libinput.conf".source = lib.mkForce ./X11/xorg.conf.d/40-libinput.conf;
  environment.etc."X11/xorg.conf".text = lib.mkForce ((import ./X11/xorg.conf.nix) pkgs);
  environment.etc."X11/xorg.conf.d/10-evdev.conf".source = lib.mkForce ./X11/xorg.conf.d/10-evdev.conf;
  environment.etc."X11/bla".text = ''
    pkgs.xorgserver.outPath: ${pkgs.xorg.xorgserver.outPath}
    xorg.xf86inputevdev.outPath: ${pkgs.xorg.xf86inputevdev.outPath}
    xorg.xf86-input-libinput.outPath: ${pkgs.xorg.xf86inputlibinput.outPath}
  '';

  services.openssh.enable = true;

  # # Filesystem - for VM
  # fileSystems."/" = {
  #   device = "/dev/disk/by-label/nixos";
  #   fsType = "ext4";
  # };

  fileSystems."shared" = {
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

  # docker support
  virtualisation.docker.enable = true;

  # vm-specific settings
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 2;
      diskSize = 8192;  # 8GB - adjust as needed for minimal size
    };
  };

  # for being able to connect to vm via ssh on port localhost:2222 from host
  virtualisation.forwardPorts = [
    { from = "host"; host.port = 2222; guest.port = 22; }
  ];

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
