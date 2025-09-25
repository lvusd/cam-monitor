{
  modulesPath,
  lib,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  hardware.enableAllFirmware = true;

  boot.loader.systemd-boot.enable = true;

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  networking.useDHCP = lib.mkDefault true;
}
