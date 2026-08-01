#!/bin/bash
#
#==============================================================================
#  Project:     MoonPhaseWallpaper
#------------------------------------------------------------------------------
#  File:        wallpaper.sh
#  Author:      Uli Treuer
#  Purpose:     Updates the KDE wallpaper using the generated image.
#
#  Copyright (c) 2026 Uli Treuer
#  License: MIT
#==============================================================================

#==================================================================================================
# set_wallpaper
#
# Set the generated image as the wallpaper for the configured Activity and Screen
# using Plasma 6 functionality.
# Comments and considerations:
#       - Updating the wallpaper only works for the currently active Activity. Therefore we need to
#         switch to the target Activity before updating the wallpaper and then back to the
#         original Activity. To be able to do that we need to determine the currently active
#         Activity, remember it, switch to the target Activity, change the wallpaper, and change
#         back to the Activity we remembered.
#       - Updating the wallpaper only works if the new wallpaper has a different name/path than the
#         current wallpaper. Otherwise KDE thinks that nothing has changed and will not update the
#         wallpaper. Therefore we need to briefly set the wallpaper to a 'black image' before
#         setting the newly created wallpaper.
#==================================================================================================
set_wallpaper()
{
local BUS
local target_activity_id target_screen
local current_activity_id
local black_image wallpaper_image js_script
local start end elapsed

    start=$(date +%s.%N)
    logv "In set_wallpaper"

    # Get the configured target activity and screen
    conf_get_target_activity target_activity_id target_screen

    # Remember the currently active Activity
    get_current_activity_id current_activity_id

    # Switch to the configured target activity
    switch_to_activity "$target_activity_id"

    # Set wallpaper on the configured Activity and screen
    black_image="$wdir/images/black_image.png"
    wallpaper_image="$wdir/images/moon_wallpaper.png"

    js_script=$(<"$wdir/lib/set_wallpaper.js")
    js_script="${js_script//__SCREEN__/$target_screen}"
    js_script="${js_script//__BLACK_IMAGE__/$black_image}"
    js_script="${js_script//__WALLPAPER_IMAGE__/$wallpaper_image}"
    logd "Executing Plasma JavaScript to update wallpaper."
    get_activity_bus BUS
    DISPLAY=:0 \
        DBUS_SESSION_BUS_ADDRESS="$BUS" \
        qdbus-qt6 org.kde.plasmashell /PlasmaShell evaluateScript \
        "$js_script"

    # Restore the previously active Activity
    switch_to_activity "$current_activity_id"

    logv "Wallpaper replaced."
    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
}

# --- This is the end, my friend ------------------------------------------------------------------
