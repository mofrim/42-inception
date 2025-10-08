pkgs: 
''
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
''
