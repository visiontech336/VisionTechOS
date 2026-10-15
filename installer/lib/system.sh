#!/bin/bash
# Base system installation via debootstrap

VTOS_SUITE="bookworm"          # Debian base
VTOS_MIRROR="http://deb.debian.org/debian"
PACKAGES_LIST="$INSTALLER_DIR/config/packages.list"

step_install_base() {
    ui_info "Installing base system (this may take a few minutes)..."

    local pkgs
    pkgs=$(grep -v '^#' "$PACKAGES_LIST" | tr '\n' ',' | sed 's/,$//')

    debootstrap \
        --arch=amd64 \
        --include="$pkgs" \
        "$VTOS_SUITE" \
        "$MOUNT_ROOT" \
        "$VTOS_MIRROR" \
        2>&1 | _debootstrap_progress

    _bind_mounts
    _configure_apt
    apply_locale "$MOUNT_ROOT"
}

_debootstrap_progress() {
    local i=0
    while IFS= read -r line; do
        i=$(( (i + 1) % 100 ))
        echo "$i"
    done | whiptail --title "$TITLE" --gauge "Installing base system..." 8 70 0
}

_bind_mounts() {
    mount --bind /dev  "${MOUNT_ROOT}/dev"
    mount --bind /proc "${MOUNT_ROOT}/proc"
    mount --bind /sys  "${MOUNT_ROOT}/sys"
    mount -t devpts devpts "${MOUNT_ROOT}/dev/pts"
}

_configure_apt() {
    cat > "${MOUNT_ROOT}/etc/apt/sources.list" <<EOF
deb ${VTOS_MIRROR} ${VTOS_SUITE} main contrib non-free non-free-firmware
deb ${VTOS_MIRROR}-security ${VTOS_SUITE}-security main contrib non-free non-free-firmware
deb ${VTOS_MIRROR} ${VTOS_SUITE}-updates main contrib non-free non-free-firmware
EOF

    chroot "$MOUNT_ROOT" apt-get update -q
}
