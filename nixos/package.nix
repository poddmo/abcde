{
  lib,
  stdenv,
  cddiscid,
  wget,
  which,
  vorbis-tools,
  id3v2,
  python3Packages,
  lame,
  flac,
  opus-tools,
  speex,
  wavpack,
  monkeysAudio,
  glyr,
  imagemagick,
  mkcue,
  normalize,
  vorbisgain,
  eject,
  atomicparsley,
  libcdio-paranoia,
  perlPackages,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "abcde";
  version = "2.12.2";

  # Sources live at the repo root, one level up from this file.
  src = ../.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = with perlPackages; [
    perl
    MusicBrainz
    MusicBrainzDiscID
    IOSocketSSL
  ];

  configurePhase = ''
    runHook preConfigure

    # The Makefile hardcodes /usr/bin/install and /usr/local.
    sed -i "s|^[[:blank:]]*prefix *=.*$|prefix = $out|g ;
            s|^[[:blank:]]*INSTALL *=.*$|INSTALL = install -c|g" \
      Makefile

    # abcde hardcodes CDPARANOIA=cdparanoia before reading any config
    # (abcde:4307), so point it at cd-paranoia through a config file.
    echo 'CDPARANOIA=${lib.getExe libcdio-paranoia}' >>abcde.conf
    echo CDROMREADERSYNTAX=cdparanoia >>abcde.conf

    # Source the packaged defaults before /etc/abcde.conf, so a bare install
    # works while /etc (e.g. the NixOS module) and ~/.abcde.conf can override.
    substituteInPlace abcde \
      --replace-fail \
        "# Load system defaults" \
        "if [ -r $out/etc/abcde.conf ]; then . $out/etc/abcde.conf; fi
    # Load system defaults"

    runHook postConfigure
  '';

  installFlags = [ "sysconfdir=$(out)/etc" ];

  postFixup = ''
    for cmd in abcde cddb-tool abcde-musicbrainz-tool; do
      wrapProgram "$out/bin/$cmd" \
        --prefix PERL5LIB : "$PERL5LIB" \
        --prefix PATH ":" ${
          lib.makeBinPath [
            (placeholder "out")
            which
            libcdio-paranoia
            cddiscid
            wget
            vorbis-tools
            id3v2
            python3Packages.eyed3
            lame
            flac
            opus-tools
            speex
            wavpack
            monkeysAudio
            glyr
            imagemagick
            mkcue
            normalize
            vorbisgain
            eject
            atomicparsley
          ]
        }
    done
  '';

  meta = {
    homepage = "https://github.com/poddmo/abcde";
    description = "Command-line audio CD ripper (poddmo fork of abcde)";
    longDescription = ''
      abcde grabs tracks off a CD, encodes them to formats such as FLAC,
      Opus, MP3 or Ogg/Vorbis, and tags them, all in one go. This poddmo
      fork focuses on lossless FLAC output and capturing as much archival
      information from the read process as possible (TOC, cue sheets,
      CD-TEXT, cover art and rich metadata).
    '';
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "abcde";
    platforms = lib.platforms.linux;
  };
}
