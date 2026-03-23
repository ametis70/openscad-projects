{
  description = "OpenSCAD Projects development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        renderScript = pkgs.writeShellScriptBin "render-stls" ''
          set -e

          BLEND_FILE="$PWD/util/renderTemplate.blend"
          CONVERT_SCRIPT="$PWD/util/stl-render-tool/convertstl.py"

          # Check if required files exist
          if [ ! -f "$BLEND_FILE" ]; then
            echo "Error: Blender template not found at $BLEND_FILE"
            exit 1
          fi

          if [ ! -f "$CONVERT_SCRIPT" ]; then
            echo "Error: Convert script not found at $CONVERT_SCRIPT"
            exit 1
          fi

          echo "Starting STL rendering..."
          echo ""

          # Hardcoded list of STL files to render with their settings
          # Format: "project_dir|filename|z_rotation|material_name"
          declare -a renders=(
            "projects/keyhole-pegboard-adapter|example_holes.stl|45|Default"
            "projects/keyhole-pegboard-adapter|example_pegs.stl|45|Default"
          )

          # Render each STL file
          for render in "''${renders[@]}"; do
            IFS='|' read -r project_dir filename z_rotation material_name <<< "$render"
            
            # Construct paths
            stl_path="$PWD/$project_dir/output/$filename"
            output_dir="$PWD/$project_dir/img/renders"
            
            if [ ! -f "$stl_path" ]; then
              echo "Warning: STL file not found: $stl_path (skipping)"
              continue
            fi
            
            # Create output directory
            mkdir -p "$output_dir"
            
            echo "Rendering: $project_dir/$filename"
            echo "  - STL: $stl_path"
            echo "  - Output: $output_dir"
            echo "  - Z rotation: $z_rotation degrees"
            echo "  - Material: $material_name"
            
            ${pkgs.blender}/bin/blender -b "$BLEND_FILE" -P "$CONVERT_SCRIPT" -- \
              "$stl_path" \
              "$output_dir" \
              --z_rotation="$z_rotation" \
              --material_name="$material_name"
            
            echo "  ✓ Done"
            echo ""
          done

          echo "All renders completed!"
        '';
      in
      {
        packages.render-stls = renderScript;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            openscad
            blender
            renderScript
          ];

          shellHook = ''
            echo "OpenSCAD Projects development environment"
            echo "Available tools:"
            echo "  - openscad: $(openscad --version 2>&1 | head -n1)"
            echo "  - blender: $(blender --version | head -n1)"
            echo "  - render-stls: Render all STL files to PNG"
          '';
        };
      }
    );
}
