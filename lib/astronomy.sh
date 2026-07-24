#!/bin/bash

#==================================================================================================
# calc_moon_rotation
#
# Calculates the apparent orientation of the Moon for an observer in Gundelfingen.
#
# Input:
#   $1  datestamp
#   $2  timestamp  (UTC)
#   $3  Right Ascension (hours)
#   $4  Declination (degrees)
#   $5  AxisA (degrees from NASA file)
#
# Output:
#   Rotation angle for ImageMagick
#==================================================================================================
calc_moon_rotation()
{
    local datestamp="$1"
    local timestamp="$2"
    local ra="$3"
    local dec="$4"
    local axis="$5"

    #
    # Gundelfingen
    #
    local latitude="$OBSERVER_LAT"
    local longitude="$OBSERVER_LON"

    #######################################################################
    # Extract year, month, day and hour from the strings
    #######################################################################

    local day="${datestamp:0:2}"
    local mon="${datestamp:3:3}"
    local year="${datestamp:7:4}"

    local hour="${timestamp:0:2}"

    case "$mon" in
        Jan) month=1 ;;
        Feb) month=2 ;;
        Mar) month=3 ;;
        Apr) month=4 ;;
        May) month=5 ;;
        Jun) month=6 ;;
        Jul) month=7 ;;
        Aug) month=8 ;;
        Sep) month=9 ;;
        Oct) month=10 ;;
        Nov) month=11 ;;
        Dec) month=12 ;;
        *)
            echo "Unknown month '$mon'" >&2
            return 1
            ;;
    esac

    awk \
        -i "$AWK_ASTRONOMY" \
        -v year="$year" \
        -v month="$month" \
        -v day="$day" \
        -v hour="$hour" \
        -v ra="$ra" \
        -v dec="$dec" \
        -v axis="$axis" \
        -v lat="$latitude" \
        -v lon="$longitude" '

    BEGIN {

        pi = atan2(0,-1)

        ###################################################################
        # Julian Date (JD)
        ###################################################################
        JD = calc_julian_date(hour,day,month,year)

        ###################################################################
        # Greenwich Mean Sidereal Time (GMST)
        ###################################################################
        GMST = calc_greenwich_mean_sidereal_time(JD)

        ###################################################################
        # Local Sidereal Time (LST)
        ###################################################################
        LST = calc_local_sidereal_time(GMST,lon)

        ###################################################################
        # Hour Angle
        ###################################################################
        H = calc_hour_angle(LST,ra)

        ###################################################################
        # Parallactic Angle
        ###################################################################
        q = calc_parallactic_angle(lat,dec,H)

        ###################################################################
        # Apparent Moon orientation
        #
        # P = AxisA from NASA
        # q = parallactic angle
        ###################################################################

        #
        # Apparent orientation of the lunar disk.
        #
        # AxisA is NASAs Position Angle (P) of the Moons north pole,
        # measured from celestial north.
        #
        # q is the observers parallactic angle.
        #
        # The apparent orientation of the Moon is:
        #
        #     P - q
        #
        # ImageMagick uses positive angles as counter-clockwise,
        # therefore the returned value is negated.
        rotation = axis - q

        rotation = normalize360(rotation)

        ###################################################################
        # ImageMagick:
        #
        # positive = counter-clockwise
        # negative = clockwise
        ###################################################################

        printf "%.2f\n", -rotation
    }'
}

#==================================================================================================
# calc_moonrise_set
#
# Calculates moonrise, moonset and current horizon status.
#
# Input:
#   $1  year
#   $2  day of year (1..366)
#   $3  current UTC hour
#
# Output (stdout):
#
#   moonrise|moonset|status
#
# Example (moonrise and moonset are calculated in minutes after midnight):
#
#   744|900|Above horizon
#
# NOTE:
# This function evaluates the 24 UTC hours of the requested day.
# In rare cases (typically when a moonrise or moonset occurs shortly after
# midnight UTC), an event may belong to the adjacent UTC day and therefore
# not be detected. Extending the evaluation window to 26 hours
# (23:00 previous day through 00:00 next day) would eliminate this edge case.
#==================================================================================================
calc_moonrise_set()
{
    local data="$1"
    local year="$2"
    local latitude="$3"
    local longitude="$4"
    local current_hour="$5"

    awk \
        -i "$AWK_ASTRONOMY" \
        -v year="$year" \
        -v lat="$latitude" \
        -v lon="$longitude" \
        -v current="$current_hour" '

    BEGIN{
        pi=atan2(0,-1)
        current += 0
    }

    {
        gsub(/ +/," ")

        day  = $1
        mon  = $2
        year = $3

        split($4,t,":")

        hour = t[1] + 0

        phase = $6 + 0
        age   = $7 + 0
        dist  = $9 + 0

        if(mon=="Jan") month=1
        else if(mon=="Feb") month=2
        else if(mon=="Mar") month=3
        else if(mon=="Apr") month=4
        else if(mon=="May") month=5
        else if(mon=="Jun") month=6
        else if(mon=="Jul") month=7
        else if(mon=="Aug") month=8
        else if(mon=="Sep") month=9
        else if(mon=="Oct") month=10
        else if(mon=="Nov") month=11
        else if(mon=="Dec") month=12

        ra  = $10 + 0
        dec = $11 + 0

        ###################################################################
        # Julian Date (JD)
        ###################################################################
        JD = calc_julian_date(hour,day,month,year)

        ###################################################################
        # Greenwich Mean Sidereal Time (GMST)
        ###################################################################
        GMST = calc_greenwich_mean_sidereal_time(JD)

        ###################################################################
        # Local Sidereal Time (LST)
        ###################################################################
        LST = calc_local_sidereal_time(GMST,lon)

        ###################################################################
        # Hour Angle
        ###################################################################
        H = calc_hour_angle(LST,ra)

        ###################################################################
        # Altitude
        ###################################################################
        altitude[hour] = calc_altitude(lat,dec,H)
    }

    END{

        rise_minutes=0
        set_minutes=0

        if(altitude[current]>=0)
            status="Above horizon"
        else
            status="Below horizon"

        for(i=1;i<24;i++){

            a1=altitude[i-1]
            a2=altitude[i]

            if(a1<0 && a2>=0){

                f=(-a1)/(a2-a1)

                x=(i-1)+f

                hh=int(x)

                mm=int((x-hh)*60+0.5)

                if(mm==60){
                    hh++
                    mm=0
                }

                rise_minutes = hh*60 + mm
            }

            if(a1>=0 && a2<0){

                f=a1/(a1-a2)

                x=(i-1)+f

                hh=int(x)

                mm=int((x-hh)*60+0.5)

                if(mm==60){
                    hh++
                    mm=0
                }

                set_minutes = hh*60 + mm
            }
        }

        printf "%d|%d|%s\n", rise_minutes, set_minutes, status

    }' <<< "$data"
}

# --- This is the end, my friend ------------------------------------------------------------------
