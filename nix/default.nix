{
  lib,
  stdenv,
  buildNpmPackage,
  nodePackages,
  meson,
  pkg-config,
  ninja,
  gobject-introspection,
  gtk3,
  libpulseaudio,
  gjs,
  wrapGAppsHook,
  upower,
  gnome-bluetooth,
  gtk-layer-shell,
  glib-networking,
  networkmanager,
  libdbusmenu-gtk3,
  fetchFromGitHub,
  gvfs,
  libsoup_3,
  libnotify,
  pam,
  extraPackages ? [],
  version ? "git",
  buildTypes ? true,
}: let
  pname = "ags";

  gvc-src = fetchFromGitHub {
    owner = "GNOME";
    repo = "libgnome-volume-control";
    rev = "master";
    sha256 = "sha256-gdgTnxzH8BeYQAsvv++Yq/8wHi7ISk2LTBfU8hk12NM=";
  };
in
  stdenv.mkDerivation {
    inherit pname version;

    src = buildNpmPackage {
      name = pname;

      src = builtins.path {
        name = "ags-${version}";
        path = lib.cleanSource ../.;
      };

      dontBuild = true;

      npmDepsHash = "sha256-ucWdADdMqAdLXQYKGOXHNRNM9bhjKX4vkMcQ8q/GZ20=";

      installPhase = ''
        runHook preInstall
        mkdir $out
        cp -r * $out
        runHook postInstall
      '';
    };

    nativeBuildInputs = [
      pkg-config
      meson
      ninja
      nodePackages.typescript
      wrapGAppsHook
      gobject-introspection
    ];

    buildInputs =
      [
        gjs
        gtk3
        libpulseaudio
        upower
        gnome-bluetooth
        gtk-layer-shell
        glib-networking
        networkmanager
        libdbusmenu-gtk3
        gvfs
        libsoup_3
        libnotify
        pam
      ]
      ++ extraPackages;

    mesonFlags = [
      (lib.mesonBool "build_types" buildTypes)
    ];

    prePatch = ''
      mkdir -p ./subprojects/gvc
      cp -r ${gvc-src}/* ./subprojects/gvc
    '';

    postPatch = ''
      chmod +x post_install.sh
      patchShebangs post_install.sh
    '';

    outputs = ["out" "lib"];

    meta = {
      description = "A customizable and extensible shell";
      homepage = "https://github.com/Aylur/ags";
      changelog = "https://github.com/Aylur/ags/blob/${version}/CHANGELOG.md";
      platforms = ["x86_64-linux" "aarch64-linux"];
      license = lib.licenses.gpl3;
      mainProgram = "ags";
      maintainers = [lib.maintainers.Aylur];
    };
  }
