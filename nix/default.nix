let
    pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
    name = "you-dev";
    buildInputs = with pkgs; [ python38Packages.internetarchive jq curl imagemagick findutils ];
}
