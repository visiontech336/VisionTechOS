#!/bin/bash
# Hostname and network configuration

step_network() {
    local hostname
    while true; do
        hostname=$(ui_input "Enter a hostname for this machine:" "visiontech")
        if [[ "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$ ]]; then
            break
        fi
        ui_msg "Invalid hostname. Letters, numbers, and hyphens only."
    done

    echo "$hostname" > "${MOUNT_ROOT}/etc/hostname"

    cat > "${MOUNT_ROOT}/etc/hosts" <<EOF
127.0.0.1   localhost
127.0.1.1   ${hostname}
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # Enable NetworkManager for post-install connectivity
    chroot "$MOUNT_ROOT" systemctl enable NetworkManager &>/dev/null || true
}
