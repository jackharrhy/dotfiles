{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # booting
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking
  networking.hostName = "thinktop";
  networking.wireless.enable = true;

  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # internationalisation
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # time
  time.timeZone = "America/St_Johns";

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [

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
    fish

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

  # ssh
  services.openssh.enable = true;

  # firewall
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  # printing
  # services.printing.enable = true;

  # sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # x11
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # touchpad
  services.xserver.libinput.enable = true;

  # wm
  services.xserver.windowManager.herbstluftwm.enable = true;

  # user
  users.users.jack = {
    isNormalUser = true;
    home = "/home/jack";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  # NixOS release
  system.stateVersion = "19.09";

}

