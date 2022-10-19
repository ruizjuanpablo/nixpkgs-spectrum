{ lib, stdenv, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with lib;

buildLinux (args // rec {
  version = "5.15.32";
  nxp_ref = "lf-5.15.y";

  # modDirVersion needs to be x.y.z, will automatically add .0 if needed
  modDirVersion = if (modDirVersionArg == null) then concatStringsSep "." (take 3 (splitVersion "${version}.0")) else modDirVersionArg;

  defconfig = "imx_v8_defconfig";

  autoModules = false;

  extraConfig = ''
    CRYPTO_TLS m
    TLS y
    MD_RAID0 m
    MD_RAID1 m
    MD_RAID10 m
    MD_RAID456 m
    DM_VERITY m
    LOGO y
    FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER n
    FB_EFI n
  '';

  kernelPatches = [ 
    {
      name = "Added DTS and GPU passthrough drivers for VM";
      patch = ./linux-imx8/0001-Added-DTS-and-GPU-PT-drivers-changes-for-VM.patch;
    } 
  ];

  src = fetchGit {
    url = "https://source.codeaurora.org/external/imx/linux-imx";
    ref = "refs/tags/lf-5.15.32-2.0.0";
  };
} // (args.argsOverride or { }))
