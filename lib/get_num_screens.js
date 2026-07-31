//==============================================================================
//  Project:     MoonPhaseWallpaper
//------------------------------------------------------------------------------
//  File:        get_num_screens.js
//  Author:      Uli Treuer
//  Purpose:     Return the number of connected screens reported by KDE.
//
//  Copyright (c) 2026 Uli Treuer
//  License: MIT
//==============================================================================

var allDesktops = desktops();

var maxScreen = -1;

for (var i = 0; i < allDesktops.length; i++) {
    var d = allDesktops[i];

    if (d.screen > maxScreen){
        maxScreen = d.screen;
    }
}

print(maxScreen + 1 + "\n");

// --- This is the end, my friend ------------------------------------------------------------------
