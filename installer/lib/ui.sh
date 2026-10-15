#!/bin/bash
# TUI helpers using whiptail

TITLE="VisionTechOS Installer"
HEIGHT=20
WIDTH=70

ui_welcome() {
    whiptail --title "$TITLE" \
        --msgbox "\nWelcome to VisionTechOS!\n\nThis installer will:\n  • Let you choose your disk\n  • Erase and partition it\n  • Install VisionTechOS\n  • Set up your user account\n\nYour disk will be ERASED. Make sure you have backups.\n\nPress OK to begin." \
        $HEIGHT $WIDTH
}

ui_info() {
    # $1 = message
    whiptail --title "$TITLE" --infobox "$1" 8 $WIDTH
    sleep 1
}

ui_msg() {
    # $1 = message
    whiptail --title "$TITLE" --msgbox "$1" 10 $WIDTH
}

ui_input() {
    # $1 = prompt, $2 = default value
    # Returns value via stdout
    whiptail --title "$TITLE" --inputbox "$1" 10 $WIDTH "$2" 3>&1 1>&2 2>&3
}

ui_password() {
    # $1 = prompt
    whiptail --title "$TITLE" --passwordbox "$1" 10 $WIDTH 3>&1 1>&2 2>&3
}

ui_menu() {
    # $1 = prompt, rest = "tag item" pairs
    local prompt="$1"; shift
    whiptail --title "$TITLE" --menu "$prompt" $HEIGHT $WIDTH 10 "$@" 3>&1 1>&2 2>&3
}

ui_yesno() {
    # $1 = question
    whiptail --title "$TITLE" --yesno "$1" 10 $WIDTH
}

ui_progress() {
    # Pipe lines to this to show a gauge
    # $1 = title text
    whiptail --title "$TITLE" --gauge "$1" 8 $WIDTH 0
}

ui_error() {
    whiptail --title "$TITLE — Error" --msgbox "ERROR: $1" 10 $WIDTH
    exit 1
}
