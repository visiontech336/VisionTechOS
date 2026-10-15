#!/bin/bash
# Pre-flight checks

BOOT_MODE=""

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: The installer must be run as root." >&2
        exit 1
    fi
}

check_uefi_or_bios() {
    if [[ -d /sys/firmware/efi ]]; then
        BOOT_MODE="uefi"
    else
        BOOT_MODE="bios"
    fi
    export BOOT_MODE
}

check_internet() {
    ui_info "Checking internet connection..."
    if ! ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
        ui_error "No internet connection detected.\n\nConnect to a network and re-run the installer."
    fi
}
