{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, self, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          board-rofi = pkgs.writeShellApplication {
            name = "board-rofi";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
              pkgs.gnused
              pkgs.rofi
              pkgs.mpv
              pkgs.systemd
            ];
            text = builtins.readFile ./bin/board-rofi.sh;
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ssh = pkgs.writeShellScriptBin "ssh" ''
            for arg in "$@"; do
              case "$arg" in
                *neoprism.lassul.us*)
                  exec ${pkgs.openssh}/bin/ssh -p 45621 "$@"
                  ;;
              esac
            done
            exec ${pkgs.openssh}/bin/ssh "$@"
          '';
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.git-annex
              pkgs.git
              pkgs.kubo
              ssh
            ];
          };
        }
      );
    };
}
