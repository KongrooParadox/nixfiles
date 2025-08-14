{ lib, users, ... }:
{

  home.persistence = lib.listToAttrs (
    map (
      user:
      lib.nameValuePair "/persist/home/${user}" {
        allowOther = true;
        directories = [
          ".gnupg"
          ".local/share"
          ".ssh"
          ".zoom"
          "Bureau"
          "Desktop"
          "Documents"
          "Downloads"
          "Images"
          "Modèles"
          "Music"
          "Musique"
          "Pictures"
          "Templates"
          "Téléchargements"
          "Videos"
          "Vidéos"
          "VirtualBox VMs"
          "nixfiles"
          "personal"
        ];
      }
    ) users
  );
}
