# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  chisel = {
    pname = "chisel";
    version = "fddf41af5a96cf9e2ace67ce84d990df808f5872";
    src = fetchFromGitHub {
      owner = "chipsalliance";
      repo = "chisel";
      rev = "fddf41af5a96cf9e2ace67ce84d990df808f5872";
      fetchSubmodules = false;
      sha256 = "sha256-ZOQqWSx7KbxVGaPcY/zhRte7Vgs4+IRexJEpC7n9ffc=";
    };
    date = "2024-10-09";
  };
}