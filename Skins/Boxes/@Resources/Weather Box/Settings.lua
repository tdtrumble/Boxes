--
-- Settings by SilverAzide
--
-- This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0
-- International (CC BY-NC-SA 4.0) license.
--
-- History:
-- 6.0.0 - 2021-04-06:  Initial release.
-- 6.1.0 - 2021-05-14:  Corrected string.rpad function, revised ParseHWiNFORegOutput for very long sensor names.
--                      Reverted dynamic settings enhancement added in 6.0.0 due to performance issues.
-- 7.4.0 - 2022-09-23:  Revised to allow refreshing config group to be optional.
--
function Initialize()
  --
  -- this function is called when the script measure is initialized or reloaded
  --
  sVarPath = SELF:GetOption('VariablesFile')
  sConfigGroup = SELF:GetOption('ConfigGroupName')
  sCpConfig = SELF:GetOption('ColorPickerConfig')
  sCpVarPath = SELF:GetOption('ColorPickerVariablesFile')

  return
end                                                                                    -- Initialize

function Update()
  --
  -- this function is called when the script measure is updated
  --
  return "success"
end                                                                                        -- Update

function PickColor(sVarName)
  --
  -- invokes ColorPickerPlus
  --
  -- where: sVarName = variable name (ex: "PaletteColor1")
  --
  -- example:
  --   [!CommandMeasure SettingsScript "PickColor('PaletteColor1')"]
  --

  -- configure color picker
  SKIN:Bang('!WriteKeyValue', 'Variables', 'BgAlpha', SKIN:GetVariable('BgAlpha'), sCpVarPath)
  SKIN:Bang('!WriteKeyValue', 'Variables', 'BgStyle', SKIN:GetVariable('BgStyle'), sCpVarPath)
  SKIN:Bang('!WriteKeyValue', 'Variables', 'baseColor', SKIN:GetVariable(sVarName), sCpVarPath)
  SKIN:Bang('!WriteKeyValue', 'Variables', 'targetConfigGroup', sConfigGroup, sCpVarPath)
  SKIN:Bang('!WriteKeyValue', 'Variables', 'targetVariable', sVarName, sCpVarPath)
  SKIN:Bang('!WriteKeyValue', 'Variables', 'targetVariablesFile', sVarPath, sCpVarPath)

  local sBaseActions = '[!WriteKeyValue Variables #targetVariable# "[&MeasureScript:GetColor(\'cur_rgb\')]\" \"#targetVariablesFile#"]'
  SKIN:Bang('!WriteKeyValue', 'Variables', 'finishAction', sBaseActions .. '[!RefreshGroup #targetConfigGroup#][!DeactivateConfig]', sCpVarPath)

  -- activate color picker
  SKIN:Bang('!ActivateConfig', sCpConfig)
end                                                                                     -- PickColor

function SetVariable(sVarName, sVarValue)
  --
  -- this function sets a variable and updates or refreshes all skins in the config group
  --
  -- where: sVarName  = variable name (ex: "PaletteColor1")
  --        sVarValue = variable value (ex: "255,255,255")
  --
  -- example:
  --   [!CommandMeasure LuaScript "SetVariable('PaletteColor1', '255,255,255')"]
  --

  -- write the variable to the variables file
  SKIN:Bang('!WriteKeyValue', 'Variables', sVarName, sVarValue, sVarPath)

  -- refresh all skins in the config group
  if sConfigGroup ~= nil then SKIN:Bang('!RefreshGroup', sConfigGroup) end

  return
end                                                                                   -- SetVariable

function SetVariables(...)
  --
  -- this function sets a list of variables and updates or refreshes all skins in the config group
  --
  -- where: ... = a list of one or more tables containing key-value pairs
  --
  -- example:
  --   [!CommandMeasure LuaScript "SetVariables({'PaletteColor1', '255,255,255'}, {'PaletteColor2', '255,255,255'})"]
  --
  local sVarName
  local sVarValue
  
  -- if variables file does not exist, return without making any changes
  local oFile = io.open(sVarPath, 'r')
  if oFile == nil then return end
  oFile:close()

  -- process function parameters (each argument is a 2-element table of key-value pairs)
  for i = 1, #arg do
    sVarName = arg[i][1]
    sVarValue = arg[i][2]

    -- write the variable to the variables file
    SKIN:Bang('!WriteKeyValue', 'Variables', sVarName, sVarValue, sVarPath)
  end

  -- refresh all skins in the config group
  if sConfigGroup ~= '' then SKIN:Bang('!RefreshGroup', sConfigGroup) end

  return
end                                                                                  -- SetVariables

function JoinDaysOfTheWeekString(sAlarmID,
                                 iDisableSun,
                                 iDisableMon,
                                 iDisableTue,
                                 iDisableWed,
                                 iDisableThu,
                                 iDisableFri,
                                 iDisableSat)
  --
  -- this functions joins boolean values indicating whether the day is used/not used into a pipe-
  -- delimited string of days (i.e., "Mon|Wed|Fri") and stores the result into the skin variables
  --
  -- where:  sAlarmID                  = alarm ID, used as part of variable name
  --         iDisableSun - iDisableSat = seven boolean (0/1) values
  --
  local aValues = {iDisableSun, iDisableMon, iDisableTue, iDisableWed, iDisableThu, iDisableFri, iDisableSat}
  local aDays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
  local aResult = {}
  local iIsDisabled

  for i,sDay in ipairs(aDays) do
    iIsDisabled = tonumber(aValues[i])

    -- if not disabled (disabled = 1), append the day to the result array
    if iIsDisabled == 0 then
      table.insert(aResult, sDay)
    end
  end

  -- save the alarm days string
  SKIN:Bang('!WriteKeyValue', 'Variables', 'Alarm' .. sAlarmID .. 'Days', table.concat(aResult, '|'), sVarPath)

  -- refresh all skins in the config group
  if sConfigGroup ~= '' then SKIN:Bang('!RefreshGroup', sConfigGroup) end

  return
end

function SplitDaysOfTheWeekString(sAlarmID,
                                  sDaysOfTheWeek)
  --
  -- this function splits a pipe-delimited string representing the days of the week (i.e.,
  -- "Mon|Wed|Fri") into boolean values and stores each result into designated variables
  --
  -- where:  sAlarmID       = alarm ID, used as part of variable name
  --         sDaysOfTheWeek = a pip-delimited string representing zero or more days of the week
  --
  -- NOTE: The days of the week string must contain zero to seven days in 3-letter abbreviated US
  --       format, separated by any delimiter character. Days can be in any order.
  --
  --       Examples:  "Sun|Mon|Tue|Wed|Thu|Fri|Sat" = all 7 days represented
  --                  "Mon|Wed|Fri"                 = Monday, Wednesday, Friday only
  --
  local iPos
  local iValue
  local aDays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

  for i,sDay in ipairs(aDays) do
    iPos = string.find(sDaysOfTheWeek, sDay)
    if iPos == nil then
      iValue = 1
    else
      iValue = 0
    end

    -- save the value to the day variable (for this skin only)
    SKIN:Bang('!SetVariable', 'Alarm' .. sAlarmID .. 'DayDisable' .. sDay, iValue)
  end

  -- update all meters (for this skin only)
  SKIN:Bang('!UpdateMeter', '*')

  -- redraw all meters (for this skin only)
  SKIN:Bang('!Redraw')

  return
end

function SetAlarmDefaults(sAlarmID)
  --
  -- this function sets an alarm to default values
  --
  -- where:  sAlarmID = alarm ID, used as part of variable name
  --
  -- example:
  --   [!CommandMeasure LuaScript "SetAlarmDefaults('1')"]
  --
  local aDays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

  -- save the alarm days string
  SKIN:Bang('!WriteKeyValue', 'Variables', 'Alarm' .. sAlarmID .. 'Days', table.concat(aDays, '|'), sVarPath)

  -- refresh all skins in the config group
  if sConfigGroup ~= '' then SKIN:Bang('!RefreshGroup', sConfigGroup) end

  return
end

function ParseHWiNFORegOutputHtml(sMeasureName)
  --
  -- This function parses HWiNFO registry info and displays it in a browser.
  -- Based on code provided by raiguard and jsmorley.
  --
  local raw = SKIN:GetMeasure(sMeasureName):GetStringValue()
  local fileName = SKIN:GetVariable('@') .. 'output.html'

  -- create document header
  local output =
  [[<!DOCTYPE HTML>
  <html lang="en-US">
  <head>
  <title>HWiNFO Registry Reader</title>
  <meta http-equiv="content-type" content="text/html;charset=utf-8" />
  <style>
  body {
    font-family: Sans-serif;
    font-size: 100%;
    font-color: #2F2F2F;
    background-color: #E1E3E6;
  }
  td {
    padding: 5px;
  }
  th {
    background-color: #F7BC81;
    color: #2F2F2F;
    padding: 10px 0px 10px 0px;
  }
  table {
    table-layout: fixed;
    width: 100%;
    background-color: #FAFAFA;
    box-shadow: 0 0 15px 3px #9E9E9E;
  }
  table, th, td {
    border-style: solid;
    border-width: 1px;
    border-color: #2F2F2F;
    border-collapse: collapse;
    word-wrap: break-word;
  }
  div {
    width: 95%;
    position: absolute;
    top:0;
    bottom: 0;
    left: 0;
    right: 0;
    margin: auto;
  }
  </style>
  </head>
  <body>
  <div>
  <br>
  <table>
  <tr>
  <th style="width: 5%;">Index</th>
  <th style="width: 25%;">Sensor</th>
  <th style="width: 25%;">Label</th>
  <th style="width: 10%;">Value</th>
  <th style="width: 10%;">ValueRaw</th>
  </tr>]]

  -- match over each group as a whole
  local match_string = '    Sensor(%d-)    .-    (.-)\n    .-    .-    (.-)\n    .-    .-    (.-)\n    .-    .-    (.-)\n'
  for index, sensor, label, value, value_raw in raw:gmatch(match_string) do
    output = output
      .. '<tr><td style="width: 5%;">' .. index     .. '</td>'
      .. '<td style="width: 25%;">'    .. sensor    .. '</td>'
      .. '<td style="width: 25%;">'    .. label     .. '</td>'
      .. '<td style="width: 10%;">'    .. value     .. '</td>'
      .. '<td style="width: 10%;">'    .. value_raw .. '</td></tr>\n'
  end

  -- create document footer
  output = output .. '</table><br></div></body></html>'

  -- write to the file
  local file = io.open(fileName, 'w')
  file:write(output)
  file:close()

  -- open the page in the browser
  SKIN:Bang('"' .. fileName .. '"')

  return
end                                                                      -- ParseHWiNFORegOutputHtml

-- Right-pads string 'str' to length 'len' with character 'char' (default = space)
string.rpad = function(str, len, char)
  if char == nil then char = ' ' end
  return str .. string.rep(char, len - #str)
end

-- Extended string.rpad; truncates string and adds an ellipsis if needed
string.rpadex = function(str, len, char)
  if #str > len then str = string.sub(str, 1, len - 3) .. '...' end
  return string.rpad(str, len, char)
end

-- Trims leading and trailing spaces from a string
string.trim = function(str)
  return string.gsub(str, '^%s*(.-)%s*$', '%1')
end

function ParseHWiNFORegOutput(sMeasureName)
  --
  -- This function parses HWiNFO registry info and displays it in the skin editor of choice.
  -- Based on code provided by raiguard and jsmorley.
  --
  local raw = SKIN:GetMeasure(sMeasureName):GetStringValue()
  local fileName = SKIN:GetVariable('@') .. 'HWiNFOIndexList.txt'
  local output = ''

  -- match over each group as a whole
  local match_string = '    Sensor(%d-)    .-    (.-)\n    .-    .-    (.-)\n    .-    .-    (.-)\n    .-    .-    (.-)\n'
  for index, sensor, label, value, value_raw in raw:gmatch(match_string) do
    output = output
      .. string.rpad(index, 5)   .. ' '
      .. string.rpadex(string.trim(sensor), 40) .. ' '
      .. string.rpadex(string.trim(label), 30)  .. ' '
      .. value .. '\n'
  end

  if #output == 0 then
    -- no sensor entries; output error message
    output = 'HWiNFO Sensor Entry Index List\n\n'
      .. 'ERROR:  HWiNFO is not configured or is not running.\n'
      .. '        https://github.com/SilverAzide/Gadgets/wiki/HOW-TO-Configure-HWiNFO#how-to-configure-hwinfo\n'
  else
    -- create document header/footer
    output = 'HWiNFO Sensor Entry Index List\n\n'
      .. string.rpad('Index', 5)     .. ' '
      .. string.rpad('Sensor', 40)   .. ' '
      .. string.rpad('Label', 30)    .. ' '
      .. 'Value'                     .. '\n'
      .. string.rep('-', 5)          .. ' '
      .. string.rep('-', 40)         .. ' '
      .. string.rep('-', 30)         .. ' '
      .. string.rep('-', 15)         .. '\n'
      .. output
  end

  -- write to the file
  local file = io.open(fileName, 'w')
  file:write(output)
  file:close()

  -- open the page in the browser
  SKIN:Bang('"' .. SKIN:GetVariable('CONFIGEDITOR') .. '" "' .. fileName .. '"')

  return
end                                                                          -- ParseHWiNFORegOutput