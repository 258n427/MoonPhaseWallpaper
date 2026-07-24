#!/bin/bash
#
#==============================================================================
#  Project:     MoonPhaseWallpaper
#------------------------------------------------------------------------------
#  File:        wallpaper.sh
#  Author:      Uli Treuer
#  Purpose:     Installs the generated image as a wallpaper on teh KDE desktops
#               for MoonPhaseWallpaper.
#
#  Copyright (c) 2026 Uli Treuer
#  License:     (to be added)
#==============================================================================

#==================================================================================================
# set_wallpaper
#
# Set the completed image back.png as the new wallpaper on second display in Activity 'Main Screen'
# using Plasma 6 functionality.
# Comments and considerations:
#       - updating the wallpaper only works for the currently active Activity. Therefore we need to
#         switch to 'Main Activity' before updating the wallpaper and then back to the
#         original Activity. To be able to do that we need to determine the currently active
#         Activity, remember it, switch to 'Main Activity', change the wallpaper, and change back
#         to the Activity we remembered.
#       - Updating the wallpaper only works if the new wallpaper has a different name/path than the
#         current wallpaper. Otherwise KDE thinks that nothing has changed and will not update the
#         wallpaper. Therefore we need to briefly set the wallpaper to a 'black image' before
#         setting the newly created wallpaper.
#==================================================================================================
set_wallpaper()
{
local i
local current_user
local BUS
local block
local quoted
local value
local count
local ACT_ID
local ACT_NAME
local ACT_DESC
local ACT_ICON
local MAIN_ACTIVITY_ID
local CUR
local ACTIVITIES_RAW
local -A ACTIVITY_MAP
local start
local end
local elapsed

    start=$(date +%s.%N)
    logv "In set_wallpaper"
    current_user=$(id -un) # user name of the current user
    BUS="unix:path=/run/user/$(id -u "$current_user")/bus"

    # Get list of activities via DBus
    ACTIVITIES_RAW=$(sudo -u "$current_user" DBUS_SESSION_BUS_ADDRESS="$BUS" qdbus-qt6 --literal org.kde.ActivityManager /ActivityManager/Activities ListActivitiesWithInformation)

    # Use process substitution to avoid subshell
    i=1
    while read -r block; do
        # Extract quoted strings
        quoted=$(echo "$block" | grep -oP '"[^"]*"')

        # Read first 4 values, remove surrounding quotes
        count=0
        while read -r value; do
            value="${value%\"}"
            value="${value#\"}"
            case $count in
                0) ACT_ID="$value" ;;
                1) ACT_NAME="$value" ;;
                2) ACT_DESC="$value" ;;
                3) ACT_ICON="$value" ;;
            esac
            ((count++))
            [[ $count -ge 4 ]] && break
        done <<< "$quoted"

        ACTIVITY_MAP["$ACT_NAME"]="$ACT_ID"
        logd "Activity Name | ID: $ACT_NAME | $ACT_ID"

        ((i++))
    done < <(echo "$ACTIVITIES_RAW" | grep -oP '\[Argument: \(ssssi\).*?\]')

    # Get ID of "Main Screen"
    MAIN_ACTIVITY_ID="${ACTIVITY_MAP["Main Screen"]}"
    if [ -z "$MAIN_ACTIVITY_ID" ]; then
        logv "Error: Activity 'Main Screen' not found. Exiting script now."
        exit 1
    fi
    logd "Using Main Screen Activity ID: $MAIN_ACTIVITY_ID"

    # remember current activity
    CUR=$(qdbus-qt6 --bus "$BUS" org.kde.ActivityManager /ActivityManager/Activities CurrentActivity)

    # switch to Main Screen Activity (if not currently active)
    if [[ "$CUR" != "$MAIN_ACTIVITY_ID" ]]; then
        qdbus-qt6 --bus "$BUS" org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity "$MAIN_ACTIVITY_ID"
        #sleep 1
    fi

    # set wallpaper (now applies to Main Screen)
    # Set the updated back.png file as wallpaper on screen 1 (which is the second monitor).
    local black_image
    local wallpaper_image
    black_image="$wdir/images/black-image.png"
    wallpaper_image="$wdir/images/moon_wallpaper.png"

    local js_script
    js_script=$(<"$wdir/lib/set_wallpaper.js")
    js_script="${js_script//__BLACK_IMAGE__/$black_image}"
    js_script="${js_script//__WALLPAPER_IMAGE__/$wallpaper_image}"
    logd "Executing Plasma JavaScript to update wallpaper."
    sudo -u "$current_user" \
        DISPLAY=:0 \
        DBUS_SESSION_BUS_ADDRESS="$BUS" \
        qdbus-qt6 org.kde.plasmashell /PlasmaShell evaluateScript \
        "$js_script"

    # switch back to previous Activity (if we switched before)
    if [[ "$CUR" != "$MAIN_ACTIVITY_ID" ]]; then
        #sleep 1
        qdbus-qt6 --bus "$BUS" org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity "$CUR"
    fi
    logv "Wallpaper replaced."
    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
}

# --- This is the end, my friend ------------------------------------------------------------------
