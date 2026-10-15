#!/bin/bash
# Cleanup, unmount, and reboot

step_finalize() {
    ui_info "Finalizing installation..."

    # Generate fstab
    genfstab -U "$MOUNT_ROOT" > "${MOUNT_ROOT}/etc/fstab"

    # Enable essential services
    chroot "$MOUNT_ROOT" systemctl enable ssh     &>/dev/null || true
    chroot "$MOUNT_ROOT" systemctl enable fstrim.timer &>/dev/null || true

    # Unmount in reverse order
    _unmount_all

    ui_msg "VisionTechOS has been installed successfully!\n\nRemove the USB drive and press OK to reboot."

    reboot
}

_unmount_all() {
    local mnt="$MOUNT_ROOT"
    umount -l "${mnt}/dev/pts" &>/dev/null || true
    umount -l "${mnt}/dev"     &>/dev/null || true
    umount -l "${mnt}/proc"    &>/dev/null || true
    umount -l "${mnt}/sys"     &>/dev/null || true

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        umount "${mnt}/boot/efi" &>/dev/null || true
    fi

    umount "$mnt" &>/dev/null || true
}
