{ pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/firmware.nix
    ./modules/nix-unstable.nix
    ./modules/flakes.nix
    ./modules/save-space.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "cam-monitor";

  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.firewall.logRefusedConnections = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    chromium
    curl
    git
    htop
    vim
  ];

  users.users.cam = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "tty"
    ];
    hashedPassword = "$6$kawWse.yi13oG6Y5$WL/evbWMI2A/hoUYqBNiM6zW1JcQKunHI9CebS71u3D9CxlNpUcQiD3q9Obkj4leuD.O6L1KY4LwHlIsMdec..";
  };
  security.sudo.wheelNeedsPassword = false;

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };
    logind.extraConfig = ''
      HandlePowerKey=reboot
      HandlePowerKeyLongPress=poweroff
    '';
    logind.powerKey = "reboot";
    logind.powerKeyLongPress = "poweroff";
    getty.autologinUser = "cam";
    unclutter.enable = true;
    xscreensaver.enable = false;
  };

  powerManagement.enable = false;

  services.xserver.resolutions = [
    {
      x = 1920;
      y = 1440;
    }
    {
      x = 1920;
      y = 1080;
    }
  ];

  services.xserver.excludePackages = with pkgs; [
    lxqt.lxqt-notificationd
    lxqt.lxqt-powermanagement
    xscreensaver
  ];

  environment.lxqt.excludePackages = with pkgs; [
    lxqt.lxqt-notificationd
    lxqt.lxqt-powermanagement
    xscreensaver
  ];

  services.xserver = {
    enable = true;
    displayManager = {
      lightdm.enable = true;
    };
    desktopManager.lxqt.enable = true;
  };
  services.displayManager = {
    defaultSession = "lxqt";
    autoLogin = {
      enable = true;
      user = "cam";
    };
  };

  systemd.timers."cam-monitor"  = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        Persistent = true;
        Unit = "cam-monitor.service";
        OnCalendar = "*-*-* 6:00:00 America/Los_Angeles";
      };
  };

  systemd.services.cam-monitor = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [
      bash
      chromium
      coreutils
      gawk
      iproute2
    ];
    serviceConfig = {
      User = "cam";
      Environment = [ "DISPLAY=:0" ];
      Restart = "always";
      RestartSec = 5;
      ExecStart = "${pkgs.bash}/bin/bash /etc/monitor.sh";
    };
  };

  environment.etc = {
    "monitor.sh" = {
      source = ./monitor.sh;
      mode = "0755";
      user = "cam";
    };
  };

  system.stateVersion = "25.05";
}
