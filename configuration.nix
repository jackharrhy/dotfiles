{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "thinktop";
    wireless.enable = true;

    interfaces = {
      enp0s25.useDHCP = true;
      wlp3s0.useDHCP = true;
    };

    firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
    };
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/St_Johns";

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [

    # lang
    crystal
    shards

    rustc
    cargo
    rustup

    python3

    nodejs-10_x

    # cli
    wget
    stow
    fd
    bat
    ripgrep
    jq
    lsd
    xclip
    git
    tmux
    _1password

    # dev
    docker-compose

    # tooling
    dmenu

    # audio
    spotifyd

    # apps
    firefox-devedition-bin
    slack
    discord
    spotify
    alacritty
    rxvt_unicode

    # editors
    vim
    vscode

  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  virtualisation.docker.enable = true;

  services = {
    openssh.enable = true;
    # printing.enable = true;
  };

  # sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # x11
  services.xserver = {
    enable = true;
    layout = "us";

    # touchpad
    libinput.enable = true;

    # wm
    windowManager.herbstluftwm.enable = true;
  };

  # user
  users.users.jack = {
    isNormalUser = true;
    home = "/home/jack";
    shell = "/run/current-system/sw/bin/fish";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  # NixOS release
  system.stateVersion = "19.09";
}

