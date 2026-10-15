#!/bin/bash
# Locale and timezone selection

SELECTED_LOCALE=""
SELECTED_TIMEZONE=""

step_locale() {
    # Timezone — pick region first
    local region
    region=$(ui_menu "Select your region:" \
        "Africa"    "Africa" \
        "America"   "Americas" \
        "Asia"      "Asia" \
        "Atlantic"  "Atlantic" \
        "Australia" "Australia" \
        "Europe"    "Europe" \
        "Pacific"   "Pacific" \
        "UTC"       "UTC (no daylight saving)")

    if [[ "$region" == "UTC" ]]; then
        SELECTED_TIMEZONE="UTC"
    else
        # Build a menu from available zones in that region
        local zone_list=()
        while IFS= read -r z; do
            zone_list+=("$z" "$z")
        done < <(timedatectl list-timezones 2>/dev/null | grep "^${region}/" | sed "s|^${region}/||" | head -60)

        local zone
        zone=$(ui_menu "Select your timezone:" "${zone_list[@]}")
        SELECTED_TIMEZONE="${region}/${zone}"
    fi

    # Locale
    SELECTED_LOCALE=$(ui_menu "Select your locale:" \
        "en_US.UTF-8" "English (United States)" \
        "en_GB.UTF-8" "English (United Kingdom)" \
        "de_DE.UTF-8" "German" \
        "fr_FR.UTF-8" "French" \
        "es_ES.UTF-8" "Spanish" \
        "pt_BR.UTF-8" "Portuguese (Brazil)" \
        "zh_CN.UTF-8" "Chinese (Simplified)" \
        "ja_JP.UTF-8" "Japanese" \
        "ko_KR.UTF-8" "Korean" \
        "ar_SA.UTF-8" "Arabic")

    export SELECTED_LOCALE SELECTED_TIMEZONE
}

apply_locale() {
    # Called after chroot is set up
    local root="$1"

    echo "LANG=${SELECTED_LOCALE}" > "${root}/etc/locale.conf"
    echo "${SELECTED_LOCALE} UTF-8" >> "${root}/etc/locale.gen"
    chroot "$root" locale-gen

    ln -sf "/usr/share/zoneinfo/${SELECTED_TIMEZONE}" "${root}/etc/localtime"
    chroot "$root" hwclock --systohc
}
