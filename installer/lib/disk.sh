#!/bin/bash
# Disk detection, selection, partitioning, and formatting

TARGET_DISK=""
EFI_PART=""
ROOT_PART=""
MOUNT_ROOT="/mnt/vtos"

step_disk() {
    _select_disk
    _confirm_erase
    _partition_disk
    _format_partitions
    _mount_partitions
}

_select_disk() {
    local disk_list=()
    while IFS= read -r line; do
        local dev size model
        dev=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        model=$(echo "$line" | awk '{$1=$2=""; print $0}' | xargs)
        disk_list+=("/dev/$dev" "$size  $model")
    done < <(lsblk -d -o NAME,SIZE,MODEL --noheadings | grep -v "loop\|sr")

    if [[ ${#disk_list[@]} -eq 0 ]]; then
        ui_error "No disks found."
    fi

    TARGET_DISK=$(ui_menu "Select the disk to install VisionTechOS on:\n\nWARNING: All data on the selected disk will be erased." \
        "${disk_list[@]}")

    export TARGET_DISK
}

_confirm_erase() {
    local disk_info
    disk_info=$(lsblk -d -o SIZE,MODEL "$TARGET_DISK" --noheadings | xargs)

    if ! ui_yesno "FINAL WARNING\n\nYou are about to ERASE:\n\n  $TARGET_DISK  ($disk_info)\n\nThis cannot be undone. Continue?"; then
        ui_msg "Installation cancelled."
        exit 0
    fi
}

_partition_disk() {
    ui_info "Partitioning $TARGET_DISK..."

    # Wipe existing partition table
    wipefs -a "$TARGET_DISK" &>/dev/null
    sgdisk -Z "$TARGET_DISK" &>/dev/null

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        # GPT: 512MB EFI + rest root
        parted -s "$TARGET_DISK" \
            mklabel gpt \
            mkpart ESP fat32 1MiB 513MiB \
            set 1 esp on \
            mkpart primary ext4 513MiB 100%

        EFI_PART="${TARGET_DISK}1"
        ROOT_PART="${TARGET_DISK}2"
    else
        # MBR: 1MB BIOS boot gap + rest root
        parted -s "$TARGET_DISK" \
            mklabel msdos \
            mkpart primary ext4 1MiB 100% \
            set 1 boot on

        ROOT_PART="${TARGET_DISK}1"
    fi

    # Re-read partition table
    partprobe "$TARGET_DISK"
    sleep 1

    export EFI_PART ROOT_PART
}

_format_partitions() {
    ui_info "Formatting partitions..."

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        mkfs.fat -F32 -n EFI "$EFI_PART" &>/dev/null
    fi

    mkfs.ext4 -L VisionTechOS "$ROOT_PART" &>/dev/null
}

_mount_partitions() {
    ui_info "Mounting partitions..."

    mkdir -p "$MOUNT_ROOT"
    mount "$ROOT_PART" "$MOUNT_ROOT"

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        mkdir -p "${MOUNT_ROOT}/boot/efi"
        mount "$EFI_PART" "${MOUNT_ROOT}/boot/efi"
    fi

    export MOUNT_ROOT
}
