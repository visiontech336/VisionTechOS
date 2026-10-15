#!/bin/bash
# VisionTechOS Installer — main entry point
set -euo pipefail

INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$INSTALLER_DIR/lib"

source "$LIB/ui.sh"
source "$LIB/checks.sh"
source "$LIB/locale.sh"
source "$LIB/disk.sh"
source "$LIB/system.sh"
source "$LIB/bootloader.sh"
source "$LIB/users.sh"
source "$LIB/network.sh"
source "$LIB/finalize.sh"

main() {
    check_root
    check_uefi_or_bios
    check_internet

    ui_welcome

    # Step 1 — Locale & timezone
    step_locale

    # Step 2 — Disk selection & partitioning
    step_disk

    # Step 3 — Install base system
    step_install_base

    # Step 4 — Bootloader
    step_bootloader

    # Step 5 — Create user
    step_users

    # Step 6 — Hostname & network
    step_network

    # Step 7 — Finalize & reboot
    step_finalize
}

main "$@"
