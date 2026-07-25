#!/bin/bash
#
#==============================================================================
#  Project:     MoonPhaseWallpaper
#------------------------------------------------------------------------------
#  File:        directories.sh
#  Author:      Uli Treuer
#  Purpose:     Defines working directories for MoonPhaseWallpaper.
#
#  Copyright (c) 2026 Uli Treuer
#  License:     (to be added)
#==============================================================================

#==================================================================================================
# set_directories
#
# Define configuration:
# - all required/used directories
# - observer coordinates
#==================================================================================================
set_directories()
{
local start end elapsed

    start=$(date +%s.%N)
    logv "In set_directories"
    # define directories
    readonly imdir="$wdir/images" # image directory
    mkdir -p "$imdir"
    readonly ddir="$wdir/data" # data directory
    mkdir -p "$ddir"
    readonly logfile="$ddir/last_run.log"
    readonly configdir="$wdir/configuration"  # configuration directory
    mkdir -p "$configdir"
    readonly configfile="$configdir/moon_wallpaper.conf"
    readonly AWK_ASTRONOMY="$wdir/lib/astronomy.awk"

    logd "wdir:      $wdir"
    logd "imdir:     $imdir"
    logd "ddir:      $ddir"
    logd "configdir: $configdir"
    logd "AWKlib:    $AWK_ASTRONOMY"
    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
}

# --- This is the end, my friend ------------------------------------------------------------------
