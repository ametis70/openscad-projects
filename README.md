<div align="center">

# OpenSCAD Projects

![license](https://img.shields.io/github/license/ametis70/openscad-projects?style=flat-square)
![openscad](https://img.shields.io/badge/OpenSCAD-yellow?style=flat-square&logo=openscad&logoColor=white)

A collection of 3D printable models and utilities<br />
designed in [OpenSCAD](https://openscad.org) using [BOSL2](https://github.com/BelfrySCAD/BOSL2)

</div>

## Projects

- **[keyhole-pegboard-adapter](projects/keyhole-pegboard-adapter/)** — Customizable adapters for mounting devices to keyhole pegboard systems
- **[mate-base](projects/mate-base/)** — Twisted, tapered holder base for mate and similar cylindrical containers
- **[pcie-riser-bracket-tt-core-p3](projects/pcie-riser-bracket-tt-core-p3/)** — Parametric vertical GPU mounting bracket for Thermaltake Core P3 case

## Dependencies

All projects use the [BOSL2](https://github.com/BelfrySCAD/BOSL2) library, included as a git submodule.

```bash
git submodule update --init --recursive
```

The rendering script depends on [stl-render-tool](https://github.com/ametis70/stl-render-tool), also included as a git submodule.

## Development Environment

This repository includes a Nix flake that provides a development shell with OpenSCAD and Blender.

```bash
# Enter the development shell
nix develop

# Or with direnv
direnv allow
```

### Rendering STL Files

The flake includes a `render-stls` script that automatically renders STL files to PNG images using Blender. The script is configured with a hardcoded list of files to render and their parameters (rotation, material, etc.).

```bash
# Render all projects
render-stls

# Render specific project only
render-stls keyhole-pegboard-adapter
render-stls mate-base
```

Rendered images are saved to `projects/<project-name>/img/renders/` with the same filename as the STL but with a `.png` extension.

### Removing EXIF Data

The flake includes a `strip-exif` script that removes all EXIF metadata (including GPS coordinates and other sensitive information) from JPG/JPEG files in the repository. This is useful before committing photos to prevent accidentally sharing location data or other private information.

```bash
# Remove EXIF data from all JPG/JPEG images
strip-exif
```

The script processes all `.jpg` and `.jpeg` files in project directories (excluding `projects/lib`) and removes metadata in-place.

## Usage

Open any `.scad` file in OpenSCAD to preview and render the models. Each project directory contains a `main.scad` file as the entry point.

## Notes

These models are designed for personal use and 3D printing. Adjust parameters in the source files to fit your specific needs.
