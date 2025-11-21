#!/bin/bash

KCM_PATHS=(
    "/usr/lib/qt6/plugins/plasma/kcms/systemsettings"
    "/usr/lib/qt6/plugins/plasma/kcms/systemsettings_qwidgets"
)

KEEP=(
    kcm_access.so
    kcm_colors.so
    kcm_icons.so
    kcm_wallpaper.so
    kcm_pulseaudio.so
    kcm_mouse.so
    kcm_keyboard.so
    kcm_touchpad.so
    kcm_networkmanagement.so
    kcm_users.so
    kcm_clock.so
    kcm_powerdevilprofilesconfig.so
    kcm_regionandlang.so
    kcm_cursortheme.so
    kcm_autostart.so
    kcm_bluetooth.so
    kcm_filetypes.so
    kcm_notifications.so
    kcm_nightlight.so
    kcm_soundtheme.so
    kcm_style.so
    kcmspellchecking.so
    kcm_kscreen.so
    kcm_workspace.so
    kcm_virtualkeyboard.so
    kcm_fonts.so
    kcm_screenlocker.so
    kcm_screenlocker.so
    kcm_lookandfeel.so
)

hide_kcms() {
    echo "Requesting root privileges to hide unwanted KCMs…"
    
    PATHS_STR="${KCM_PATHS[*]}"
    KEEP_STR="${KEEP[*]}"
    
    sudo bash <<EOF
IFS=' ' read -r -a PATHS <<< "$PATHS_STR"
IFS=' ' read -r -a KEEP_ARRAY <<< "$KEEP_STR"

for KCM_PATH in "\${PATHS[@]}"; do
    echo "Processing: \$KCM_PATH"
    cd "\$KCM_PATH" || { echo "Path not found: \$KCM_PATH"; continue; }

    for f in *.so; do
        keep=false
        for k in "\${KEEP_ARRAY[@]}"; do
            [[ "\$f" == "\$k" ]] && keep=true
        done

        if [ "\$keep" = true ]; then
            echo "keep: \$f"
        else
            if [[ "\$f" != *.disabled ]]; then
                echo "hide: \$f -> \$f.disabled"
                mv "\$f" "\$f.disabled"
            fi
        fi
    done
done
EOF
    
    echo "Done! All unwanted KCMs have been renamed. Restart KDE to see changes."

}

restore_kcms() {
    echo "Requesting root privileges to restore KCMs…"
    
    PATHS_STR="${KCM_PATHS[*]}"
    
    sudo bash <<EOF
IFS=' ' read -r -a PATHS <<< "$PATHS_STR"

for KCM_PATH in "\${PATHS[@]}"; do
    echo "Processing: \$KCM_PATH"
    cd "\$KCM_PATH" || { echo "Path not found: \$KCM_PATH"; continue; }

    for f in *.so.disabled; do
        [ -e "\$f" ] || continue
        echo "restore: \$f -> \${f%.disabled}"
        mv "\$f" "\${f%.disabled}"
    done
done
EOF
    
    echo "Done! All KCMs restored. Restart KDE to see changes."
    
}

if [[ "$1" == "--uninstall" ]]; then
    restore_kcms
else
    hide_kcms
fi
