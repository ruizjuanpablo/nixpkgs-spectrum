{ lib, stdenv, fetchgit, fetchpatch, meson, ninja, pkg-config, wayland-scanner
, python3, wayland, libGL, mesa, libxkbcommon, cairo, libxcb, seatd
, libXcursor, xlibsWrapper, udev, libdrm, mtdev, libjpeg, pam, dbus, libinput, libevdev, pixman
, colord, lcms2, pipewire ? null
, pango ? null, libunwind ? null, freerdp ? null, vaapi ? null, libva ? null
, libwebp ? null, xwayland ? null, wayland-protocols, imx-gpu-viv, imx-g2d, makeWrapper
# beware of null defaults, as the parameters *are* supplied by callPackage by default
}:

with lib;
stdenv.mkDerivation rec {
  pname = "weston";
  version = "10.0.0";

  src = fetchgit {
    url = "https://source.codeaurora.org/external/imx/weston-imx.git";
    rev = "lf-5.15.32-2.0.0";
    sha256 = "sha256-V8LI29YWKZRy4dD7FtGPgohJ+E/AQHLKtcN2oMKaldQ=";
  };

  patches = [
    ./fix-g2d-renderer.patch
    ./fix-wayland-scanner-path.patch
    ./dont-use-plane-add-prop.patch
    ./fix-gbm-path.patch
  ];

  depsBuildBuild = [pkg-config];
  nativeBuildInputs = [ meson ninja pkg-config python3 wayland-scanner makeWrapper ];
  buildInputs = [
    wayland libGL mesa libxkbcommon cairo /* libxcb libXcursor xlibsWrapper udev */ libdrm
    /* mtdev libjpeg pam dbus */ libinput libevdev /* pango libunwind freerdp vaapi libva */ pixman
    /* libwebp */ wayland-protocols imx-gpu-viv imx-g2d
  #   colord lcms2 pipewire
  ];

  mesonFlags = [
    "-Dimage-jpeg=false"
    "-Dimage-webp=false"
    "-Dlauncher-logind=false"
    # "-Dlauncher-libseat=true"
    "-Drenderer-gl=true"
    "-Drenderer-g2d=true"
    "-Degl=true"
    "-Dopengl=true"
    "-Dimxgpu=true"
    "-Dbackend-drm-screencast-vaapi=false"
    "-Dbackend-drm=true"
    "-Dbackend-default=drm"
    "-Dbackend-rdp=false"
    "-Dxwayland=false"
    "-Dcolor-management-lcms=false"
    "-Dcolor-management-colord=false"
    "-Dremoting=false"
    "-Dpipewire=false"
    "-Dsimple-clients="
    "-Ddemo-clients=false"
    "-Dtest-junit-xml=false"
    "-Dsystemd=false"
    "-Dlauncher-logind=false"
    "-Dbackend-x11=false"
  ];

  # mesonFlags= [
  #   "-Dbackend-drm-screencast-vaapi=${boolToString (vaapi != null)}"
  #   "-Dbackend-rdp=${boolToString (freerdp != null)}"
  #   "-Dxwayland=${boolToString (xwayland != null)}" # Default is true!
  #   "-Dremoting=false" # TODO
  #   "-Dpipewire=${boolToString (pipewire != null)}"
  #   "-Dimage-webp=${boolToString (libwebp != null)}"
  #   "-Ddemo-clients=false"
  #   "-Dsimple-clients="
  #   "-Dtest-junit-xml=false"
  #   # TODO:
  #   #"--enable-clients"
  #   #"--disable-setuid-install" # prevent install target to chown root weston-launch, which fails
  # ] ++ optionals (xwayland != null) [
  #   "-Dxwayland-path=${xwayland.out}/bin/Xwayland"
  # ];

  postInstall = ''
    wrapProgram $out/bin/weston --prefix LD_LIBRARY_PATH : "${imx-gpu-viv}/lib"
  '';

  passthru.providedSessions = [ "weston" ];

  meta = {
    description = "A lightweight and functional Wayland compositor";
    longDescription = ''
      Weston is the reference implementation of a Wayland compositor, as well
      as a useful environment in and of itself.
      Out of the box, Weston provides a very basic desktop, or a full-featured
      environment for non-desktop uses such as automotive, embedded, in-flight,
      industrial, kiosks, set-top boxes and TVs. It also provides a library
      allowing other projects to build their own full-featured environments on
      top of Weston's core. A small suite of example or demo clients are also
      provided.
    '';
    homepage = "https://gitlab.freedesktop.org/wayland/weston";
    license = licenses.mit; # Expat version
    platforms = platforms.linux;
    maintainers = with maintainers; [ primeos ];
  };
}
