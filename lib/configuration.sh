#!/bin/bash
#
#==============================================================================
#  Project:     MoonPhaseWallpaper
#------------------------------------------------------------------------------
#  File:        configuration.sh
#  Author:      Uli Treuer
#  Purpose:     Manages configuration information for MoonPhaseWallpaper.
#
#  Copyright (c) 2026 Uli Treuer
#  License:     (to be added)
#==============================================================================

# set initially to false to indicate that the configuration file
# has not been read yet
CONFIGURATION_FILE_READ=false

#==================================================================================================
# read_configuration
#
# Reads the configuration file to define all user-defined data
# - Target activity and screen for generated wallpaper
# - observer coordinates
# - specification for NASA data from NASA website
#==================================================================================================
read_configuration()
{
local start end elapsed

    if $CONFIGURATION_FILE_READ; then
        return 0 # configuration file was read before already - no need to read it again
    fi
    start=$(date +%s.%N)
    logv "In read_configuration"
    # If configuration file exists, then read it
    if [[ -f "$configfile" ]]; then
        if ! source "$configfile"; then
            echo "Unable to read configuration:"
            echo "    $configfile"
            exit 1
        fi
        CONFIGURATION_FILE_READ=true
        logd "ACTIVITY_ID:        $ACTIVITY_ID"
        logd "SCREEN:             $SCREEN"
        logd "OBSERVER_LATITUDE:  $OBSERVER_LATITUDE"
        logd "OBSERVER_LONGITUDE: $OBSERVER_LONGITUDE"
        logd "NASA_CURR_YEAR:             $NASA_CURR_YEAR"
        logd "NASA_SVS_URL_CURRENT_YEAR:  $NASA_SVS_URL_CURRENT_YEAR"
        logd "NASA_PREV_YEAR:             $NASA_PREV_YEAR"
        logd "NASA_SVS_URL_PREVIOUS_YEAR: $NASA_SVS_URL_PREVIOUS_YEAR"
    else
        echo "Not implemented yet!"
    fi

    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
}

#==================================================================================================
# conf_get_target_activity
#
# Returns by reference the target activity ID and target screen as read from configuration file
#==================================================================================================
conf_get_target_activity()
{
local -n activity_id_ref=$1
local -n screen_ref=$2

    read_configuration
    activity_id_ref=$ACTIVITY_ID
    screen_ref=$SCREEN
}

#==================================================================================================
# conf_get_observer_data
#
# Returns by reference the observer latitude and longitude as read from configuration file
#==================================================================================================
conf_get_observer_data()
{
local -n latitude_ref=$1
local -n longitude_ref=$2

    read_configuration
    latitude_ref=$OBSERVER_LATITUDE
    longitude_ref=$OBSERVER_LONGITUDE
}

#==================================================================================================
# conf_get_nasa_url_data
#
# Returns by reference the NASA URL-related data as read from configuration file
#==================================================================================================
conf_get_nasa_url_data()
{
local -n curr_year_ref=$1
local -n curr_year_url_ref=$2
local -n prev_year_ref=$3
local -n prev_year_url_ref=$4

    read_configuration
    curr_year_ref=$NASA_CURR_YEAR
    curr_year_url_ref=$NASA_SVS_URL_CURRENT_YEAR
    prev_year_ref=$NASA_PREV_YEAR
    prev_year_url_ref=$NASA_SVS_URL_PREVIOUS_YEAR
}

#==================================================================================================
# write_configuration
#
# tbd
#==================================================================================================
conf_write_configuration()
{
    return 0
}

#==================================================================================================
# define_moonimage_URLs
#
# Defines the URLs from which the moon images will be downloaded.
#
# The years and URLs are defined in the configuration file configuration/moon_wallpaper.conf and
# must be updated every year. Instructions how to do that are included in the configuration file
#==================================================================================================
define_moonimage_URLs()
{
local nasa_curr_year nasa_curr_year_url nasa_prev_year nasa_prev_year_url
local start end elapsed

    start=$(date +%s.%N)
    logv "In define_moonimage_URLs"

    # Get NASA data as defined by configuration
    conf_get_nasa_url_data nasa_curr_year nasa_curr_year_url nasa_prev_year nasa_prev_year_url

   # current and previous year (in UTC)
    readonly this_year=$(date --utc +"%Y")
    readonly prev_year=$(date --utc -d "last year" +"%Y")

    if [[ "$this_year" == "$nasa_curr_year" ]]; then
        url_for_this_year="$nasa_curr_year_url"
        url_for_prev_year="$nasa_prev_year_url"
    else
        # incorrect configuration, needs to be updated for new year.
        echo "Configuration error."
        echo
        echo "Please update:"
        echo "    $configfile"
        exit 1
    fi

    logd "This Year:      $this_year"
    logd "Prev Year:      $prev_year"
    logd "URL this year:  $url_for_this_year"
    logd "URL prev year:  $url_for_prev_year"
    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "

}

# --- This is the end, my friend ------------------------------------------------------------------
