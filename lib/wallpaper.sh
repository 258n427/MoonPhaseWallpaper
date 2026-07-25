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
local CURRENT_ACTIVITY_ID
local ACTIVITIES_RAW
local -A ACTIVITY_MAP
local start
local end
local elapsed

    start=$(date +%s.%N)
    logv "In set_wallpaper"

    # find the ID of the 'Main Screen' Activity
    activity_id_from_name "Main Screen" MAIN_ACTIVITY_ID

    # remember current activity
    get_current_activity_id CURRENT_ACTIVITY_ID

    # switch to 'Main Screen' Activity (if not currently active)
    switch_to_activity "$MAIN_ACTIVITY_ID"


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
    get_activity_bus BUS
    get_current_user current_user
    sudo -u "$current_user" \
        DISPLAY=:0 \
        DBUS_SESSION_BUS_ADDRESS="$BUS" \
        qdbus-qt6 org.kde.plasmashell /PlasmaShell evaluateScript \
        "$js_script"

    # switch back to previous Activity (if we switched before)
    switch_to_activity "$CURRENT_ACTIVITY_ID"

    logv "Wallpaper replaced."
    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
}

# --- This is the end, my friend ------------------------------------------------------------------
