{ stdenv
, fetchurl
, lib
, autoPatchelfHook, wayland, libdrm
}:

stdenv.mkDerivation rec {
  pname = "imx-gpu-viv";
  version = "6.4.3.p4.2";

  FSL_MIRROR = "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/";

  src = fetchurl {
    url = "${FSL_MIRROR}/${pname}-${version}-aarch64.bin";
    sha256 = "sha256-UpIcC1lSnxWYCE6ZHtoYYxAHVPKKd0S6lYFY3/gHSzs=";
    name = "${pname}-${version}-aarch64.bin";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ wayland libdrm ];

  dontBuild = true;
  unpackPhase = ''
    sh ${src} --auto-accept --force
  '';

  installPhase = ''
    mkdir -p $dev/include
    mkdir -p $dev/lib/pkgconfig
    mkdir -p $out/lib    
    cp -rd --no-preserve=ownership $pname-$version-aarch64/gpu-core/usr/include/* $dev/include
    cp -rd --no-preserve=ownership $pname-$version-aarch64/gpu-core/usr/lib/pkgconfig/* $dev/lib/pkgconfig
    cp -rd --no-preserve=ownership $pname-$version-aarch64/gpu-core/usr/lib/*.so* $out/lib
    cp -rd --no-preserve=ownership $pname-$version-aarch64/gpu-core/usr/lib/wayland/* $out/lib
    cp -rd --no-preserve=ownership $pname-$version-aarch64/gpu-core/usr/lib/mx8qxp/* $out/lib
    cp -rd --no-preserve=ownership $pname-$version-aarch64/gpu-tools/gmem-info/usr/bin/* $out/bin

    gl_so_path="$out/lib/libEGL.so"
    mkdir -p "$(dirname "$gl_so_path")"
    gl_icd_json="$out/share/glvnd/egl_vendor.d/10-nxp.json"
    mkdir -p "$(dirname "$gl_icd_json")"
    cat >"$gl_icd_json" <<EOF
    {
      "file_format_version" : "1.0.0",
      "ICD" : {
          "library_path" : "$gl_so_path"
      }
    }
    EOF
  '';

  outputs = [ "out" "dev" ];

  meta = with lib; {
    description = "GPU driver for i.MX";
    homepage = "http://www.nxp.com/";
    license = licenses.unfree;
    # maintainers = with maintainers;
    platforms = platforms.linux;
  };
}
