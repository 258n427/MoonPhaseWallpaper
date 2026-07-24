#!/bin/bash
#
#==============================================================================
#  Project:     MoonPhaseWallpaper
#------------------------------------------------------------------------------
#  File:        image_processing.sh
#  Author:      Uli Treuer
#  Purpose:     Provides image processing and handling for MoonPhaseWallpaper.
#
#  Copyright (c) 2026 Uli Treuer
#  License:     (to be added)
#==============================================================================

#==================================================================================================
# image_processing
#
# Create the final image (index 0 = one big image for current date and time) and 6 small inserts
# on the final image showing the moon image for the 6 days before today (making it the complete
# last week)
#==================================================================================================
image_processing()
{
local i
local rotation
local new_x
local new_y
local new_pos
local y_pos
local text1
local text2
local text3
local text4
local text5
local text6
local text7
local text8
local start
local end
local elapsed

    start=$(date +%s.%N)
    logv "In image_processing"
    cd "$imdir" || {
        logv "ERROR: cannot enter $imdir" >&2
        exit 1
    }

    y_pos=1075
    for (( i=0; i<7; i++ )); do
        if (( i == 0 )); then
            rotation=$(calc_moon_rotation \
                "${datestamp[i]}" \
                "${timestamp[i]}" \
                "${ra[i]}" \
                "${dec[i]}" \
                "${axisA[i]}")

            new_x=1920
            new_y=1080
            new_pos="+0+0"

            # build the strings for the image caption
            text1="Date:                ${datestamp[0]}"
            text2="Status Time:         ${timestamp[0]}"
            text3="Moonrise:            ${moonrise[0]}"
            text4="Moonset:             ${moonset[0]}"
            text5="Status:              ${moonstatus[0]}"
            text6="Visibility:          ${phase[0]}%"
            text7="Days into Cycle:     ${cycle[0]}"
            text8="Distance from Earth: ${distance[0]} km"
        else
            rotation=$(calc_moon_rotation \
                "${datestamp[i]}" \
                "${timestamp[i]}" \
                "${ra[i]}" \
                "${dec[i]}" \
                "${axisA[i]}")

            new_x=267
            new_y=150
            new_pos="+30+0"
            y_pos=$((y_pos-175))

            # build the strings for the image caption
            text1="${datestamp[i]}"
            text2="${timestamp[i]}"
            text3="${phase[i]}%"
            text4="${cycle[i]}"
            text5="${distance[i]} km"
        fi

        if (( i == 0 )); then
            logv "Processing big image $((i+1))"
            # Step 1: resize star background image
            # Step 2: resize downloaded image
            # Step 3: rotate downloaded image according to observer position
            # Step 4: increase brightness of rotated image to 110%
            # Step 5: overlay downloaded and rotated image on top of star background
            # Step 6: create semi-transparent mask with blurred, rounded edges as background for the captions
            # Step 7: overlay the mask on top of the image created so far
            # Step 8: add the captions defined before to the image (inside the rectangle defined by the mask)
            magick \
                stars_background.tif \
                    -resize "${new_x}x${new_y}" \
                \( "${moonimage[i]}" \
                    -resize "${new_x}x${new_y}" \
                    -background none \
                    -rotate "$rotation" \
                    +repage \
                    -gravity center \
                    -crop "${new_x}x${new_y}+0+0" \
                    +repage \
                    -modulate 110x100 \
                \) \
                    -gravity northwest \
                    -geometry "$new_pos" \
                    -composite \
                \( -size 1920x1080 xc:none \
                    -fill "#00000080" \
                    -draw "roundrectangle 1560,800 1880,1040 20,20" \
                    -gaussian-blur 10x10 \
                \) \
                -composite \
                -font noto-sans-mono-semicondensed-bold \
                -fill '#ffb600' \
                -pointsize 15 \
                -draw "text 1575,825 '$text1'" \
                -draw "text 1575,850 '$text2'" \
                -draw "text 1575,875 '$text3'" \
                -draw "text 1575,900 '$text4'" \
                -draw "text 1575,925 '$text5'" \
                -draw "text 1575,950 '$text6'" \
                -draw "text 1575,975 '$text7'" \
                -draw "text 1575,1000 '$text8'" \
                final.tif

        else
            logv "Processing small image $((i+1))"
            # Step 1: resize star background image
            # Step 2: resize downloaded image
            # Step 3: rotate downloaded image according to observer position
            # Step 4: increase brightness of rotated image to 110%
            # Step 5: overlay downloaded and rotated image on top of star background
            # Step 6: add the captions defined before to the image
            # Step 7: create a border around the inserted image
            # Step 8: overlay small picture on top of background
            magick final.tif \
                \( \
                    stars_background.tif \
                        -resize "${new_x}x${new_y}" \
                    \( "${moonimage[i]}" \
                        -resize "${new_x}x${new_y}" \
                        -background none \
                        -rotate "$rotation" \
                        +repage \
                        -gravity center \
                        -crop "${new_x}x${new_y}+0+0" \
                        +repage \
                        -modulate 110x100 \
                    \) \
                    -gravity northwest \
                    -geometry "$new_pos" \
                    -composite \
                    -font noto-sans-mono-semicondensed-bold \
                    -fill '#ffb600' \
                    -pointsize 10 \
                    -draw "text 7,15 '$text1'" \
                    -draw "text 7,30 '$text2'" \
                    -draw "text 7,45 '$text3'" \
                    -draw "text 7,60 '$text4'" \
                    -draw "text 7,75 '$text5'" \
                    -bordercolor '#222222' \
                    -border 1 \
                \) \
                -geometry "+25+${y_pos}" \
                -composite \
                final.tif
        fi
        # removing the downloaded moon image as not to use up storage
        rm -f "${moonimage[i]}"
    done

    # convert final image to .png (as the file size will be much smaller) => back.png
    magick final.tif moon_wallpaper.png
    # remove last temporary file
    rm -f final.tif
    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
}

#==================================================================================================
# clear_image_dir
#
# Cleanup (just in case the previous run was interrupted and there are leftovers)
#==================================================================================================
clear_image_dir()
{
local start
local end
local elapsed

    start=$(date +%s.%N)
    logv "In clear_image_dir"
    cd "$imdir" || {
        logv "ERROR: cannot enter $imdir" >&2
        exit 1
    }
    logv "Removing potential leftovers images"
    rm -f moon.[0-9][0-9][0-9][0-9].tif # downloaded images
    rm -f final.tif # intermediate file from ImageMagick
    end=$(date +%s.%N)
    elapsed=$(awk "BEGIN { printf \"%.2f\", $end - $start }")
    logd "Completed in ${elapsed} seconds."
    logv "================================================================================"
    logv " "
}

# --- This is the end, my friend ------------------------------------------------------------------
