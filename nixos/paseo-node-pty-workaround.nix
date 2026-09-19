{paseo}:
paseo.overrideAttrs (oldAttrs: {
  postInstall =
    (oldAttrs.postInstall or "")
    + ''
      nodePtyOutput="$out/lib/paseo/packages/server/node_modules/node-pty"
      cp -a packages/server/node_modules/node-pty/prebuilds "$nodePtyOutput/"
    '';
})
