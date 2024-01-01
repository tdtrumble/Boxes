--[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]][][][][][][][]
-- Author = Mordasius
-- Name = SunMoonTimes.lua
-- Version = 300313
-- Information = Script to calculate sun and moon rise and set times based on date, latitude and
--               longitude.
-- License = Creative Commons BY-NC-SA 3.0

-- Functions for sunrise, sunset and twilight were converted from javascript on http://praytimes.org/
-- The parts for moonrise and moonset were converted by Stone from C which came from javascript on
-- http://mysite.verizon.net/res148h4j/javascript/script_moon_rise_set.html
-- (see Stone's post on http://rainmeter.net/forum/viewtopic.php?f=27&t=15071)
--
--[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]][][][][][][][]
--
----------------------------------------------------------------------------------------------------
--
-- Weather Meter by SilverAzide
--
-- This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0
-- International (CC BY-NC-SA 4.0) license.
--
-- Attribution: Sunset-Moonrise (v.2.1) by Mordasius
--                http://fav.me/d5ybxqr
--                https://mordasius.deviantart.com/art/Sunset-Moonrise-v-2-1-359994771
--
-- Attribution: ModernGadgets v1.6.3 by raiguard (as excerpted in SunMoonExample by Mordasius)
--                https://github.com/raiguard/ModernGadgets
--                https://forum.rainmeter.net/viewtopic.php?f=5&t=35896&start=30#p182152
--
-- History:
-- 4.0.0 - 2018-03-17:  Revised Mordasius' Lua script to allow execution on demand for specified
--                      dates and removed skin-specific references.  Minor additional refactoring.
--                      Added code to calculate sun dial angle. NOTE: The sun dial angle calculation
--                      is NOT the same as the real "azimuth"; this calc is just the apparent angle
--                      between sunrise and sunset.
-- 5.1.0 - 2019-07-13:  Corrected Windows/Unix timestamp conversion.  Corrected sunrise/sunset time
--                      display when no sunrise or no sunset.
-- 5.2.0 - 2020-01-19:  Added moon dial angle.
--                      Added function to calculate moon age (wxdata no longer available)
-- 5.3.0 - 2020-02-29:  Corrected moonrise/moonset calculation for case where moon does not rise or
--                      set on the given day.
-- 5.3.1 - 2020-03-04:  Corrected Weather Meter moon dial angle calculation for days when moon does
--                      not rise, set, or sets before rising.
-- 5.4.0 - 2020-05-30:  Corrected sunAngleTime() function for edge case where days having no dawn or
--                      dusk would appear as having no sunrise/sunset.
-- 6.0.0 - 2021-04-06:  Added moon zenith angle (tilt) calculation and illumination percentage
--                      (based on Mordasius' tweak of raiguard's ModernGadgets SunCalc.lua).
--
function Initialize()
  --
  -- this function is called when the script measure is initialized or reloaded
  --
  dawnAngle, duskAngle = 6, 6
  DR = math.pi / 180                                       -- factor to convert degrees to radians
  J2000 = 2451545                                          -- Julian date = Jan 1 2000 12:00 PM
  K1 = 15 * math.pi * 1.0027379 / 180
  synMonth = 29.53058868                                   -- synodic month (days between new moons)

end                                                                           -- function Initialize

function Update()
  --
  -- this function is called when the script measure is updated
  --
  return "success"
end                                                                               -- function Update

----------------------------------------------------------------------------------------------------

function GetSunMoonTimes(nLatitude,
                         nLongitude,
                         nTimeZone,
                         nTimestamp,
                         nShiftTz,
                         nTimeLZero,
                         nTimeStyle,
                         sSunrise,
                         sSunset,
                         sMoonrise,
                         sMoonset,
                         sDayLength,
                         sSunDialAngle,
                         sMoonDialAngle,
                         sMoonAge,
                         sMoonAlphaAngle,
                         sMoonLitPct)
  --
  -- This function returns a timestamp for the sunrise time for a specific location and date.  Can
  -- be called on demand via inline Lua.
  --
  -- Where:  nLatitude       = latitude
  --         nLongitude      = longitude
  --         nTimeZone       = timezone offset for the location of interest (in hours)
  --         nTimestamp      = timestamp for location of interest (Windows timestamp)
  --         nShiftTz        = "true" to shift timestamp to the timezone of the location of interest*
  --         nTimeLZero      = 0 (no leading zeros on hour), 1 (leading zeros on hour)
  --         nTimeStyle      = 0 (12-hour clock), 1 (24-hour clock)
  --         sSunrise        = (optional) name of string meter to display sunrise time
  --         sSunset         = (optional) name of string meter to display sunset time
  --         sMoonrise       = (optional) name of string meter to display moonrise time
  --         sMoonset        = (optional) name of string meter to display moonset time
  --         sDayLength      = (optional) name of string meter to display day length
  --         sSunDialAngle   = (optional) name of variable to hold sun dial angle (in degrees)
  --         sMoonDialAngle  = (optional) name of variable to hold moon dial angle (in degrees)
  --         sMoonAge        = (optional) name of variable to hold moon age (in days)
  --         sMoonAlphaAngle = (optional) name of variable to hold moon zenith angle (in degrees)
  --         sMoonLitPct     = (optional) name of variable to hold moon illumination percentage
  --
  -- NOTE: The "nShiftTz" parameter is used to offset a timestamp from your location to the timezone
  --       of the location of interest, if needed.  This case happens if you use a Time measure to
  --       get your current time, but need to know what that time is in another timezone; e.g.,
  --       if you are in New York (Tz = -5) and need to calculate the current time in Los Angeles
  --       (Tz = -8).  Set this value to "false" if the timestamp is ALREADY converted to the target
  --       timezone.
  --
  local nMoonAge
  local nMoonLitPct
  local nMoonAlphaAngle

  if nLatitude == 0 and nLongitude == 0 then
    -- nothing to do
    return 0
  end

  -- set default values
  sunRiseSetTimes = {6, 6, 6, 12, 13, 18, 18, 18, 24}
  moonRiseSetTimes = {-1, -1}
  NoSunRise, NoSunSet, NoDawn, NoDusk = false, false, false, false
  NoMoonRise, NoMoonSet = false, false
  Sky = {0,0,0}
  Dec = {0,0,0}
  VHz = {0,0,0}
  RAn = {0,0,0}

  -- convert Windows timestamp (0 = 1/1/1601) to Unix/Lua timestamp (0 = 1/1/1970)
  nTimestamp = nTimestamp - 11644473600

  -- debugging
  --nTimestamp = 1577988000     -- = 01/02/2020 18:00 GMT (no moon set this day in Wash DC)
  --nTimestamp = 1581703200     -- = 02/14/2020 18:00 GMT (no moon rise this day in Wash DC)

  -- NOTE:  Lua os.date appears to convert timestamps to dates while adding the timezone offset of
  --        THIS machine.  In cases where you are monitoring weather in a timezone not your own,
  --        the resulting date will be incorrect.  If the current timezone is not the same as the
  --        one coming from the weather.com data, offset the timestamp by the difference.
  local nLocalTz = (getTimeOffset() / 3600)
  if nTimeZone == nLocalTz or not nShiftTz then
    tDate = os.date("!*t", nTimestamp)
  else
    tDate = os.date("!*t", nTimestamp - getTimeOffset() + (nTimeZone * 3600))
  end

  -- debugging
  --print("latitude = "      .. nLatitude)
  --print("longitude = "     .. nLongitude)
  --print("twc timezone = "  .. nTimeZone)
  --print("my timezone = "   .. nLocalTz)
  --print("raw timestamp = " .. nTimestamp)
  --print("timestamp = "     .. os.date("%m/%d/%Y %I:%M:%S %p", os.time(tDate) - (os.date('*t')['isdst'] and 3600 or 0)))

  -- set time and gregorian date
  setDateTime(nLatitude, nLongitude, nTimeZone, tDate)

  -- sun time calculations
  calcSunRiseSet()
  if NoSunRise or NoSunSet then
    -- adjust times to solar noon
    sunRiseSetTimes[2] = (sunRiseSetTimes[2] - 12)           -- sunrise
    if NoSunRise then
      sunRiseSetTimes[3] = sunRiseSetTimes[2] + 0.0001       -- sunset
    else
      sunRiseSetTimes[3] = (sunRiseSetTimes[2] - 0.0001)     -- sunset
    end
    -- adjust times to midnight
    sunRiseSetTimes[1] = 0        -- dawn
    sunRiseSetTimes[4] = 0        -- twilight
  end
  if NoDawn then
    sunRiseSetTimes[1] = 0        -- dawn
  end
  if NoDusk then
    sunRiseSetTimes[4] = 0        -- twilight
  end

  -- moon time calculations
  calcMoonRiseSet(nLatitude, nLongitude, jDateMoon, moonTimeOffset)
  nMoonAge = calcMoonAge(convertToJulian(0, tDate.min, tDate.hour, tDate.day, tDate.month, tDate.year), (nTimeZone / 24))

  -- calculate day length and sun dial angle
  -- NOTE:  Sunrise = 180, solar noon = 90, sunset = 0.
  local nCurrTime = ((tDate.hour * 3600) + (tDate.min * 60)) / 3600         -- current time in hours
  local nDayLength
  local nSunAngle

  if NoSunRise then
    -- sun will not rise today
    nDayLength = 0.0
    nSunAngle = 270
  elseif NoSunSet then
    -- sun will not set today
    nDayLength = 24.0
    nSunAngle = 90
  else
    local nSunRise = sunRiseSetTimes[2]                                     -- sunrise time in hours
    local nSunSet = sunRiseSetTimes[3]                                      -- sunset time in hours

    -- convert fraction of day to fraction of 180 degrees, fix negative values (night time)
    nDayLength = nSunSet - nSunRise
    nSunAngle = (((nSunSet - nCurrTime) / nDayLength) * 180)
    nSunAngle = DMath.fixAngle(nSunAngle)

    -- if southern hemisphere, calculate supplementary angle (so sun will move right to left)
    if nLatitude < 0 then
      if nSunAngle < 180 then
        nSunAngle = 180 - nSunAngle
      else
        nSunAngle = 180 + (360 - nSunAngle)
      end
    end
  end

  -- calculate moon dial angle
  -- NOTE:  Moonrise = 180, moonset = 0.
  local nMoonAngle = 270
  local nMoonRise = moonRiseSetTimes[1]                                    -- moonrise time in hours
  local nMoonSet = moonRiseSetTimes[2]                                     -- moonset time in hours

  if nMoonRise < 0 and nMoonSet < 0 then
    -- moon does not rise or set today
    NoMoonRise = 1
    NoMoonSet = 1

  else
    local nAdjMoonRise = nMoonRise                                -- adjusted moonrise time in hours
    local nAdjMoonSet = nMoonSet                                  -- adjusted moonset time in hours
    moonRiseSetTimes = {-1, -1}

    -- convert fraction of "moontime" to fraction of 180 degrees
    if nMoonRise < 0 then
        -- moon does not rise this day
        NoMoonRise = 1

        -- get previous day's moonrise
        calcMoonRiseSet(nLatitude, nLongitude, jDateMoon - 1, moonTimeOffset)
        nAdjMoonRise = moonRiseSetTimes[1] - 24

    elseif nMoonSet < 0 then
        -- moon does not set this day
        NoMoonSet = 1

        -- get next day's moonset
        calcMoonRiseSet(nLatitude, nLongitude, jDateMoon + 1, moonTimeOffset)
        nAdjMoonSet = moonRiseSetTimes[2] + 24

    elseif nMoonSet < nMoonRise then
      -- moon sets before it rises (i.e., moon rose on previous day)
      if nCurrTime < nMoonSet then
        -- moon has not set yet; get previous day's moonrise
        calcMoonRiseSet(nLatitude, nLongitude, jDateMoon - 1, moonTimeOffset)
        nAdjMoonRise = moonRiseSetTimes[1] - 24
      else
        -- moon has set, and will rise or has risen; get next day's moonset
        calcMoonRiseSet(nLatitude, nLongitude, jDateMoon + 1, moonTimeOffset)
        nAdjMoonSet = moonRiseSetTimes[2] + 24
      end
    else
      -- moon rises and then sets on this day; no adjustments needed
    end

    nMoonAngle = (((nAdjMoonSet - nCurrTime) / (nAdjMoonSet - nAdjMoonRise)) * 180)

    -- fix negative angles
    if nMoonAngle < -180.0 or nMoonAngle > 360.0 then
      nMoonAngle = 270
    else
      nMoonAngle = DMath.fixAngle(nMoonAngle)
    end

    -- if southern hemisphere, calculate supplementary angle (so moon will move right to left)
    if nLatitude < 0 then
      if nMoonAngle < 180 then
        nMoonAngle = 180 - nMoonAngle
      else
        nMoonAngle = 180 + (360 - nMoonAngle)
      end
    end

    -- restore this day's values
    moonRiseSetTimes[1] = nMoonRise
    moonRiseSetTimes[2] = nMoonSet
  end

  -- debugging
  --print("curr time = "  .. TimeString(nCurrTime,           nTimeLZero, nTimeStyle) .. " (" .. nCurrTime           .. ")")
  --print("dawn = "       .. TimeString(sunRiseSetTimes[1],  nTimeLZero, nTimeStyle) .. " (" .. sunRiseSetTimes[1]  .. ")")
  --print("sunrise = "    .. TimeString(sunRiseSetTimes[2],  nTimeLZero, nTimeStyle) .. " (" .. sunRiseSetTimes[2]  .. ")")
  --print("sunset = "     .. TimeString(sunRiseSetTimes[3],  nTimeLZero, nTimeStyle) .. " (" .. sunRiseSetTimes[3]  .. ")")
  --print("twilight = "   .. TimeString(sunRiseSetTimes[4],  nTimeLZero, nTimeStyle) .. " (" .. sunRiseSetTimes[4]  .. ")")
  --print("moonrise = "   .. TimeString(moonRiseSetTimes[1], nTimeLZero, nTimeStyle) .. " (" .. moonRiseSetTimes[1] .. ")")
  --print("moonset = "    .. TimeString(moonRiseSetTimes[2], nTimeLZero, nTimeStyle) .. " (" .. moonRiseSetTimes[2] .. ")")
  --print("day length = " .. TimeString(nDayLength,          0,          1)          .. " (" .. nDayLength          .. ")")
  --print("sun dial = "   .. nSunAngle                                               .. " deg")
  --print("moon dial = "  .. nMoonAngle                                              .. " deg")
  --print("moon age = "   .. string.format("%.2f", nMoonAge)                         .. " days since new moon")

  -- calculate moon view/image angle (tilt of moon as seen at lat/long/time)
  if sMoonAlphaAngle ~= nil or sMoonLitPct ~= nil then
    -- NOTE: jD        = days since J2000 (with time)
    --       jDateMoon = full Julian date (without time)
    --
    local jD = convertToJulian(0, tDate.min, tDate.hour, tDate.day, tDate.month, tDate.year) - (nTimeZone / 24) - J2000
    local moonPosition = getMoonPosition(jD, nLatitude, nLongitude)
    local moonIllumination = getMoonIllumination(jD)

    -- the moon illumination fraction is off by quite a bit, sometimes as much as 1+%; need to find
    -- a better calculation method (illumination angle is close enough as to not be noticeable)
    nMoonLitPct = moonIllumination.fraction * 100

    -- adjust the moon zenith angle (tilt)
    -- NOTE:  alpha = angle of the bright limb relative to a horizontal line
    --        PA    = the position angle of the bright limb (measured eastward from celestial north)
    --        q     = the parallactic angle between the zenith and celestial north
    --        ZOC   = angle of the bright limb relative to the zenith (a vertical line)
    --
    --        alpha = PA - q - 90 = ZOC - 90
    --
    --        Between new and full moon, the moon images are lit from the opposite side, so add 180
    --        degrees to flip the image properly (i.e., to the other side of the zenith line).
    --
    nMoonAlphaAngle = rtd(moonIllumination.angle - moonPosition.parallacticAngle) - 90
    if (moonIllumination.phase < 0.50) then
      nMoonAlphaAngle = nMoonAlphaAngle + 180
    end

    -- debugging
    --print("moon pos azimuth = "           .. string.format("%.4f", rtd(moonPosition.azimuth) + 180)    .. " deg")
    --print("moon pos altitude = "          .. string.format("%.4f", rtd(moonPosition.altitude))         .. " deg")
    --print("moon pos distance = "          .. string.format("%.4f", moonPosition.distance)              .. " km")
    --print("moon pos parallacticAngle = "  .. string.format("%.4f", rtd(moonPosition.parallacticAngle)) .. " deg = " .. string.format("%.4f", moonPosition.parallacticAngle) .. " rad")
    --print("moon illumination fraction = " .. string.format("%.2f", moonIllumination.fraction * 100)    .. "%")
    --print("moon illumination phase = "    .. string.format("%.2f", moonIllumination.phase * 100)       .. "%")
    --print("moon illumination angle = "    .. string.format("%.4f", rtd(moonIllumination.angle))        .. " deg = " .. string.format("%.4f", moonIllumination.angle)        .. " rad")
    --print("moon zenith angle = "          .. string.format("%.4f", nMoonAlphaAngle)                    .. " deg")
  end

  --
  -- save the results to the meters/variables and exit
  --
  if NoSunRise and NoSunSet then
    if sSunrise ~= nil then SKIN:Bang("!SetOption", sSunrise,   "Text", "----") end
    if sSunset  ~= nil then SKIN:Bang("!SetOption", sSunset,    "Text", "----") end
  elseif NoSunRise then
    if sSunrise ~= nil then SKIN:Bang("!SetOption", sSunrise,   "Text", "----") end
    if sSunset  ~= nil then SKIN:Bang("!SetOption", sSunset,    "Text", TimeString(sunRiseSetTimes[3], nTimeLZero, nTimeStyle)) end
  elseif NoSunSet then
    if sSunrise ~= nil then SKIN:Bang("!SetOption", sSunrise,   "Text", TimeString(sunRiseSetTimes[2], nTimeLZero, nTimeStyle)) end
    if sSunset  ~= nil then SKIN:Bang("!SetOption", sSunset,    "Text", "----") end
  else
    if sSunrise ~= nil then SKIN:Bang("!SetOption", sSunrise,   "Text", TimeString(sunRiseSetTimes[2], nTimeLZero, nTimeStyle)) end
    if sSunset  ~= nil then SKIN:Bang("!SetOption", sSunset,    "Text", TimeString(sunRiseSetTimes[3], nTimeLZero, nTimeStyle)) end
  end
  if NoMoonRise and NoMoonSet then
    if sMoonrise  ~= nil then SKIN:Bang("!SetOption", sMoonrise,  "Text", "----") end
    if sMoonset   ~= nil then SKIN:Bang("!SetOption", sMoonset,   "Text", "----") end
  elseif NoMoonRise then
    if sMoonrise  ~= nil then SKIN:Bang("!SetOption", sMoonrise,  "Text", "----") end
    if sMoonset   ~= nil then SKIN:Bang("!SetOption", sMoonset,   "Text", TimeString(moonRiseSetTimes[2], nTimeLZero, nTimeStyle)) end
  elseif NoMoonSet then
    if sMoonrise  ~= nil then SKIN:Bang("!SetOption", sMoonrise,  "Text", TimeString(moonRiseSetTimes[1], nTimeLZero, nTimeStyle)) end
    if sMoonset   ~= nil then SKIN:Bang("!SetOption", sMoonset,   "Text", "----") end
  else
    if sMoonrise  ~= nil then SKIN:Bang("!SetOption", sMoonrise,  "Text", TimeString(moonRiseSetTimes[1], nTimeLZero, nTimeStyle)) end
    if sMoonset   ~= nil then SKIN:Bang("!SetOption", sMoonset,   "Text", TimeString(moonRiseSetTimes[2], nTimeLZero, nTimeStyle)) end
  end
  if sDayLength      ~= nil then SKIN:Bang("!SetOption",   sDayLength,      "Text", TimeString(nDayLength, 0, 1)) end
  if sSunDialAngle   ~= nil then SKIN:Bang("!SetVariable", sSunDialAngle,   string.format("%.2f", nSunAngle)) end
  if sMoonDialAngle  ~= nil then SKIN:Bang("!SetVariable", sMoonDialAngle,  string.format("%.2f", nMoonAngle)) end
  if sMoonAge        ~= nil then SKIN:Bang("!SetVariable", sMoonAge,        math.floor(nMoonAge)) end
  if sMoonAlphaAngle ~= nil then SKIN:Bang("!SetVariable", sMoonAlphaAngle, string.format("%.2f", nMoonAlphaAngle)) end
  if sMoonLitPct     ~= nil then SKIN:Bang("!SetVariable", sMoonLitPct,     string.format("%.1f", nMoonLitPct)) end

  return 1
end                                                                      -- function GetSunMoonTimes

----------------------------------------------------------------------------------------------------

function setDateTime(xlat, ylong, tmzone, today)
  lat = xlat or 0
  long = ylong or 0
  timeOffset = tmzone

  --iTimeNow = ((today.hour * 3600) + (today.min * 60) + today.sec) / 3600
  local Gday = today.day
  local Gmonth = today.month
  local Gyear = today.year

  ----------- for testing ------
  -- Gday = 12
  -- Gmonth = 4
  -- Gyear = 2013

  moonTimeOffset = (-60) * timeOffset
  jDateSun = julian(Gyear, Gmonth, Gday) - (long / (15 * 24))
  jDateMoon =  julian(Gyear, Gmonth, Gday)

end                                                                          -- function setDateTime

------------------------------------ [ sun time calculations ] -------------------------------------

function midDay(Ftime)
  local eqt = sunPosition(jDateSun + Ftime, 0)
  local noon = DMath.fixHour(12 - eqt)
  return noon
end                                                                               -- function midDay

function sunAngleTime(angle, Ftime, direction, isSun)
  --
  -- time at which sun reaches a specific angle below horizon
  --
  -- NOTE: Revised by SilverAzide to add isSun parameter (true if for sunrise/set, false for
  --       dawn/dusk).  Without this the NoSunRise/NoSunSet flags could be tripped on days where
  --       there is a sun rise/set but no dawn/dusk.
  --
  local decl = sunPosition(jDateSun + Ftime, 1)
  local noon = midDay(Ftime)
  local t = (-DMath.Msin(angle) - DMath.Msin(decl) * DMath.Msin(lat)) / (DMath.Mcos(decl) * DMath.Mcos(lat))

  if t > 1 then
    if isSun then
      -- the sun doesn't rise today
      NoSunRise = true
    else
      -- no dawn today
      NoDawn = true
    end
    return noon
  elseif t < -1 then
    if isSun then
      -- the sun doesn't set today
      NoSunSet = true
    else
      -- no dusk today
      NoDusk = true
    end
    return noon
  end

  t = 1 / 15 * DMath.arccos(t)
  return noon + ((direction == "CCW") and -t or t)
end                                                                         -- function sunAngleTime

--function asrTime(factor, Ftime)
--  --
--  -- compute asr time
--  --
--  local decl = sunPosition(jDateSun + Ftime, 1)
--  local angle = -DMath.arccot(factor + DMath.Mtan(math.abs(lat - decl)))
--  return sunAngleTime(angle, Ftime, "ASR")
--end

function sunPosition(jd, Declination)
  --
  -- compute declination angle of sun
  --
  local D = jd - J2000
  local g = DMath.fixAngle(357.529 + 0.98560028 * D)
  local q = DMath.fixAngle(280.459 + 0.98564736 * D)
  local L = DMath.fixAngle(q + 1.915 * DMath.Msin(g) + 0.020 * DMath.Msin(2 * g))
  local R = 1.00014 - 0.01671 * DMath.Mcos(g) - 0.00014 * DMath.Mcos(2 * g)
  local e = 23.439 - 0.00000036 * D
  local RA = DMath.arctan2(DMath.Mcos(e) * DMath.Msin(L), DMath.Mcos(L)) / 15
  local eqt = q / 15 - DMath.fixHour(RA)
  local decl = DMath.arcsin(DMath.Msin(e) * DMath.Msin(L))

  if Declination == 1 then
    return decl
  else
    return eqt
  end
end                                                                          -- function sunPosition

function julian(year, month, day)
  --
  -- convert Gregorian date to Julian day
  --
  -- NOTE:  Unlike the convertToJulian() function below, this one does not include the time.
  --
  if (month <= 2) then
    year = year - 1
    month = month + 12
  end
  local A = math.floor(year/ 100)
  local B = 2 - A + math.floor(A / 4)
  local JD = math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + B - 1524.5
  return JD
end                                                                               -- function julian

function setTimes(sunRiseSetTimes)
  Ftimes = dayPortion(sunRiseSetTimes)
  local dawn    = sunAngleTime(dawnAngle, Ftimes[2], "CCW", false)
  local sunrise = sunAngleTime(riseSetAngle(), Ftimes[3], "CCW", true)
  local sunset  = sunAngleTime(riseSetAngle(), Ftimes[8], "CW", true)
  local dusk    = sunAngleTime(duskAngle, Ftimes[7], "CW", false)
  return {dawn, sunrise, sunset, dusk}
end                                                                             -- function setTimes

function calcSunRiseSet()
  sunRiseSetTimes = setTimes(sunRiseSetTimes)
  return adjustTimes(sunRiseSetTimes)
end                                                                       -- function calcSunRiseSet

function adjustTimes(sunRiseSetTimes)
  for i = 1, #sunRiseSetTimes do
    sunRiseSetTimes[i] = sunRiseSetTimes[i] + (timeOffset - long / 15)
  end
  sunRiseSetTimes = adjustHighLats(sunRiseSetTimes)
  return sunRiseSetTimes
end                                                                          -- function adjustTimes

function riseSetAngle()
  --
  -- sun angle for sunset/sunrise
  --
  -- local angle = 0.0347 * math.sqrt( elv )
  local angle = 0.0347
  return 0.833 + angle
end                                                                         -- function riseSetAngle

function adjustHighLats(sunRiseSetTimes)
  --
  -- adjust times for higher latitudes
  --
  local nightTime = timeDiff(sunRiseSetTimes[3], sunRiseSetTimes[2])
  sunRiseSetTimes[1] = refineHLtimes(sunRiseSetTimes[1], sunRiseSetTimes[2], (dawnAngle), nightTime, "CCW")
  return sunRiseSetTimes
end                                                                       -- function adjustHighLats

function refineHLtimes(Ftime, base, angle, night, direction)
  --
  -- refine time for higher latitudes
  --
  local portion = night / 2
  local FtimeDiff = (direction == "CCW") and timeDiff(Ftime, base) or timeDiff(base, Ftime)

  if not ((Ftime * 2) > 2) or (FtimeDiff > portion) then
    Ftime = base + ((direction == "CCW") and -portion or portion)
  end

  return Ftime
end                                                                        -- function refineHLtimes

function dayPortion(sunRiseSetTimes)
  --
  --  convert hours to day portions
  --
  for i = 1, #sunRiseSetTimes do
    sunRiseSetTimes[i] = sunRiseSetTimes[i] / 24
  end
  return sunRiseSetTimes
end                                                                           -- function dayPortion

function timeDiff(time1, time2)
  --
  --  difference between two times
  --
  return DMath.fixHour(time2 - time1)
end                                                                             -- function timeDiff

------------------------------------ [ moon time calculations ] ------------------------------------

function sgn(x)
  --
  -- returns value for sign of argument
  --
  local rv

  if x > 0 then
    rv = 1
  else
    if x < 0 then
      rv = -1
    else
      rv = 0
    end
  end

  return rv
end                                                                               -- function sgn(x)

function moon(jd)
  --
  -- moon's position using fundamental arguments (Van Flandern & Pulkkinen, 1979)
  --
  local d, f, g, h, m, n, s, u, v, w

  h = 0.606434 + 0.03660110129 * jd
  m = 0.374897 + 0.03629164709 * jd
  f = 0.259091 + 0.0367481952 * jd
  d = 0.827362 + 0.03386319198 * jd
  n = 0.347343 - 0.00014709391 * jd
  g = 0.993126 + 0.0027377785 * jd

  h = h - math.floor(h)
  m = m - math.floor(m)
  f = f - math.floor(f)
  d = d - math.floor(d)
  n = n - math.floor(n)
  g = g - math.floor(g)

  h = h * 2 * math.pi
  m = m * 2 * math.pi
  f = f * 2 * math.pi
  d = d * 2 * math.pi
  n = n * 2 * math.pi
  g = g * 2 * math.pi

  v = 0.39558 * math.sin(f + n)
  v = v + 0.082 * math.sin(f)
  v = v + 0.03257 * math.sin(m - f - n)
  v = v + 0.01092 * math.sin(m + f + n)
  v = v + 0.00666 * math.sin(m - f)
  v = v - 0.00644 * math.sin(m + f - 2 * d + n)
  v = v - 0.00331 * math.sin(f - 2 * d + n)
  v = v - 0.00304 * math.sin(f - 2 * d)
  v = v - 0.0024 * math.sin(m - f - 2 * d - n)
  v = v + 0.00226 * math.sin(m + f)
  v = v - 0.00108 * math.sin(m + f - 2 * d)
  v = v - 0.00079 * math.sin(f - n)
  v = v + 0.00078 * math.sin(f + 2 * d + n)

  u = 1 - 0.10828 * math.cos(m)
  u = u - 0.0188 * math.cos(m - 2 * d)
  u = u - 0.01479 * math.cos(2 * d)
  u = u + 0.00181 * math.cos(2 * m - 2 * d)
  u = u - 0.00147 * math.cos(2 * m)
  u = u - 0.00105 * math.cos(2 * d - g)
  u = u - 0.00075 * math.cos(m - 2 * d + g)

  w = 0.10478 * math.sin(m)
  w = w - 0.04105 * math.sin(2 * f + 2 * n)
  w = w - 0.0213 * math.sin(m - 2 * d)
  w = w - 0.01779 * math.sin(2 * f + n)
  w = w + 0.01774 * math.sin(n)
  w = w + 0.00987 * math.sin(2 * d)
  w = w - 0.00338 * math.sin(m - 2 * f - 2 * n)
  w = w - 0.00309 * math.sin(g)
  w = w - 0.0019 * math.sin(2 * f)
  w = w - 0.00144 * math.sin(m + n)
  w = w - 0.00144 * math.sin(m - 2 * f - n)
  w = w - 0.00113 * math.sin(m + 2 * f + 2 * n)
  w = w - 0.00094 * math.sin(m - 2 * d + g)
  w = w - 0.00092 * math.sin(2 * m - 2 * d)

  s = w / math.sqrt(u - v * v)                                 -- compute moon's right ascension ...
  Sky[1] = h + math.atan(s / math.sqrt(1 - s * s))

  s = v / math.sqrt(u)                                         -- declination ...
  Sky[2] = math.atan(s / math.sqrt(1 - s * s))

  Sky[3] = 60.40974 * math.sqrt(u)                             -- and parallax

end                                                                                 -- function moon

function test_moon(k, t0, lat, plx)
  --
  -- test an hour for an event
  --
  ha = {0,0,0}
  local a, b, c, d, e, s, z
  local hr, _min, _time
  local az, hz, nz, dz

  if (RAn[3] < RAn[1]) then
    RAn[3] = RAn[3] + 2 * math.pi
  end

  ha[1] = t0 - RAn[1] + (k * K1)
  ha[3] = t0 - RAn[3] + (k * K1) + K1
  ha[2] = (ha[3] + ha[1]) / 2                                            -- hour angle at half hour
  Dec[2] = (Dec[3] + Dec[1]) / 2                                         -- declination at half hour
  s = math.sin(DR * lat)
  c = math.cos(DR * lat)

  -- refraction + sun semidiameter at horizon + parallax correction
  z = math.cos(DR * (90.567 - 41.685 / plx))

  if (k <= 0) then
    -- first call of function
    VHz[1] = s * math.sin(Dec[1]) + c * math.cos(Dec[1]) * math.cos(ha[1]) - z
  end
  VHz[3] = s * math.sin(Dec[3]) + c * math.cos(Dec[3]) * math.cos(ha[3]) - z
  if (sgn(VHz[1]) == sgn(VHz[3])) then
    -- no event this hour
    return VHz[3]
  end
  VHz[2] = s * math.sin(Dec[2]) + c * math.cos(Dec[2]) * math.cos(ha[2]) - z
  a = 2 * VHz[3] - 4 * VHz[2] + 2 * VHz[1]
  b = 4 * VHz[2] - 3 * VHz[1] - VHz[3]
  d = b * b - 4 * a * VHz[1]

  if (d < 0) then
    -- no event this hour
    return VHz[3]
  end

  d = math.sqrt(d)
  e = (-b + d) / (2 * a)
  if ((e > 1) or (e < 0)) then
    e = (-b - d) / (2 * a)
  end
  _time = k + e + 1 / 120                                             -- time of an event + round up

  if ((VHz[1] < 0) and (VHz[3] > 0)) then
    moonRiseSetTimes[1] = _time
  end

  if ((VHz[1] > 0) and (VHz[3] < 0)) then
    moonRiseSetTimes[2] = _time
  end

  return VHz[3]
end                                                                             -- function testmoon

function lst(lon, jd, z)
  --
  -- Local Sidereal Time for zone
  --
  local s = 24110.5 + 8640184.812999999 * jd / 36525 + 86636.6 * z + 86400 * lon
  s = s / 86400
  s = s - math.floor(s)

  return s * 360 * DR
end                                                                                  -- function lst

function interpolate(f0, f1, f2, p)
  --
  -- 3-point interpolation
  --
  local a = f1 - f0
  local b = f2 - f1 - a
  local f = f0 + p * (2 * a + b * (2 * p - 1))

  return f
end                                                                          -- function interpolate

function calcMoonRiseSet(lat, lon, jDateMoon, moonTimeOffset)
  --
  -- calculate moonrise and moonset times
  --
  local i, j, k
  local zone = moonTimeOffset / 60
  local ph
  local jd = jDateMoon - J2000                         -- Julian day relative to Jan 1 2000 12:00 PM
  local mp = {}
  local lon_local = lon

  for i = 1,3 do
    mp[i] = {}
    for j = 1,3 do
      mp[i][j] = 0
    end
  end

  lon_local = lon / 360
  tz = zone / 24
  t0 = lst(lon_local, jd, tz)                                   -- local sidereal time
  jd = jd + tz                                                  -- get moon position at start of day
  for k = 1,3 do
    moon(jd)
    mp[k][1] = Sky[1]
    mp[k][2] = Sky[2]
    mp[k][3] = Sky[3]
    jd = jd + 0.5
  end

  if (mp[2][1] <= mp[1][1]) then
    mp[2][1] = mp[2][1] + 2 * math.pi
  end
  if (mp[3][1] <= mp[2][1]) then
    mp[3][1] = mp[3][1] + 2 * math.pi
  end
  RAn[1] = mp[1][1]
  Dec[1] = mp[1][2]

  -- check each hour of this day
  for k = 0,23 do
    ph = (k + 1) / 24
    RAn[3] = interpolate(mp[1][1], mp[2][1], mp[3][1], ph)
    Dec[3] = interpolate(mp[1][2], mp[2][2], mp[3][2], ph)
    VHz[3] = test_moon(k, t0, lat, mp[2][3])
    RAn[1] = RAn[3] -- advance to next hour
    Dec[1] = Dec[3]
    VHz[1] = VHz[3]
  end
end                                                                      -- function calcMoonRiseSet

function calcMoonAge(jDateMoon, moonTimeOffset)
  --
  -- calculates the age of the moon in days (days since last new moon)
  --
  -- where:  jDateMoon      = current julian date
  --         moonTimeOffset = timezone offset in minutes
  --
  -- 2451549.5  = 1/6/2000 at 12:24:01, the moon was New
  -- 29.5305882 = new moon every 29.5305882 days
  -- 1440       = minutes in a day, to convert offset into days
  --
  -- by SilverAzide
  --   Source: https://www.subsystems.us/uploads/9/8/9/4/98948044/moonphase.pdf
  --           http://www.calculatorcat.com/moon_phases/moon_phases.phtml
  --
  local daysSinceNew = jDateMoon + (moonTimeOffset / 1440) - 2451549.5
  local countNewMoons = daysSinceNew / 29.5305882

  -- multiply fractional part by 29.5305882 to get days into current cycle
  local moonAge = (countNewMoons - math.floor(countNewMoons)) * 29.5305882
  return moonAge
end                                                                          -- function calcMoonAge

----------------------------------------------------------------------------------------------------
------------------------------------- [ other odds and sods ] --------------------------------------

function getTimeOffset()
  return (os.time() - os.time(os.date('!*t')) + (os.date('*t')['isdst'] and 3600 or 0))
end

function twoDigitsFormat(num)
  --
  -- add a leading 0
  --
  if (num < 10) then
    return "0" .. tostring(num)
  else
    return tostring(num)
  end
end                                                                      -- function twoDigitsFormat

function TimeString(Ftime,
                    nTimeLZero,
                    nTimeStyle)
  --
  -- put time in string format
  --
  -- Where:  Ftime      = floating point time (hours with fractional minutes)
  --         nTimeLZero = 0 (no leading zeros on hour), 1 (leading zeros on hour)
  --         nTimeStyle = 0 (12-hour clock), 1 (24-hour clock)
  --
  local hours = math.floor(Ftime)
  local minutes = math.floor((Ftime - hours) * 60)

  if nTimeStyle == 0 then
    -- 12-hour clock
    if hours > 11 and hours < 24 then
      AmPm = ' PM'
    else
      AmPm = ' AM'
    end

    -- convert 24-hour time to 12-hour time
    if hours >= 0 then
      hours = ((hours + 12 - 1) % 12 + 1)
    end

    if nTimeLZero == 0 then
      -- no leading zeros
      return hours .. ":" .. twoDigitsFormat(minutes) .. AmPm
    else
      -- leading zeros
      return twoDigitsFormat(hours) .. ":" .. twoDigitsFormat(minutes) .. AmPm
    end

  else
    -- 24-hour clock
    if nTimeLZero == 0 then
      -- no leading zeros
      return hours .. ":" .. twoDigitsFormat(minutes)
    else
      -- leading zeros
      return twoDigitsFormat(hours) .. ":" .. twoDigitsFormat(minutes)
    end
  end

end                                                                           -- function TimeString

---------------------------------------- [ math functions ] ----------------------------------------

function fix(a, b)
  a = a - b * (math.floor(a / b))
  return (a < 0) and a + b or a
end

--function round(x)
--  -- round "away-from-zero"
--  return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
--end

--function roundTo(num, numDecimalPlaces)
--  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
--end

-- degrees to radians
function dtr(d) return (d * math.pi) / 180 end

-- radians to degrees
function rtd(r) return (r * 180) / math.pi end

DMath = {
  Msin = function(d) return math.sin(dtr(d)) end,
  Mcos = function(d) return math.cos(dtr(d)) end,
  Mtan = function(d) return math.tan(dtr(d)) end,
  arcsin = function(d) return rtd(math.asin(d)) end,
  arccos = function(d) return rtd(math.acos(d)) end,
  arctan = function(d) return rtd(math.atan(d)) end,
  arccot = function(x) return rtd(math.atan(1/x)) end,
  arctan2 =  function(y, x) return rtd(math.atan2(y, x)) end,
  fixAngle = function(a) return fix(a, 360) end,
  fixHour =  function(a) return fix(a, 24 ) end
}

----------------------------------------------------------------------------------------------------
-- extracted by Mordasius from SunCalc.lua from ModernGadgets by raiguard
----------------------------------------------------------------------------------------------------

--  sun calculations based on http://aa.quae.nl/en/reken/zonpositie.html
--  general calculations for position

e = (math.pi / 180) * 23.4397 -- obliquity of the Earth
function altitude(H, phi, dec) return math.asin(math.sin(phi) * math.sin(dec) + math.cos(phi) * math.cos(dec) * math.cos(H)); end
function azimuth(H, phi, dec)  return math.atan2(math.sin(H), math.cos(H) * math.sin(phi) - math.tan(dec) * math.cos(phi)); end
function declination(l, b)     return math.asin(math.sin(b) * math.cos(e) + math.cos(b) * math.sin(e) * math.sin(l)); end
function rightAscension(l, b)  return math.atan2(math.sin(l) * math.cos(e) - math.tan(b) * math.sin(e), math.cos(l)); end
function siderealTime(d, lw)   return DR * (280.16 + 360.9856235 * d) - lw; end

function astroRefraction(h)
  -- the following formula works for positive altitudes only.
  if (h < 0) then
    h = 0                                                  -- if h = -0.08901179 a div/0 would occur
  end

  -- formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  -- 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
  return 0.0002967 / math.tan(h + 0.00312536 / (h + 0.08901179))
end                                                                      -- function astroRefraction

-- general sun calculations
function solarMeanAnomaly(d)
  return DR * (357.5291 + 0.98560028 * d)
end                                                                     -- function solarMeanAnomaly

function eclipticLongitude(M)
  local C = DR * (1.9148 * math.sin(M) + 0.02 * math.sin(2 * M) + 0.0003 * math.sin(3 * M))  -- equation of center
  local P = DR * 102.9372                                                                    -- perihelion of the Earth

  return M + C + P + math.pi
end                                                                    -- function eclipticLongitude

function sunCoords(d)
  local M = solarMeanAnomaly(d)
  local L = eclipticLongitude(M)

  return {
    dec = declination(L, 0),
    ra = rightAscension(L, 0)
  }
end                                                                            -- function sunCoords

--
-- moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas
--
function moonCoords(d)
  --
  -- geocentric ecliptic coordinates of the moon
  --
  -- where: d = julian date
  --
  local L = DR * (218.316 + 13.176396 * d)   -- ecliptic longitude
  local M = DR * (134.963 + 13.064993 * d)   -- mean anomaly
  local F = DR * (93.272 + 13.229350 * d)    -- mean distance
  local l  = L + DR * 6.289 * math.sin(M)    -- longitude
  local b  = DR * 5.128 * math.sin(F)        -- latitude
  local dt = 385001 - 20905 * math.cos(M)    -- distance to the moon in km

  return {
    ra = rightAscension(l, b),
    dec = declination(l, b),
    dist = dt
  }
end                                                                           -- function moonCoords

function getMoonPosition(d2, lat, lng)
  --
  -- where:  d2   = julian date
  --         lat  = latitude
  --         long = longitude
  --
  local lw  = DR * -lng
  local phi = DR * lat
  local c = moonCoords(d2)
  local H = siderealTime(d2, lw) - c.ra
  local h = altitude(H, phi, c.dec)

  -- formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  local pa = math.atan2(math.sin(H), math.tan(phi) * math.cos(c.dec) - math.sin(c.dec) * math.cos(H))
  h = h + astroRefraction(h)                                   -- altitude correction for refraction

  return {
    azimuth = azimuth(H, phi, c.dec),
    altitude = h,
    distance = c.dist,
    parallacticAngle = pa
  }
end                                                                      -- function getMoonPosition

function getMoonIllumination(d2)
  --
  -- calculations for illumination parameters of the moon,
  -- based on http://idlastro.gsfc.nasa.gov/ftp/pro/astro/mphase.pro formulas and
  -- Chapter 48 of "Astronomical Algorithms"
  -- 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  --
  local s = sunCoords(d2)
  local m = moonCoords(d2)
  local sdist = 149598000                                        -- distance from Earth to Sun in km

  -- phi = geocentric elongation of the Moon from the Sun
  -- inc = selenocentric (moon-centered) elongation of the Earth from the Sun
  local phi = math.acos(math.sin(s.dec) * math.sin(m.dec) + math.cos(s.dec) * math.cos(m.dec) * math.cos(s.ra - m.ra))
  local inc = math.atan2(sdist * math.sin(phi), m.dist - sdist * math.cos(phi))
  local angle = math.atan2(math.cos(s.dec) * math.sin(s.ra - m.ra), math.sin(s.dec) * math.cos(m.dec) - math.cos(s.dec) * math.sin(m.dec) * math.cos(s.ra - m.ra))

  return {
    fraction = ((1 + math.cos(inc)) / 2),
    phase = 0.5 + 0.5 * inc * (angle < 0 and -1 or 1) / math.pi,
    angle = angle
  }
end                                                                  -- function getMoonIllumination

function getMeanPhase(jDate, K)
  --
  -- calculates time of the mean new moon for a given base date
  --
  -- where:  jDate = base Julian date
  --         K     = the precomputed synodic month index, given by:
  --                   K = (Year - 1900) * 12.3685
  --                   where Year is expressed as a year and fractional year
  --
  -- NOTE:  The "mean phase" is based on the "mean lunar month" or "synodic month"; however, the
  --        moon's orbit is not circular, so the mean is not precise because the length of the lunar
  --        month changes.  The "true phase" calculates the precise phase for the particular date.
  --
  local t
  local t2
  local t3
  local nt1

  -- get time in Julian centuries from 1900 January 0.5
  t = (jDate - 2415020) / 36525
  t2 = t * t                                                              -- square for frequent use
  t3 = t2 * t                                                             -- cube for frequent use
  nt1 = 2415020.75933 + synMonth * K + 0.0001178 * t2 - 0.000000155 * t3 + 0.00033 * DMath.Msin(166.56 + 132.87 * t - 0.009173 * t2)

  return nt1
end

function getTruePhase(K, phaseSelector)
  --
  -- calculates the true, corrected phase time
  --
  -- where:  K             = the K value used to determine the mean phase of the new moon
  --         phaseSelector = the phase selector (0.0 = new, 0.25 = first quarter, 0.5 = full,
  --                         0.75 = third quarter)
  --
  local f
  local m
  local mPrime
  local phaseTrue
  local t
  local t2
  local t3

  K = K + phaseSelector                            -- add phase to new moon time
  t = K / 1236.85                                  -- time in Julian centuries from 1900 January 0.5
  t2 = t * t                                       -- square for frequent use
  t3 = t2 * t                                      -- cube for frequent use

  -- mean time of phase
  phaseTrue = 2415020.75933 + synMonth * K + 0.0001178 * t2 - 0.000000155 * t3  + 0.00033 * DMath.Msin(166.56 + 132.87 * t - 0.009173 * t2)
  m = 359.2242 + 29.10535608 * K - 0.0000333 * t2 - 0.00000347 * t3          -- sun's mean anomaly
  mPrime = 306.0253 + 385.81691806 * K + 0.0107306 * t2 + 0.00001236 * t3    -- moon's mean anomaly
  f = 21.2964 + 390.67050646 * K - 0.0016528 * t2 - 0.00000239 * t3          -- moon's argument of latitude

  if ((phaseSelector < 0.01) or (math.abs(phaseSelector - 0.5) < 0.01)) then
    -- corrections for new and full moon
    phaseTrue = phaseTrue + (0.1734 - 0.000393 * t) * DMath.Msin(m)+ 0.0021 * DMath.Msin(2 * m)- 0.4068 * DMath.Msin(mPrime) + 0.0161 * DMath.Msin(2 * mPrime) - 0.0004 * DMath.Msin(3 * mPrime) + 0.0104 * DMath.Msin(2 * f) - 0.0051 * DMath.Msin(m + mPrime) - 0.0074 * DMath.Msin(m - mPrime) + 0.0004 * DMath.Msin(2 * f + m) - 0.0004 * DMath.Msin(2 * f - m) - 0.0006 * DMath.Msin(2 * f + mPrime) + 0.0010 * DMath.Msin(2 * f - mPrime)+ 0.0005 * DMath.Msin(m + 2 * mPrime)
  else
    if ((math.abs(phaseSelector - 0.25) < 0.01 or (math.abs(phaseSelector - 0.75) < 0.01))) then
      phaseTrue = phaseTrue + (0.1721 - 0.0004 * t) * DMath.Msin(m) + 0.0021 * DMath.Msin(2 * m) - 0.6280 * DMath.Msin(mPrime) + 0.0089 * DMath.Msin(2 * mPrime) - 0.0004 * DMath.Msin(3 * mPrime) + 0.0079 * DMath.Msin(2 * f) - 0.0119 * DMath.Msin(m + mPrime) - 0.0047 * DMath.Msin(m - mPrime) + 0.0003 * DMath.Msin(2 * f + m) - 0.0004 * DMath.Msin(2 * f - m) - 0.0006 * DMath.Msin(2 * f + mPrime) + 0.0021 * DMath.Msin(2 * f - mPrime) + 0.0003 * DMath.Msin(m + 2 * mPrime) + 0.0004 * DMath.Msin(m - 2 * mPrime) - 0.0003 * DMath.Msin(2 * m + mPrime)
      if (phaseSelector < 0.5) then
        -- first quarter correction
        phaseTrue = phaseTrue + 0.0028 - 0.0004 * DMath.Mcos(m) + 0.0003 * DMath.Mcos(mPrime)
      else
        -- last quarter correction
        phaseTrue = phaseTrue - 0.0028 + 0.0004 * DMath.Mcos(m) - 0.0003 * DMath.Mcos(mPrime)
      end
    end
  end

  return phaseTrue
end

function convertToJulian(second, minute, hour, day, month, year)
  --
  -- determine Julian day from calendar date and time
  -- (Jean Meeus, "Astronomical Algorithms", Willmann-Bell, 1991)
  --
  local a, b, gregorian

  if year < 1583 then
    gregorian = 0
  else
    gregorian = 1
  end

  if ((month == 1) or (month == 2)) then
    year = year - 1
    month = month + 12
  end

  a = math.floor(year / 100)
  if gregorian == 1 then
    b = 2 - a + math.floor(a / 4)
  else
    b = 0
  end

  return math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + b - 1524.5 + ((second + 60 * (minute + 60 * hour)) / 86400)
end                                                                      -- function convertToJulian

function convertToGregorian(jDate)
  --
  -- convert Julian date to Gregorian date
  --
  local a
  local b
  local c
  local d
  local e
  local f
  local z
  local dd
  local mm
  local yy
  local hh
  local mi
  local ss

  jDate = jDate + 0.5
  z = math.floor(jDate)
  f = jDate - z
  if (z < 2299161)  then
    a = z
  else
    local alpha = math.floor((z - 1867216.25) / 36524.25)
    a = z + 1 + alpha - math.floor(alpha / 4)
  end
  b = a + 1524
  c = math.floor((b - 122.1) / 365.25)
  d = math.floor(365.25 * c)
  e = math.floor((b - d) / 30.6001)

  -- day
  dd = (b - d - math.floor(30.6001 * e) + f)
  
  -- hour
  hh = (dd - math.floor(dd)) * 24
  
  -- minute
  mi = (hh - math.floor(hh)) * 60
  
  -- seconds
  ss = (mi - math.floor(mi)) * 60
  
  -- month
  if e < 14 then
    mm = e - 1
  else
    mm = e - 13
  end

  -- year
  if mm > 2 then
    yy = c - 4716
  else
    yy = c - 4715
  end

  return {
    year = yy,
    month = mm,
    day = math.floor(dd),
    hour = math.floor(hh),
    min = math.floor(mi),
    sec = math.floor(ss + 0.50)
  }
end                                                                   -- function convertToGregorian
