{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.latex;
  tex = pkgs.texliveBasic.withPackages (
    ps: with ps; [
      accsupp
      adjustbox
      biblatex
      changepage
      cmap
      dashrule
      datetime2
      enumitem
      epstopdf-pkg
      etoolbox
      everyshi
      extsizes
      fontawesome5
      fontaxes
      fontspec
      footmisc
      geometry
      graphics
      hyperref
      ifmtarg
      iftex
      infwarerr
      latex-bin
      latexmk
      lato
      ltxcmds
      luatex85
      luatexbase
      multirow
      paracol
      pdftexcmds
      pdfx
      pgf
      ragged2e
      roboto
      scheme-minimal
      simpleicons
      tcolorbox
      tikzfill
      xcolor
      xmpincl
    ]
  );
in
{
  options.kp.latex.enable = lib.mkEnableOption "LaTeX specific tools";

  config = lib.mkIf cfg.enable {
    home.packages = [
      tex
    ];
    xdg.configFile."latexmk".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles/dotfiles/latexmk";
  };
}
