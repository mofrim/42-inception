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
    xorg.xorgserver
    xorg.xinit
    xorg.xinput
    # xorg.xauth
    xorg.setxkbmap
    xorg.xf86inputevdev
    fluxbox
    
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
      shellAliases = {
        "cd.." = "cd ..";
        "ciao" = "sudo shutdown -h now";
      };

    };
    programs = {
      bash = {
        enable = true;
        # FIXME: startx should not be started on ssh login!
        profileExtra = ''
          # ln -sf /tmp/shared /home/fmaurer/inception
          mkdir -p /home/fmaurer/data/wp_{data,db}
          cd /home/fmaurer/inception
          if [ -z "$(pidof xinit)" ]; then
            startx /etc/xinitrc-fluxbox
          fi
        '';
        bashrcExtra = ''
          echo "- run 'make' to start the inception circus"
          echo "- run 'ciao' to shutdown vm"
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

  security.pki.certificates = [
    ''
      CERT_GOES_HERE
    ''
  ];

  # deactivate sudo pw
  security.sudo.wheelNeedsPassword = false;

  # Minimal dbus (required for Firefox and modern apps)
  services.dbus.enable = true;

  services.libinput.enable = true;

  # Xorg configuration for input devices
  # environment.etc."X11/xorg.conf.d/40-libinput.conf".source = lib.mkForce ./X11/xorg.conf.d/40-libinput.conf;
  environment.etc."X11/xorg.conf.d/40-libinput.conf".text = lib.mkForce ''
    Section "InputClass"
    Identifier "libinput pointer catchall"
    MatchIsPointer "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    EndSection

    Section "InputClass"
    Identifier "libinput keyboard catchall"
    MatchIsKeyboard "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    EndSection

  '';

  environment.etc."X11/xorg.conf".text = lib.mkForce ''
        Section "Files"

        # FontPath "/nix/store/yz1mk2skrz3h01dr3px4pbgxzvskyh5n-font-cursor-misc-1.0.4/lib/X11/fonts/misc"
        FontPath "${pkgs.xorg.fontcursormisc.outPath}/lib/X11/fonts/misc"

        # FontPath "/nix/store/yrb3bh519rj7kis83x1bd38apgf9jdg4-font-misc-misc-1.1.3/lib/X11/fonts/misc"
        FontPath "${pkgs.xorg.fontmiscmisc.outPath}/lib/X11/fonts/misc"

        # FontPath "/nix/store/8lwwcwnf8cgqc4bk1l2r8z1mfvpbbggc-unifont-16.0.03/share/fonts"
        FontPath "${pkgs.unifont.outPath}/share/fonts"

        # FontPath "/nix/store/v2i0vz32xwafrf60vw66zl98fc699iyg-font-adobe-100dpi-1.0.4/lib/X11/fonts/100dpi"
        FontPath "${pkgs.xorg.fontadobe100dpi.outPath}/lib/X11/fonts/100dpi"

        # FontPath "/nix/store/qav6xpa83664kijqrma0xxjm25wr7whm-font-adobe-75dpi-1.0.4/lib/X11/fonts/75dpi"
        FontPath "${pkgs.xorg.fontadobe75dpi.outPath}/lib/X11/fonts/75dpi"

        ModulePath "${pkgs.xorg.xorgserver.outPath}/lib/xorg/modules"
        ModulePath "${pkgs.xorg.xf86inputevdev.outPath}/lib/xorg/modules"
        ModulePath "${pkgs.xorg.xf86inputlibinput.outPath}/lib/xorg/modules"

        EndSection

        Section "ServerFlags"
        Option "AllowMouseOpenFail" "on"
        Option "DontZap" "on"

        EndSection

        Section "Module"

        EndSection

        Section "Monitor"
        Identifier "Monitor[0]"
        # Set a higher refresh rate so that resolutions > 800x600 work.
        HorizSync 30-140
        VertRefresh 50-160

        EndSection

        # Additional "InputClass" sections
        Section "InputClass"
        Identifier "libinput mouse configuration"
        MatchDriver "libinput"
        MatchIsPointer "on"

        Option "AccelProfile" "adaptive"
        Option "LeftHanded" "off"
        Option "MiddleEmulation" "on"
        Option "NaturalScrolling" "off"

        Option "ScrollMethod" "twofinger"
        Option "HorizontalScrolling" "on"
        Option "SendEventsMode" "enabled"
        Option "Tapping" "on"

        Option "TappingDragLock" "on"
        Option "DisableWhileTyping" "off"

        EndSection

        Section "InputClass"
        Identifier "libinput touchpad configuration"
        MatchDriver "libinput"
        MatchIsTouchpad "on"

        Option "AccelProfile" "adaptive"
        Option "LeftHanded" "off"
        Option "MiddleEmulation" "on"
        Option "NaturalScrolling" "off"

        Option "ScrollMethod" "twofinger"
        Option "HorizontalScrolling" "on"
        Option "SendEventsMode" "enabled"
        Option "Tapping" "on"

        Option "TappingDragLock" "on"
        Option "DisableWhileTyping" "off"

        EndSection

        Section "ServerLayout"
        Identifier "Layout[all]"

        # Reference the Screen sections for each driver.  This will
        # cause the X server to try each in turn.
        Screen "Screen-modesetting[0]"

        EndSection

        # For each supported driver, add a "Device" and "Screen"
        # section.

        Section "Device"
        Identifier "Device-modesetting[0]"
        Driver "modesetting"

        EndSection

        Section "Screen"
        Identifier "Screen-modesetting[0]"
        Device "Device-modesetting[0]"
        Monitor "Monitor[0]"

        SubSection "Display"
        Depth 8
        Modes "1024x768"

        EndSubSection
        SubSection "Display"
        Depth 16
        Modes "1024x768"

        EndSubSection
        SubSection "Display"
        Depth 24
        Modes "1024x768"

        EndSubSection
        EndSection
      '';

  environment.etc."X11/xorg.conf.d/10-evdev.conf".text = lib.mkForce ''
    Section "InputClass"
    Identifier "evdev pointer catchall"
    MatchIsPointer "on"
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    EndSection

    Section "InputClass"
    Identifier "evdev keyboard catchall"
    MatchIsKeyboard "on"
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    EndSection

    Section "InputClass"
    Identifier "evdev touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    EndSection

    Section "InputClass"
    Identifier "evdev tablet catchall"
    MatchIsTablet "on"
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    EndSection

    Section "InputClass"
    Identifier "evdev touchscreen catchall"
    MatchIsTouchscreen "on"
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    EndSection
  '';

  environment.etc."X11/bla".text = ''
    pkgs.xorgserver.outPath: ${pkgs.xorg.xorgserver.outPath}
    xorg.xf86inputevdev.outPath: ${pkgs.xorg.xf86inputevdev.outPath}
    xorg.xf86-input-libinput.outPath: ${pkgs.xorg.xf86inputlibinput.outPath}
  '';

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

  environment.etc."xinitrc-fluxbox".text = ''
    #!/bin/sh
    exec st &
    exec fluxbox
  '';

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
