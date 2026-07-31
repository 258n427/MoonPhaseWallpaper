# Installation

## 1. Requirements

MoonPhaseWallpaper has been developed and tested on

- Fedora Linux 44
- KDE Plasma 6.7
- Wayland

Other Linux distributions running KDE Plasma 6.x may also work but have not been tested.

MoonPhaseWallpaper is designed to be installed in a user account without requiring root privileges during normal operation. The application stores its configuration and runtime data in user-specific directories and can be executed either manually or automatically using a user-level systemd timer.

## 2. Install dependencies

Package names shown below are valid for Fedora Linux.

Install the required runtime packages:

```bash
sudo dnf install \
    git \
    ImageMagick \
    curl \
    gawk \
    qt6-qttools
```

## 3. Choose an installation directory

MoonPhaseWallpaper can be installed into any directory within your home directory.

The installation directory is referenced later by the optional `systemd` service template and therefore should not be moved after installation.

## 4. Clone the repository

Navigate to the installation directory and clone the repository:

```bash
mkdir -p ~/Projects
cd ~/Projects

git clone https://github.com/...
cd MoonPhaseWallpaper
```

## 5. Configure the application

Run:

```bash
./moon_wallpaper.sh -c
```

and follow the Configuration Wizard.

## 6. Optional: Install the systemd timer

Edit the service template

```bash
templates/systemd/moon_wallpaper.service
```
The provided systemd user service template contains the placeholder 

`@INSTALL_DIR@`

Replace it with the absolute path to your MoonPhaseWallpaper installation directory.

Copy the template files into your user systemd directory:
```bash
cp templates/systemd/*.service ~/.config/systemd/user/
cp templates/systemd/*.timer   ~/.config/systemd/user/
```

Reload the user systemd configuration and enable the timer:
```bash
systemctl --user daemon-reload

systemctl --user enable --now moon_wallpaper.timer
```
The timer will automatically execute MoonPhaseWallpaper at the beginning of every hour after you log in.

## 7. Verify the installation

In the installation directory, run:

```bash
./moon_wallpaper.sh
```

The wallpaper should be updated.

To verify that the timer is active:

```bash
systemctl --user status moon_wallpaper.timer
```

To inspect recent runs:

```bash
journalctl --user -u moon_wallpaper.service
```

**Congratulations!**

MoonPhaseWallpaper is now installed and ready to use.

You can update the wallpaper manually by running

```bash
./moon_wallpaper.sh
```

or automatically every hour using the user `systemd` timer.

## 8. Updating

This section will be added once an installation script becomes available.