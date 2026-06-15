{
  pkgs,
  lib,
  pythonPackages,
  enableGui ? false,
}:
pythonPackages.buildPythonPackage rec {
  pname = "tidaler";
  version = "0.1.7";
  format = "pyproject";

  src = pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-UM9F07EXdN1G0+iFCX+mjgK0quOkJ93mE88YNj4TjII=";
  };

  build-system = with pythonPackages; [
    poetry-core
  ];

  dependencies = with pythonPackages;
    [
      requests
      mutagen
      dataclasses-json
      pathvalidate
      m3u8
      coloredlogs
      rich
      toml
      typer
      tidalapi
      python-ffmpeg
      pycryptodome
      ansi2html
    ]
    ++ (lib.optionals enableGui [pyside6 pyqtdarktheme]);

  postFixup = ''
    wrapProgram $out/bin/tidaler \
      --prefix PATH : ${lib.makeBinPath [pkgs.ffmpeg]}

    if [ -f "$out/bin/tidaler-gui" ]; then
      wrapProgram $out/bin/tidaler-gui \
        --prefix PATH : ${lib.makeBinPath [pkgs.ffmpeg]}
    fi
  '';

  pyprojet = true;
  doCheck = false;
  # because versions of "typer" and "requests" provided by nixpkgs are higher,
  # than specified in pyproject, it won't build, skiping check doesn't cause any issue in this case
  # https://discourse.nixos.org/t/packaging-python-for-nixpkgs-w-dependency-from-github/40415
  dontCheckRuntimeDeps = true;

  meta = with lib; {
    description = "TIDAL Downloader (fork of tidal-dl-ng)";
    homepage = "https://github.com/maya-doshi/tidaler";
    license = licenses.agpl3Only;
  };
}
