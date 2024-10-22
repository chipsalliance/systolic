# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2024 Jiuyang Liu <liu@jiuyang.me>

{ lib
, rustPlatform
, tbConfig
, dpiLibName
, sv2023 ? true
, vpi ? false
, enable-trace ? false
, timescale ? 1
}:

rustPlatform.buildRustPackage rec {
  name = "dpi-lib";
  src = ./../../${dpiLibName};
  cargoHash = "sha256-DzedUaBSNOT552x+/4RjeUcKs68HxAiejQ60BgZnUYc=";
  buildFeatures = lib.optionals sv2023 [ "sv2023" ]
    ++ lib.optionals vpi [ "vpi" ] ++ lib.optionals enable-trace [ "trace" ];

  env = { };

  passthru = {
    inherit enable-trace;
    inherit env;
    libOutName = "lib${dpiLibName}.a";
  };
}
