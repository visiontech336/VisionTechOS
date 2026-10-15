#!/bin/bash
# GRUB bootloader installation

step_bootloader() {
    ui_info "Installing bootloader..."

    if [[ "$BOOT_MODE" == "uefi" ]]; then
        chroot "$MOUNT_ROOT" apt-get install -y -q grub-efi-amd64 efibootmgr
        chroot "$MOUNT_ROOT" grub-install \
            --target=x86_64-efi \
            --efi-directory=/boot/efi \
            --bootloader-id=VisionTechOS \
            --recheck
    else
        chroot "$MOUNT_ROOT" apt-get install -y -q grub-pc
        chroot "$MOUNT_ROOT" grub-install \
            --target=i386-pc \
            --recheck \
            "$TARGET_DISK"
    fi

    _write_grub_config
    chroot "$MOUNT_ROOT" update-grub
}

_write_grub_config() {
    cat > "${MOUNT_ROOT}/etc/default/grub" <<'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=3
GRUB_DISTRIBUTOR="VisionTechOS"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
GRUB_TERMINAL_OUTPUT="console"
EOF
}
