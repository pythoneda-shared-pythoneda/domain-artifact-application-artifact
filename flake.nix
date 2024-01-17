# flake.nix
#
# This file packages pythoneda-shared-artifact/domain-application as a Nix flake.
#
# Copyright (C) 2023-today rydnr's pythoneda-shared-artifact-def/domain-application
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Application layer for pythoneda-shared-artifact/domain";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixos.url = "github:NixOS/nixpkgs/23.11";
    pythoneda-shared-artifact-application = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-artifact-def/application/0.0.23";
    };
    pythoneda-shared-application = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-def/application/0.0.37";
    };
    pythoneda-shared-pythoneda-artifact-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-artifact-def/domain/0.0.41";
    };
    pythoneda-shared-artifact-domain-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-artifact-def/domain-infrastructure/0.0.39";
    };
    pythoneda-shared-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      url = "github:pythoneda-shared-def/banner/0.0.41";
    };
    pythoneda-shared-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      url = "github:pythoneda-shared-def/domain/0.0.22";
    };
    pythoneda-shared-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos.follows = "nixos";
      inputs.pythoneda-shared-banner.follows = "pythoneda-shared-banner";
      inputs.pythoneda-shared-domain.follows = "pythoneda-shared-domain";
      url = "github:pythoneda-shared-def/infrastructure/0.0.19";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        org = "pythoneda-shared-pythoneda-artifact";
        repo = "domain-application";
        version = "0.0.10";
        sha256 = "1jq3dp900gb7935zl45p0as49a6khmcy13dk65j8k0g709xy7lla";
        pname = "${org}-${repo}";
        pythonpackage = "pythoneda.artifact.application";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        entrypoint = "artifact_app";
        description =
          "Application layer for pythoneda-shared-pythoneda-artifact/domain";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/${org}/${repo}";
        maintainers = with pkgs.lib.maintainers;
          [ "rydnr <github@acm-sl.org>" ];
        archRole = "B";
        space = "D";
        layer = "A";
        nixosVersion = builtins.readFile "${nixos}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixos-${nixosVersion}";
        shared = import "${pythoneda-shared-banner}/nix/shared.nix";
        pkgs = import nixos { inherit system; };
        pythoneda-shared-pythoneda-artifact-domain-application-for = { python
          , pythoneda-shared-artifact-application
          , pythoneda-shared-pythoneda-artifact-domain
          , pythoneda-shared-pythoneda-artifact-domain-infrastructure
          , pythoneda-shared-application, pythoneda-shared-banner
          , pythoneda-shared-domain }:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
            banner_file = "${package}/artifact_banner.py";
            banner_class = "ArtifactBanner";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage package pname pythonMajorMinorVersion
                pythonpackage version;
              pythonedaSharedArtifactApplication =
                pythoneda-shared-artifact-application.version;
              pythonedaSharedApplication = pythoneda-shared-application.version;
              pythonedaSharedBanner = pythoneda-shared-banner.version;
              pythonedaSharedDomain = pythoneda-shared-domain.version;
              src = pyprojectTemplateFile;
              pythonedaSharedPythonedaArtifactDomainInfrastructure =
                pythoneda-shared-pythoneda-artifact-domain-infrastructure.version;
              pythonedaSharedPythonedaArtifactDomain =
                pythoneda-shared-pythoneda-artifact-domain.version;
            };
            bannerTemplateFile =
              "${pythoneda-shared-banner}/templates/banner.py.template";
            bannerTemplate = pkgs.substituteAll {
              project_name = pname;
              file_path = banner_file;
              inherit banner_class org repo;
              tag = version;
              pescio_space = space;
              arch_role = archRole;
              hexagonal_layer = layer;
              python_version = pythonMajorMinorVersion;
              nixpkgs_release = nixpkgsRelease;
              src = bannerTemplateFile;
            };

            entrypointTemplateFile =
              "${pythoneda-shared-banner}/templates/entrypoint.sh.template";
            entrypointTemplate = pkgs.substituteAll {
              arch_role = archRole;
              hexagonal_layer = layer;
              nixpkgs_release = nixpkgsRelease;
              inherit homepage maintainers org python repo version;
              pescio_space = space;
              python_version = pythonMajorMinorVersion;
              pythoneda_shared_banner = pythoneda-shared-banner;
              pythoneda_shared_domain = pythoneda-shared-domain;
              src = entrypointTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-shared-application
              pythoneda-shared-artifact-application
              pythoneda-shared-banner
              pythoneda-shared-domain
              pythoneda-shared-pythoneda-artifact-domain
              pythoneda-shared-pythoneda-artifact-domain-infrastructure
            ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod -R +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
              cp ${bannerTemplate} $sourceRoot/${banner_file}
              cp ${entrypointTemplate} $sourceRoot/entrypoint.sh
            '';

            postPatch = ''
              substituteInPlace /build/$sourceRoot/entrypoint.sh \
                --replace "@SOURCE@" "$out/bin/${entrypoint}.sh" \
                --replace "@PYTHONPATH@" "$PYTHONPATH" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/${entrypoint}.py" \
                --replace "@BANNER@" "$out/bin/banner.sh"
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist $out/bin
              cp dist/${wheelName} $out/dist
              cp /build/$sourceRoot/entrypoint.sh $out/bin/${entrypoint}.sh
              chmod +x $out/bin/${entrypoint}.sh
              echo '#!/usr/bin/env sh' > $out/bin/banner.sh
              echo "export PYTHONPATH=$PYTHONPATH" >> $out/bin/banner.sh
              echo "${python}/bin/python $out/lib/python${pythonMajorMinorVersion}/site-packages/${banner_file} \$@" >> $out/bin/banner.sh
              chmod +x $out/bin/banner.sh
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default =
            pythoneda-shared-pythoneda-artifact-domain-application-default;
          pythoneda-shared-pythoneda-artifact-domain-application-default =
            pythoneda-shared-pythoneda-artifact-domain-application-python311;
          pythoneda-shared-pythoneda-artifact-domain-application-python38 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-application-python38;
              inherit entrypoint;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python39 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-application-python39;
              inherit entrypoint;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python310 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-application-python310;
              inherit entrypoint;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python311 =
            shared.app-for {
              package =
                self.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-application-python311;
              inherit entrypoint;
            };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default =
            pythoneda-shared-pythoneda-artifact-domain-application-default;
          pythoneda-shared-pythoneda-artifact-domain-application-default =
            pythoneda-shared-pythoneda-artifact-domain-application-python311;
          pythoneda-shared-pythoneda-artifact-domain-application-python38 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythoneda-artifact-domain-application-python38;
              python = pkgs.python38;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python39 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythoneda-artifact-domain-application-python39;
              python = pkgs.python39;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python310 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythoneda-artifact-domain-application-python310;
              python = pkgs.python310;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310;
              inherit archRole layer org pkgs repo space;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python311 =
            shared.devShell-for {
              banner = "${
                  pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38
                }/bin/banner.sh";
              extra-namespaces = "";
              nixpkgs-release = nixpkgsRelease;
              package =
                packages.pythoneda-shared-pythoneda-artifact-domain-application-python311;
              python = pkgs.python311;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311;
              inherit archRole layer org pkgs repo space;
            };
        };
        packages = rec {
          default =
            pythoneda-shared-pythoneda-artifact-domain-application-default;
          pythoneda-shared-pythoneda-artifact-domain-application-default =
            pythoneda-shared-pythoneda-artifact-domain-application-python311;
          pythoneda-shared-pythoneda-artifact-domain-application-python38 =
            pythoneda-shared-pythoneda-artifact-domain-application-for {
              python = pkgs.python38;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python38;
              pythoneda-shared-artifact-application =
                pythoneda-shared-artifact-application.packages.${system}.pythoneda-shared-artifact-application-python38;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python38;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python38;
              pythoneda-shared-pythoneda-artifact-domain =
                pythoneda-shared-pythoneda-artifact-domain.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-python38;
              pythoneda-shared-pythoneda-artifact-domain-infrastructure =
                pythoneda-shared-pythoneda-artifact-domain-infrastructure.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-infrastructure-python38;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python39 =
            pythoneda-shared-pythoneda-artifact-domain-application-for {
              python = pkgs.python39;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python39;
              pythoneda-shared-artifact-application =
                pythoneda-shared-artifact-application.packages.${system}.pythoneda-shared-artifact-application-python39;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python39;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python39;
              pythoneda-shared-pythoneda-artifact-domain =
                pythoneda-shared-pythoneda-artifact-domain.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-python39;
              pythoneda-shared-pythoneda-artifact-domain-infrastructure =
                pythoneda-shared-pythoneda-artifact-domain-infrastructure.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-infrastructure-python39;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python310 =
            pythoneda-shared-pythoneda-artifact-domain-application-for {
              python = pkgs.python310;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python310;
              pythoneda-shared-artifact-application =
                pythoneda-shared-artifact-application.packages.${system}.pythoneda-shared-artifact-application-python310;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python310;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python310;
              pythoneda-shared-pythoneda-artifact-domain-infrastructure =
                pythoneda-shared-pythoneda-artifact-domain-infrastructure.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-infrastructure-python310;
              pythoneda-shared-pythoneda-artifact-domain =
                pythoneda-shared-pythoneda-artifact-domain.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-python310;
            };
          pythoneda-shared-pythoneda-artifact-domain-application-python311 =
            pythoneda-shared-pythoneda-artifact-domain-application-for {
              python = pkgs.python311;
              pythoneda-shared-application =
                pythoneda-shared-application.packages.${system}.pythoneda-shared-application-python311;
              pythoneda-shared-artifact-application =
                pythoneda-shared-artifact-application.packages.${system}.pythoneda-shared-artifact-application-python311;
              pythoneda-shared-banner =
                pythoneda-shared-banner.packages.${system}.pythoneda-shared-banner-python311;
              pythoneda-shared-domain =
                pythoneda-shared-domain.packages.${system}.pythoneda-shared-domain-python311;
              pythoneda-shared-pythoneda-artifact-domain-infrastructure =
                pythoneda-shared-pythoneda-artifact-domain-infrastructure.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-infrastructure-python311;
              pythoneda-shared-pythoneda-artifact-domain =
                pythoneda-shared-pythoneda-artifact-domain.packages.${system}.pythoneda-shared-pythoneda-artifact-domain-python311;
            };
        };
      });
}
