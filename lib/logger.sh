#!/bin/bash
#
#==============================================================================
#  Project:     MoonPhaseWallpaper
#------------------------------------------------------------------------------
#  File:        logger.sh
#  Author:      Uli Treuer
#  Purpose:     Defines functions for logging output (currently only on screen)
#
#  Copyright (c) 2026 Uli Treuer
#  License:     (to be added)
#==============================================================================

#==================================================================================================
# logv
#
# log function to log output on screen when debug mode or verbose mode is active
#==================================================================================================
logv()
{
    if $debug_mode || $verbose_mode; then
        echo "$@"
    fi
    return 0
}

#==================================================================================================
# logd
#
# log function to log debug output on screen when debug mode is active
#==================================================================================================
logd()
{
    if $debug_mode; then
        echo "$@"
    fi
    return 0
}

# --- This is the end, my friend ------------------------------------------------------------------
