# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    # Use the GRUB 2 boot loader.
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    initrd = {
      checkJournalingFS = false;
      kernelModules = ["hv_vmbus" "hv_storvsc"]; # https://github.com/NixOS/nix/issues/9899
    };
    kernel.sysctl = {
      "vm.overcommit_memory" = "1"; # https://github.com/NixOS/nix/issues/421
      "fs.inotify.max_user_watches" = "1048576";
    };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "nixos";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    firewall.enable = false;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # CLI Tools
    curl
    keybase
    screenfetch

    # Version Control
    git

    # DevOps
    docker docker-compose
    aws
    terraform

    # Languages
    jdk11
    nodejs-12_x yarn
    python poetry

    # Nix
    direnv
    niv

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  # Enable Docker support
  virtualisation.docker.enable = true;
  environment.variables.DOCKER_BUILDKIT = "1";
  environment.variables.COMPOSE_DOCKER_CLI_BUILD = "1";

  # Enable the OpenSSH daemon
  services.sshd.enable = true;
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "no";

  services.lorri.enable = true;

  # Enable fish
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrejus = {
    isNormalUser = true;
    home = "/home/andrejus";
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    # openssh.authorizedKeys.keyFiles = [ "/home/andrejus/.ssh/authorized_keys" ];
    shell = pkgs.fish;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}