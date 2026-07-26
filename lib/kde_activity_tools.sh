#!/bin/bash
#
#==============================================================================
#  Project:     MoonPhaseWallpaper
#------------------------------------------------------------------------------
#  File:        kde_activity_tools.sh
#  Author:      Uli Treuer
#  Purpose:     Provides tools for managing KDE Activities
#               for MoonPhaseWallpaper.
#
#  Copyright (c) 2026 Uli Treuer
#  License:     (to be added)
#==============================================================================

#==================================================================================================
# switch_to_activity
#
# Activate the Activity with the specified ID. Do nothing if this Activity is already active.
#==================================================================================================
switch_to_activity()
{
local new_activity_id="$1"
local current_activity_id

    get_current_activity_id current_activity_id

    # switch to specified Activity (if not currently active)
    if [[ "$current_activity_id" != "$new_activity_id" ]]; then
        get_activity_bus BUS
        qdbus-qt6 --bus "$BUS" org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity "$new_activity_id"
    fi
}

#==================================================================================================
# get_current_activity_id
#
# Return the ID of the currently active Activity.
#==================================================================================================
get_current_activity_id()
{
local -n activity_id_ref=$1
local BUS

    get_activity_bus BUS
    activity_id_ref=$(qdbus-qt6 --bus "$BUS" org.kde.ActivityManager /ActivityManager/Activities CurrentActivity)
}

#==================================================================================================
# activity_id_from_name
#
# Return the ID of the Activity with the specified name.
#==================================================================================================
activity_id_from_name()
{
local activity_name=$1
local -n activity_id_ref=$2

local -A activity_map

    logd "In activity_id_from_name"
    create_activity_map activity_map
    # Get ID of requested activity from activity_map
    activity_id_ref="${activity_map["$activity_name"]}"
    if [ -z "$activity_id_ref" ]; then
        logv "Error: Activity '$activity_name' not found. Exiting script now."
        exit 1
    fi
    logd "Using Activity ID: $activity_id_ref"
}

#==================================================================================================
# get_activity_bus
#
# Get the BUS variable required for most Activity-related function calls.
#==================================================================================================
get_activity_bus()
{
local -n bus_ref=$1
local current_user

    get_current_user current_user
    bus_ref="unix:path=/run/user/$(id -u "$current_user")/bus"
}

#==================================================================================================
# get_current_user
#
# return the user name of the current user.
#==================================================================================================
get_current_user()
{
local -n user_ref=$1

    user_ref=$(id -un)
}

#==================================================================================================
# create_activity_map
#
# Create an associative array connecting Activity name and Activity ID for all Activities.
#==================================================================================================
create_activity_map()
{
local -n map_ref=$1
local -n num_activities_ref=$2

local current_user
local BUS
local ACTIVITIES_RAW
local quoted
local count
local ACT_ID ACT_NAME ACT_DESC ACT_ICON

    logd "In create_activity_map"
    get_activity_bus BUS

    get_current_user current_user
    ACTIVITIES_RAW=$(sudo -u "$current_user" \
        DBUS_SESSION_BUS_ADDRESS="$BUS" \
        qdbus-qt6 --literal \
        org.kde.ActivityManager \
        /ActivityManager/Activities \
        ListActivitiesWithInformation)

    num_activities_ref=0
    while read -r block; do
        quoted=$(grep -oP '"[^"]*"' <<< "$block")

        count=0
        while read -r value; do
            value="${value%\"}"
            value="${value#\"}"

            case $count in
                0) ACT_ID=$value ;;
                1) ACT_NAME=$value ;;
                2) ACT_DESC=$value ;;
                3) ACT_ICON=$value ;;
            esac

            ((count++))
            ((count >= 4)) && break
        done <<< "$quoted"

        num_activities_ref=$((num_activities_ref+1))
        map_ref["$ACT_NAME"]="$ACT_ID"
        logd "Activity Name | ID: $ACT_NAME | $ACT_ID"

    done < <(grep -oP '\[Argument: \(ssssi\).*?\]' <<< "$ACTIVITIES_RAW")
}

#==================================================================================================
# get_num_screens
#
# Return the number of screens from KDE
#==================================================================================================
get_num_screens()
{
local -n num_screens_ref=$1
local current_user
local BUS

    logd "In get_num_screens"
    get_activity_bus BUS
    get_current_user current_user
    js_script=$(<"$wdir/lib/get_num_screens.js")
    num_screens_ref=$(sudo -u "$current_user" \
        DISPLAY=:0 \
        DBUS_SESSION_BUS_ADDRESS="$BUS" \
        qdbus-qt6 org.kde.plasmashell /PlasmaShell evaluateScript \
        "$js_script")
}

# --- This is the end, my friend ------------------------------------------------------------------
