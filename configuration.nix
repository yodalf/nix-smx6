{ config, pkgs, lib, ... }:
{

  # Remove ZFS
  #boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "ext4" "vfat" ];

  networking.hostName = "coresense";

  networking.useDHCP = false;
  networking.interfaces.end0.useDHCP = true; 

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
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1oPimkUsL+ra+arflNE4Tbppo4wtIJjX+FOvsg3hNblSdlUJ7wpNSCOR/inoJU9p4lOie/9vtOBsf9kss3NndcMFy3s2Ag1sdbmT7iORPyyn506vqxWbzuvDMnX2DRmUONq2FmJiTHP7JCOzX9q4kDvRfu1LS4TpCQjBaLX71R1m7tpFyDoJ81xLSz9kjcudbtoaawSybXiEFn7IUJKh4zsrp8S5ygA1StP+2EnXKyDP5btJu463EG3jFvSIrdfIWyAb6bURg8MV/dZ7Y5LzkLQthROxShTpHqk+x/KL+Vjf+aIQ4XL4cg/pgTwmwWe6nJw41AiuffhRXb0E9qekDujd4HovUR4ZceL6UJUgz4eVwyhBM/jMIwWYVObw0eM1G44OiDWndnBd6431HuyKUYVGmbGIZQIVK7+EeAHpNx46aoudKH7Qvv/52b0BmxEfsSAxb+Cmr3wUBlXuHouXMQgyT5kqaLPd2Ys7GEQfISDnaTIO8obx/Ec4iLoI5kQc= abb@ABBuntu" ];
  };

  # Packages installed in system profile.
  environment.systemPackages = with pkgs; [
    #vim
    #wget
    #git
    #adoptopenjdk-jre-bin
    btop
    #hdparm
    #gcc
  ];

  # Enable ssh on boot
  services.openssh = {
        enable = true;
  };


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
 




##########################################################3


###########################################################




 
    system.stateVersion = "22.11";

}
