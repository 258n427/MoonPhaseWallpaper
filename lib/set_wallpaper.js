//==============================================================================
//  Project:     MoonPhaseWallpaper
//------------------------------------------------------------------------------
//  File:        set_wallpaper.js
//  Author:      Uli Treuer
//  Purpose:     Update the KDE Plasma wallpaper for the selected desktop.
//
//  Copyright (c) 2026 Uli Treuer
//  License:     (to be added)
//==============================================================================

var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
    var d = allDesktops[i];

    if (d.screen == "__SCREEN__") {
        d.wallpaperPlugin = "org.kde.image";
        d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];

        d.writeConfig("Image", "file://__BLACK_IMAGE__");
        d.writeConfig("Image", "file://__WALLPAPER_IMAGE__");
    }
}

// --- This is the end, my friend ------------------------------------------------------------------
