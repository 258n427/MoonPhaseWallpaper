###############################################################################
# astronomy.awk
#
# Common astronomical AWK functions used by multiple Bash functions.
###############################################################################

###############################################################################
# calc_julian_date
# Calculate the Julian Date (JD)
###############################################################################
function calc_julian_date(hour,day,month,year,     A,B)
{
    if (month <= 2) {
        year--
        month += 12
    }

    A = int(year/100)
    B = 2 - A + int(A/4)

    return int(365.25*(year+4716)) + int(30.6001*(month+1)) + day + B - 1524.5 + hour/24.0
}

###############################################################################
# calc_greenwich_mean_sidereal_time
# Calculate the Greenwich Mean Sidereal Time (GMST)
###############################################################################
function calc_greenwich_mean_sidereal_time(JD,     tmp,T)
{
    T = (JD-2451545.0)/36525.0
    tmp = 280.46061837 + 360.98564736629*(JD-2451545.0) + 0.000387933*T*T - T*T*T/38710000.0

    return normalize360(tmp)
}

###############################################################################
# calc_local_sidereal_time
# Calculate the Local Sidereal Time (LST)
###############################################################################
function calc_local_sidereal_time(GMST,longitude)
{
    return normalize360(GMST + longitude)
}

###############################################################################
# calc_hour_angle
# Calculate the Hour Angle (H)
###############################################################################
function calc_hour_angle(LST,ra)
{
    return normalize180(LST - ra * 15.0)
}

###############################################################################
# calc_altitude
# Calculate the Altitude
###############################################################################
function calc_altitude(lat,dec,H,      s)
{
    s = sin(deg2rad(lat))*sin(deg2rad(dec)) + cos(deg2rad(lat))*cos(deg2rad(dec))*cos(deg2rad(H))

    # guard against tiny floating-point errors
    if (s > 1)  s = 1
    if (s < -1) s = -1

    return rad2deg(atan2(s, sqrt(1 - s*s)))
}

###############################################################################
# calc_parallactic_angle
# Calculate the Parallactic Angle
###############################################################################
function calc_parallactic_angle(lat,dec,H,      Hrad,decrad,latrad,qloc)
{
    Hrad = deg2rad(H)
    decrad = deg2rad(dec)
    latrad = deg2rad(lat)

    qloc = atan2(sin(Hrad), (sin(latrad) / cos(latrad)) * cos(decrad) - sin(decrad) * cos(Hrad))

    return rad2deg(qloc)
}

##############################################################################
# Mathematical helper functions
##############################################################################

function deg2rad(x)
{
    return x * pi / 180.0
}

function rad2deg(x)
{
    return x * 180.0 / pi
}

##############################################################################
# Angle normalization
##############################################################################

function normalize360(angle)
{
    while (angle < 0)
        angle += 360

    while (angle >= 360)
        angle -= 360

    return angle
}

function normalize180(angle)
{
    angle = normalize360(angle)

    if (angle > 180)
        angle -= 360

    return angle
}

# --- This is the end, my friend ------------------------------------------------------------------
