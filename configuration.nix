{ config, pkgs, lib, ... }:
{

  # Remove ZFS
  #boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "ext4" "vfat" ];

  networking.hostName = "coresense";
#  networking = {
#    interfaces."wlan0".useDHCP = true;
#    wireless = {
#      interfaces = [ "wlan0" ];
#      enable = true;
#      networks = {
#        myWifiNetworkSSID.pskRaw = "29f4be0s82e33c18149cdcfc869f84ce6a8831fb492e35d759468f6103bf8a31"; # pskRaw is the result of running wpa_passphrase 'SSID' 'PASSWORD'
#        WIFI_SSID.psk = "WIFI_PASSWORD";
#      };
#    };
#  };
  

  # Define a user account. 
  users.users.abb = {
    description = "abb";
    isNormalUser = true;
    password = "abb";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  # Packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    adoptopenjdk-jre-bin
    #openjdk11_headless
  ];

  # Enable ssh on boot
  services.openssh.enable = true;

  # Enable Avahi mDNS, you should be able to reach http://nix:19999
  # to reach netdata when booted
  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns = true; # Allows software to use Avahi to resolve.
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
