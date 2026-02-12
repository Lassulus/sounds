{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
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
