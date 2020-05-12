argsOuter@{...}:
let
  # specifying args defaults in this slightly non-standard way to allow us to include the default values in `args`
  args = rec {
    pkgs = import <nixpkgs> {};
    localOverridesPath = ./local.nix;
  } // argsOuter;
in (with args; {
  digitalMarketplaceFunctionalTestsEnv = (
    (pkgs.bundlerEnv {
      name = "datagovuk-publish-bundler-env";

      ruby = pkgs.ruby;
      gemfile = ./Gemfile;
      lockfile = ./Gemfile.lock;
      gemset = ./gemset.nix;
    }).env.overrideAttrs (oldAttrs: oldAttrs // rec {
      name = "datagovuk-publish-env";
      shortName = "dgu-pub";
      buildInputs = [
        pkgs.bundix
        pkgs.libxml2
        pkgs.nodejs
      ];

      # if we don't have this, we get unicode troubles in a --pure nix-shell
      LANG="en_GB.UTF-8";

      shellHook = ''
        export PS1="\[\e[0;36m\](nix-shell\[\e[0m\]:\[\e[0;36m\]${shortName})\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0m\]\[\e[0;36m\]\w\[\e[0m\]\$ "
      '';
    })
  ).overrideAttrs (if builtins.pathExists localOverridesPath then (import localOverridesPath args) else (x: x));
})
