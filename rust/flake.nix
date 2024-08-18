{
  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = {
    self,
    fenix,
    flake-utils,
    naersk,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      name = "replace-me";
      pkgs = nixpkgs.legacyPackages.${system};

      toolchain = with fenix.packages.${system};
        combine [
          stable.cargo
          stable.rustc
          stable.rustfmt
          stable.rust-std
          stable.rust-src
          stable.rust-analyzer
          stable.clippy
          # targets.wasm32-unknown-unknown.stable.rust-std
        ];

      nativeBuildInputs = with pkgs; [
        toolchain
        pkg-config
      ];

      buildInputs = with pkgs; [
        mold
        # fontconfig
        # glibc
        # alsa-lib
        # dbus
        # libudev-zero
        # udev
        # vulkan-tools
        # vulkan-headers
        # vulkan-loader
        # vulkan-validation-layers
        # libxkbcommon
        # wayland
        # xorg.libX11
        # xorg.libXrandr
        # xorg.libXcursor
        # xorg.libXi
        clang
      ];
      shellHook = ''
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${nixpkgs.lib.makeLibraryPath buildInputs}"
      '';

      naersk' = pkgs.callPackage naersk {
        cargo = toolchain;
        rustc = toolchain;
      };
    in {
      defaultPackage = naersk'.buildPackage {
        name = name;
        src = ./.;
        inherit nativeBuildInputs buildInputs shellHook;
      };

      devShell = pkgs.mkShell {
        name = name;
        inherit nativeBuildInputs buildInputs shellHook;
        packages = with pkgs; [
          # wasm-pack
          # nodejs_22
        ];

        RUSTC_LINKER = "${pkgs.llvmPackages.clangUseLLVM}/bin/clang";
        RUSTFLAGS = "-Clink-arg=-fuse-ld=mold";
        # CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "mold";
      };
    });
}
