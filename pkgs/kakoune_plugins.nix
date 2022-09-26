{ lib, kakouneUtils, fetchFromGitHub }:

let
  inherit (kakouneUtils) buildKakounePluginFrom2Nix;
in
{
  kak-surround = buildKakounePluginFrom2Nix {
    pname = "kak-surround";
    version = "2018-09-17";
    src = fetchFromGitHub {
      owner = "h-youhei";
      repo = "kakoune-surround";
      rev = "efe74c6f434d1e30eff70d4b0d737f55bf6c5022";
      sha256 = "sha256-0PicMTkYRnhtrFAMWVgynE4HfoL9/EHZIu4rTSE+zSU=";
    };
    meta.homepage = "https://github.com/h-youhei/kakoune-surround";
  };

  kak-sudo-write = buildKakounePluginFrom2Nix {
    pname = "kak-sudo-write";
    version = "2021-08-16";
    src = fetchFromGitHub {
      owner = "occivink";
      repo = "kakoune-sudo-write";
      rev = "ec0d6d26ceaadd93d6824630ba587b31e442214d";
      sha256 = "sha256-O+yw8upyYnQThDoWKnFbjrjthPTCm6EaBUoJNqpUPLA=";
    };
    meta.homepage = "https://github.com/occivink/kakoune-sudo-write";
  };

  kak-auto-pairs = buildKakounePluginFrom2Nix {
    pname = "kak-auto-pairs";
    version = "2021-10-27";
    src = fetchFromGitHub {
      owner = "alexherbo2";
      repo = "auto-pairs.kak";
      rev = "596872fb1bd6cf804ee984e005ec2e05ec6872c7";
      sha256 = "sha256-5M0Omi+rSnXhm3WtU9tkBhhIcRCWaGTMOdbne7Z9Yvs=";
    };
    meta.homepage = "https://github.com/alexherbo2/auto-pairs.kak";
  };

  kak-find = buildKakounePluginFrom2Nix {
    pname = "kak-find";
    version = "2021-11-15";
    src = fetchFromGitHub {
      owner = "occivink";
      repo = "kakoune-find";
      rev = "b424ad4edb62cb0f5ee15b26c6bdfca7797377fa";
      sha256 = "sha256-tSDVIqqEsQnq8QG9/llvSgdxtR42WAA98Hv2NY5qN1g=";
    };
    meta.homepage = "https://github.com/occivink/kakoune-find";
  };
}
