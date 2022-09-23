{ stdenv
, fetchurl
, lib, autoPatchelfHook, libdrm, imx-gpu-viv
}:

stdenv.mkDerivation rec {
  pname = "imx-dpu-g2d";
  version = "2.1.0";

  FSL_MIRROR = "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/";

  src = fetchurl {
    url = "${FSL_MIRROR}/${pname}-${version}.bin";
    sha256 = "sha256-ZazHNF3K85U21g7kUWrXMcQDeQ7QXWGoGGATklVKZiA=!";
    name = "${pname}-${version}.bin";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ libdrm imx-gpu-viv ];

  dontBuild = true;
  unpackPhase = ''
    sh ${src} --auto-accept --force
  '';

  installPhase = ''
    mkdir -p $dev/include
    mkdir -p $out/lib
    cp -rd --no-preserve=ownership $pname-$version/g2d/usr/include/* $dev/include
    cp -rd --no-preserve=ownership $pname-$version/g2d/usr/lib/* $out/lib
  '';

  outputs = [ "out" "dev" ];
  
  meta = with lib; {
    description = "GPU G2D library and apps for i.MX with 2D GPU and DPU";
    homepage = "http://www.nxp.com/";
    license = licenses.unfree;
    # maintainers = with maintainers;
    platforms = platforms.linux;
  };
}
