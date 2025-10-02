{ config, lib, pkgs, home-manager, modulesPath, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/refs/heads/release-25.05.tar.gz";
in
{
  imports =
    [
      (import "${modulesPath}/virtualisation/qemu-vm.nix")
      (import "${home-manager}/nixos")
    ];
  virtualisation = {
    memorySize = 2048;
    cores = 2;
    diskSize = 15360;
  };

  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;
 
  users = {
    users.root.hashedPasswordFile = import ./hashed_pw;
    users.fmaurer = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: change to 42 key
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDlhRzDpd+8nwaDMnAeXjpyM/M0RhCA7LYZCEFKHWYI7 mofrim@posteo.de" 
      ];
      hashedPasswordFile = import ./hashed_pw;
      extraGroups = [ "wheel" "docker" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  home-manager.users.fmaurer = {
    xsession.enable = true;
    xsession.windowManager.fluxbox = {
      enable = true;
      menu = ''
        [begin] (fmaurer's 42-Inception-Box)
        [encoding] {UTF-8}
              [exec] (alacritty) {alacritty}
              [exec] (firefox) {firefox}
        #[submenu] (Fluxbox menu)
        #      [config] (Configure)
        #[submenu] (System Styles) {Choose a style...}
        #      [stylesdir] (/nix/store/44f61fdnp4i2am6xrkjr4id28546sp8w-fluxbox-1.3.7/share/fluxbox/styles)
        #[end]
        #[submenu] (User Styles) {Choose a style...}
        #      [stylesdir] (~/.fluxbox/styles)
        #[end]
        #      [workspaces] (Workspace List)
        #      [commanddialog] (Fluxbox Command)
        #      [reconfig] (Reload config)
        #      [restart] (Restart)
        #      [exec] (About) {(fluxbox -v; fluxbox -info | sed 1d) | xmessage -file - -center}
              [separator]
              [exit] (Exit)
        #[end]
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
        gnumake
        firefox
        alacritty
      ];
      shellAliases = {
        "cd.." = "cd ..";
      };
    };
  };

  services.openssh.enable = true;
  virtualisation = {
    containers.enable = true;
    docker.enable = true;
  };

  networking.hosts = {
    "127.0.0.1" = ["fmaurer.42.fr"];
  };

  # Enable X11 and Xfce
  services.xserver.enable = true;
  services.xserver.windowManager.fluxbox.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "fmaurer";

  # Enable DBus and polkit for desktop functionality
  services.dbus.enable = true;
  services.printing.enable = false;
 
  # deactivate sudo pw
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
