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
CONFIGURATION_FILE_DEFAULT_READ=false

#==================================================================================================
# read_configuration
#
# Read the configuration file to define all user-defined data
# - Target activity and screen for generated wallpaper
# - observer coordinates
# - specification for NASA data from NASA website
# Return values:
#       0 => configuration successfully loaded
#       1 => configuration file missing
#       2 => configuration file is invalid
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
            return 2
        fi
        CONFIGURATION_FILE_READ=true
        logd "CONFIGURATION_VERSION:      $CONFIGURATION_VERSION"
        logd "ACTIVITY_NAME:              $ACTIVITY_NAME"
        logd "ACTIVITY_ID:                $ACTIVITY_ID"
        logd "SCREEN:                     $SCREEN"
        logd "OBSERVER_LATITUDE:          $OBSERVER_LATITUDE"
        logd "OBSERVER_LONGITUDE:         $OBSERVER_LONGITUDE"
        logd "NASA_CURR_YEAR:             $NASA_CURR_YEAR"
        logd "NASA_SVS_URL_CURRENT_YEAR:  $NASA_SVS_URL_CURRENT_YEAR"
        logd "NASA_PREV_YEAR:             $NASA_PREV_YEAR"
        logd "NASA_SVS_URL_PREVIOUS_YEAR: $NASA_SVS_URL_PREVIOUS_YEAR"
    else
        return 1
    fi

    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
    return 0
}

#==================================================================================================
# read_default_configuration
#
# Read the default configuration file as a fallback for the user-specific configuration file.
# Return values:
#       0 => default configuration successfully loaded
#       1 => default file missing
#       2 => default file is invalid
#==================================================================================================
read_default_configuration()
{
local start end elapsed

    if $CONFIGURATION_FILE_DEFAULT_READ; then
        return 0 # default configuration file was read before already - no need to read it again
    fi
    start=$(date +%s.%N)
    logv "In read_default_configuration"
    # If configuration file exists, then read it
    if [[ -f "$configfile_default" ]]; then
        if ! source "$configfile_default"; then
            return 2
        fi
        CONFIGURATION_FILE_DEFAULT_READ=true
        logd "DEFAULT_CONFIGURATION_VERSION:      $CONFIGURATION_VERSION"
        logd "DEFAULT_ACTIVITY_NAME:              $ACTIVITY_NAME"
        logd "DEFAULT_ACTIVITY_ID:                $ACTIVITY_ID"
        logd "DEFAULT_SCREEN:                     $SCREEN"
        logd "DEFAULT_OBSERVER_LATITUDE:          $OBSERVER_LATITUDE"
        logd "DEFAULT_OBSERVER_LONGITUDE:         $OBSERVER_LONGITUDE"
        logd "DEFAULT_NASA_CURR_YEAR:             $NASA_CURR_YEAR"
        logd "DEFAULT_NASA_SVS_URL_CURRENT_YEAR:  $NASA_SVS_URL_CURRENT_YEAR"
        logd "DEFAULT_NASA_PREV_YEAR:             $NASA_PREV_YEAR"
        logd "DEFAULT_NASA_SVS_URL_PREVIOUS_YEAR: $NASA_SVS_URL_PREVIOUS_YEAR"
    else
        return 1
    fi

    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
    return 0
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
# conf_write_configuration
#
# Make the configuration as determined by the configuration wizard persistent
# by writing it to the config file
#==================================================================================================
conf_write_configuration()
{
cat >"$configfile" <<EOF
#==============================================================================
# MoonPhaseWallpaper configuration
#
# This file is created and maintained by MoonPhaseWallpaper.
# You may edit it manually if necessary. When doing so make sure that the
# variable assignments must not contain spaces around '='.
#       LABEL=value     => Good
#       LABEL = value   => BAD!!
#==============================================================================

# Configuration version (do not change manually!)
CONFIGURATION_VERSION=1

# KDE Activity
# Defines the Activity (identified by its ID) and screen (0, 1, 2, ...)
# where the generated MoonPhaseWallpaper will be shown.
ACTIVITY_NAME="$wizard_activity_name"
ACTIVITY_ID="$wizard_activity_id"
SCREEN="$wizard_screen"

# Observer location (decimal degrees)
# Latitude:
#       > 0 => north of equator
#       < 0 => south of equator
# Longitude:
#       > 0 => east of Greenwich
#       < 0 => west of Greenwich
OBSERVER_LATITUDE="$wizard_latitude"
OBSERVER_LONGITUDE="$wizard_longitude"

# NASA data
# Defines the URLs from which the moon images and data will be downloaded.
# This section must be updated at the end of each year for the following year
# (as the URL on the NASA site does not follow any systematic convention).
# Check the API view on the NASA page for the URL for the current and
# potentially next year.
# Navigate to https://svs.gsfc.nasa.gov/ and search for 'libration'
# using the search field in the upper right corner of the NASA web page.
# This is the NASA page with the data for 2026: https://svs.gsfc.nasa.gov/5587/
# This is the NASA page with the data for 2025: https://svs.gsfc.nasa.gov/5415/
NASA_CURR_YEAR="$wizard_default_curr_year"
NASA_SVS_URL_CURRENT_YEAR="$wizard_default_curr_url"
NASA_PREV_YEAR="$wizard_default_prev_year"
NASA_SVS_URL_PREVIOUS_YEAR="$wizard_default_prev_url"

EOF
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

#==================================================================================================
# fatal_configuration_error
#
# Closing the application after notifying the user of a fatal configuration error
#==================================================================================================
fatal_configuration_error()
{
    echo
    echo "Fatal configuration error. $1"
    echo "    $2"
    echo "Exiting."
    exit 1
}
# --- This is the end, my friend ------------------------------------------------------------------
