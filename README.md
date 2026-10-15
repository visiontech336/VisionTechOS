# VisionTechOS

A fast, open source Linux-based desktop operating system. No accounts. No data collection. No fees.

Download the ISO, burn it to a USB drive, boot into it, and install — just like any Linux distro.

---

## Features

- **Fast** — lightweight, optimized for modern desktops
- **Private** — zero telemetry, zero data collection, zero accounts required
- **Open Source** — fork it, build it, improve it
- **Custom Installer** — guided walkthrough that partitions and installs to disk
- **Linux-based** — familiar package ecosystem, hardware support out of the box

## Getting Started

### Install from USB

1. Download the latest `.iso` from [Releases](../../releases)
2. Burn it to a USB drive (e.g. with [Balena Etcher](https://www.balena.io/etcher/))
3. Boot your PC from the USB
4. Follow the on-screen installer to erase your disk and install VisionTechOS

### Build from Source

> Requirements: Linux host, `git`, `docker` or `debootstrap`

```bash
git clone https://github.com/visiontech336/VisionTechOS.git
cd VisionTechOS
./scripts/build.sh
```

The build outputs an `.iso` in the `dist/` directory.

## Project Structure

```
VisionTechOS/
├── installer/        # Custom OS installer (guided setup, disk erase, partitioning)
├── base/             # Base system config and packages
├── desktop/          # Desktop environment and UI customizations
├── scripts/          # Build scripts
├── docs/             # Documentation
└── dist/             # Build output (gitignored)
```

## Contributing

Pull requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[GPL-3.0](LICENSE)
