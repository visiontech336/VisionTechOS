#!/bin/bash
# User account creation

CREATED_USER=""

step_users() {
    # Get username
    while true; do
        CREATED_USER=$(ui_input "Enter a username for your account:" "visionuser")
        if [[ "$CREATED_USER" =~ ^[a-z_][a-z0-9_-]{0,30}$ ]]; then
            break
        fi
        ui_msg "Invalid username. Use lowercase letters, numbers, _ or - only."
    done

    # Get password (with confirmation)
    local pass1 pass2
    while true; do
        pass1=$(ui_password "Enter a password for '$CREATED_USER':")
        pass2=$(ui_password "Confirm password:")
        if [[ "$pass1" == "$pass2" ]]; then
            break
        fi
        ui_msg "Passwords do not match. Try again."
    done

    # Get full name (optional)
    local fullname
    fullname=$(ui_input "Full name (optional):" "")

    # Create user inside chroot
    chroot "$MOUNT_ROOT" useradd \
        -m \
        -s /bin/bash \
        -G sudo,audio,video,plugdev,netdev \
        -c "$fullname" \
        "$CREATED_USER"

    echo "${CREATED_USER}:${pass1}" | chroot "$MOUNT_ROOT" chpasswd

    # Set root password to same
    echo "root:${pass1}" | chroot "$MOUNT_ROOT" chpasswd

    # Lock root login via SSH (good default)
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' \
        "${MOUNT_ROOT}/etc/ssh/sshd_config" 2>/dev/null || true

    export CREATED_USER
}
