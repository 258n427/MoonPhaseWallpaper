#!/bin/bash
#
#==============================================================================
#  Project:     MoonPhaseWallpaper
#------------------------------------------------------------------------------
#  File:        configuration.sh
#  Author:      Uli Treuer
#  Purpose:     Defines configuration information and URLs for MoonPhaseWallpaper.
#
#  Copyright (c) 2026 Uli Treuer
#  License:     (to be added)
#==============================================================================

#==================================================================================================
# read_configuration
#
# Define configuration:
# - observer coordinates
#==================================================================================================
read_configuration()
{
local start
local end
local elapsed

    start=$(date +%s.%N)
    logv "In read_configuration"

    # latitude and longitude of Gundelfingen
    readonly OBSERVER_LAT=48.0394
    readonly OBSERVER_LON=7.8664

    logd "LAT:    $OBSERVER_LAT"
    logd "LONG:   $OBSERVER_LON"

    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
}


#==================================================================================================
# define_moonimage_URLs
#
# Defines the URLs from which the moon images will be downloaded.
#
# The following section must be updated at the end of each year for the following year
# (as the URL on the NASA site does not follow any systematic convention).
#
# Check the API view on the NASA page for the URL for the current and potentially next year.
# Navigate to https://svs.gsfc.nasa.gov/ and search for 'libration'
# using the search field in the upper right corner of the web page.
#==================================================================================================
define_moonimage_URLs()
{
local start
local end
local elapsed

    start=$(date +%s.%N)
    logv "In define_moonimage_URLs"
   # current and previous year (in UTC)
    readonly this_year=$(date --utc +"%Y")
    readonly prev_year=$(date --utc -d "last year" +"%Y")

    if [[ "$this_year" == "2026" ]]; then
        # This is the NASA page with the data for 2026: https://svs.gsfc.nasa.gov/5587/
        url_for_this_year="https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587" # 2026
        url_for_prev_year="https://svs.gsfc.nasa.gov/vis/a000000/a005400/a005415" # 2025
    else
        # to be updated for 2027
        # This is the NASA page with the data for 2027: https://svs.gsfc.nasa.gov/xxxx/
        url_for_this_year="https://svs.gsfc.nasa.gov/vis/a000000/a00xxxx/a00xxxx" # 2027
        url_for_prev_year="https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587" # 2026
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
