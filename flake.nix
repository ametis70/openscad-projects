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

          # Parse command line arguments
          PROJECT_FILTER=""
          if [ $# -gt 0 ]; then
            PROJECT_FILTER="$1"
          fi

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
          if [ -n "$PROJECT_FILTER" ]; then
            echo "Filtering for project: $PROJECT_FILTER"
          fi
          echo ""

          # Hardcoded list of STL files to render with their settings
          # Format: "project_dir|filename|z_rotation|material_name"
          declare -a renders=(
            "projects/keyhole-pegboard-adapter|example_holes.stl|135|Default"
            "projects/keyhole-pegboard-adapter|example_pegs.stl|45|Default"
            "projects/mate-base|mate-base.stl|0|Default"
            "projects/pcie-riser-bracket-tt-core-p3|default.stl|45|Default"
            "projects/pcie-riser-bracket-tt-core-p3|cooler_master_pcie4.stl|45|Default"
            "projects/under-desk-holder|benq.stl|45|Default"
            "projects/under-desk-holder|nexode.stl|135|Default"
            "projects/keyhole-pegboard-spool-holder|main.stl|45|Default"
          )

          # Render each STL file
          rendered_count=0
          for render in "''${renders[@]}"; do
            IFS='|' read -r project_dir filename z_rotation material_name <<< "$render"
            
            # Filter by project if specified
            if [ -n "$PROJECT_FILTER" ]; then
              project_name=$(basename "$project_dir")
              if [ "$project_name" != "$PROJECT_FILTER" ]; then
                continue
              fi
            fi
            
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
            rendered_count=$((rendered_count + 1))
          done

          if [ $rendered_count -eq 0 ]; then
            if [ -n "$PROJECT_FILTER" ]; then
              echo "No renders found for project: $PROJECT_FILTER"
            else
              echo "No renders completed!"
            fi
            exit 1
          else
            echo "All renders completed! ($rendered_count file(s))"
          fi
        '';

        stripExifScript = pkgs.writeShellScriptBin "strip-exif" ''
          set -e

          # Find all JPG/JPEG image files in project directories (excluding lib)
          echo "Searching for JPG/JPEG files with EXIF data in project directories..."
          echo ""

          image_count=0
          stripped_count=0

          # Find all jpg and jpeg files in projects subdirectories, excluding lib
          while IFS= read -r -d "" file; do
            image_count=$((image_count + 1))
            
            echo "Processing: $file"
            
            # Strip all EXIF data
            ${pkgs.exiftool}/bin/exiftool -all= -overwrite_original "$file"
            
            if [ $? -eq 0 ]; then
              stripped_count=$((stripped_count + 1))
              echo "  ✓ EXIF data removed"
            else
              echo "  ✗ Failed to remove EXIF data"
            fi
            echo ""
          done < <(find projects -mindepth 1 -maxdepth 1 -type d ! -name "lib" -exec find {} -type f \( -iname "*.jpg" -o -iname "*.jpeg" \) -print0 \;)

          if [ $image_count -eq 0 ]; then
            echo "No JPG/JPEG files found in project directories"
          else
            echo "Processed $stripped_count of $image_count image(s)"
          fi
        '';
      in
      {
        packages.render-stls = renderScript;
        packages.strip-exif = stripExifScript;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            openscad
            blender
            exiftool
            renderScript
            stripExifScript
          ];

          shellHook = ''
            echo "OpenSCAD Projects development environment"
            echo "Available tools:"
            echo "  - openscad: $(openscad --version 2>&1 | head -n1)"
            echo "  - blender: $(blender --version | head -n1)"
            echo "  - render-stls [project]: Render STL files to PNG"
            echo "    Usage: render-stls                    # Render all projects"
            echo "           render-stls keyhole-pegboard-adapter  # Render specific project"
            echo "  - strip-exif: Remove EXIF data from all images"
          '';
        };
      }
    );
}
