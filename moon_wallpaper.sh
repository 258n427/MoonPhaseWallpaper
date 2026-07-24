#!/bin/bash

#==================================================================================================
# Moon Phase Wallpaper Generator
#
# Generates hourly wallpapers using NASA SVS Moon imagery.
# Script to download information about moon phases and an image of the moon in the current
# moon phase from the NASA web page https://svs.gsfc.nasa.gov/.
# A nice image is created by overlaying the moon phase information to the downloaded image.
# Finally, the image is set as the wallpaper on screen 2 of the 'Main Screen' Activity.
# This script is called by a user-specific systemd timer at minute 0 of every hour
#
# Features:
# - Automatic download of NASA yearly Moon dataset
# - Correct lunar phase
# - Correct libration
# - Observer-dependent apparent orientation
# - Dynamic text overlay
# - Automatic wallpaper generation

# Dependencies:
# - bash
# - ImageMagick
# - gawk
# - curl
#==================================================================================================

# for deteermining run duration
SECONDS=0

# define working directory wdir
# (directory in which the script is located - no matter what it is called)
readonly wdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$wdir/lib/config.sh"
source "$wdir/lib/astronomy.sh"
source "$wdir/lib/wallpaper.sh"
source "$wdir/lib/read_moon_data_images.sh"
source "$wdir/lib/image_processing.sh"

#evaluate command line options
force_run=false
debug=false
verbose=false
while getopts ":dfv" opt; do
    case "$opt" in
        d)
            debug=true ;;
        f)
            force_run=true ;;
        v)
            verbose=true ;;
        \?)
            echo "Unknown option: -$OPTARG"
            exit 1
            ;;
    esac
done

# define a small logger function to be used when verbose is true
logv()
{
    if $debug || $verbose; then
        echo "$@"
    fi
    return 0
}

# define a small logger function to be used when debug is true
logd()
{
    if $debug; then
        echo "$@"
    fi
    return 0
}

# read all configuration data
read_config

# declare all global arrays which are needed
moonimage=()
moonimage_URL=()
datestamp=()
timestamp=()
phase=()
distance=()
cycle=()
ra=()
dec=()
axisA=()
moonrise=()
moonset=()
moonstatus=()

#--------------------------------------------------------------------------------------------------
# Check whether a new run is actually needed. Script needs to run only once per hour
logtimestamp="$(date "+%d-%b-%Y") $(date "+%H:00")"
if ! $force_run; then
    # If logfile exists, compare
    if [[ -f "$logfile" ]]; then
        read -r previous < "$logfile"
        if [[ "$logtimestamp" == "$previous" ]]; then
            logv "Same timestamp as last run. Exiting script."
            exit 0
        fi
    fi
fi


# Cleanup (just in case the previous run was interrupted and there are leftovers)
clear_image_dir

# Defines the URLs from which the moon images will be downloaded.
# The URLs must be updated at the end of each year for the following year.
# Instructions are contained in the header of function define_moonimage_URLs
# in the file lib/config.sh
define_moonimage_URLs

# download the text file for phase/illumination from the NASA web page
read_moon_info

# determine metadata for all days
calculate_moon_metadata

# download all moon image as defined before from the NASA web page in parallel
download_moon_images

# Create the final image (one big image for current date and time) and 6 small inserts on the final
# image showing the moon image for the 6 days before today (making it the complete last week)
image_processing

# Call the function to set the completed image as the new wallpaper on the second display
# in Activity 'Main Screen'
set_wallpaper

#--------------------------------------------------------------------------------------------------
# once completed, overwrite logfile
echo "$logtimestamp" > "$logfile"
logv "New timestamp recorded."
logv "Moon Wallpaper successfully updated."
logv "Completed in ${SECONDS} seconds."
logv "================================================================================"

exit 0
# --- This is the end, my friend ------------------------------------------------------------------
