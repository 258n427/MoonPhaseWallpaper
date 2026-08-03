//==============================================================================
//  Project:     MoonPhaseWallpaper
//------------------------------------------------------------------------------
//  File:        set_wallpaper.js
//  Author:      Uli Treuer
//  Purpose:     Update the KDE Plasma wallpaper for the selected screen.
//
// Input:
//      screen
//      wallpaper paths
//
// Output:
//      Prints "1" if a wallpaper was updated.
//      Prints "0" if no matching desktop was found.
//
//  Copyright (c) 2026 Uli Treuer
//  License: MIT
//==============================================================================

var allDesktops = desktops();
var wallpaper_changed = false;

for (var i = 0; i < allDesktops.length; i++) {
    var d = allDesktops[i];

    if (d.screen == "__SCREEN__") {
        d.wallpaperPlugin = "org.kde.image";
        d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];

        d.writeConfig("Image", "file://__WALLPAPER_IMAGE__");
        wallpaper_changed = true;
    }
}

print(wallpaper_changed ? "1\n" : "0\n");

// --- This is the end, my friend ------------------------------------------------------------------
