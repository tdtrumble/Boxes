--
-- CpuMeter by SilverAzide
--
-- This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0
-- International (CC BY-NC-SA 4.0) license.
--
-- History:
-- 1.4.1 - 2015-06-09:  Initial release.
-- 1.4.2 - 2015-06-17:  Editorial change only.
-- 1.9.0 - 2015-08-31:  Corrected mapping of physical cores to logical cores.
-- 2.2.0 - 2016-08-06:  Added additional measure names to arrays for 10-core/20-thread CPU support.
-- 2.3.0 - 2016-11-21:  Consolidated All CPU Meter skin variants to a single skin.
-- 3.0.0 - 2017-07-06:  Added additional measure names to arrays for 16-core/32-thread CPU support.
-- 3.0.2 - 2018-03-17:  Added code to enable/disable HWiNFO core clock measures.
-- 4.0.0 - 2018-03-17:  Added additional measure names to arrays for 18-core/36-thread CPU support.
-- 5.0.0 - 2018-12-21:  Added additional measure names to arrays for 32-core/64-thread CPU support.
-- 6.0.0 - 2021-04-06:  Added code to configure CPU performance measures. Updated license.
-- 6.0.2 - 2021-04-16:  Revised configuration of temperature measures when not using per-core temps.
--                      Revised for case where temps show decimal values for some CPUs.
-- 6.1.1 - 2021-05-22:  Added code to properly enumerate PerfMon counters for CPUs in NUMA mode.
--                      Corrected v6.02 regression issue where core temperatures would not update.
-- 7.0.0 - 2021-08-21:  Enhanced code to properly handle SMP and NUMA machine architectures.
--                      Enhanced code to properly handle hybrid processors.
--                      Added additional measure names to arrays for 64-core/128-thread CPU support.
-- 7.1.1 - 2021-09-18:  Corrected v7.0.0 regression issue where total CPU usage would not be shown.
-- 7.2.0 - 2022-01-10:  Revised to handle CPUs/machines with multiple processor groups.
-- 7.3.0 - 2022-04-08:  Corrected to properly handle dual socket systems running Windows 7/2008R2.
-- 7.5.0 - 2022-11-04:  Added optional leading zeros to core numbers.
-- 7.6.0 - 2023-10-06:  Added validation for CPU configuration (i.e., for missing plugin).
--                      Added option to enumerate cores starting with one (default is 1/true).
--
----------------------------------------------------------------------------------------------------
--
-- This script is used to configure temperature, fan, and clock speed measures and meters in the
-- All CPU Meter gadget.
--
----------------------------------------------------------------------------------------------------
--
function Initialize()
  --
  -- this function is called when the script measure is initialized or reloaded
  --

  -- initialize array of measure names
  asCoreTempMeasures = { "MeasureCoreTempCpu1",
                         "MeasureCoreTempCpu2",
                         "MeasureCoreTempCpu3",
                         "MeasureCoreTempCpu4",
                         "MeasureCoreTempCpu5",
                         "MeasureCoreTempCpu6",
                         "MeasureCoreTempCpu7",
                         "MeasureCoreTempCpu8",
                         "MeasureCoreTempCpu9",
                         "MeasureCoreTempCpu10",
                         "MeasureCoreTempCpu11",
                         "MeasureCoreTempCpu12",
                         "MeasureCoreTempCpu13",
                         "MeasureCoreTempCpu14",
                         "MeasureCoreTempCpu15",
                         "MeasureCoreTempCpu16",
                         "MeasureCoreTempCpu17",
                         "MeasureCoreTempCpu18",
                         "MeasureCoreTempCpu19",
                         "MeasureCoreTempCpu20",
                         "MeasureCoreTempCpu21",
                         "MeasureCoreTempCpu22",
                         "MeasureCoreTempCpu23",
                         "MeasureCoreTempCpu24",
                         "MeasureCoreTempCpu25",
                         "MeasureCoreTempCpu26",
                         "MeasureCoreTempCpu27",
                         "MeasureCoreTempCpu28",
                         "MeasureCoreTempCpu29",
                         "MeasureCoreTempCpu30",
                         "MeasureCoreTempCpu31",
                         "MeasureCoreTempCpu32",
                         "MeasureCoreTempCpu33",
                         "MeasureCoreTempCpu34",
                         "MeasureCoreTempCpu35",
                         "MeasureCoreTempCpu36",
                         "MeasureCoreTempCpu37",
                         "MeasureCoreTempCpu38",
                         "MeasureCoreTempCpu39",
                         "MeasureCoreTempCpu40",
                         "MeasureCoreTempCpu41",
                         "MeasureCoreTempCpu42",
                         "MeasureCoreTempCpu43",
                         "MeasureCoreTempCpu44",
                         "MeasureCoreTempCpu45",
                         "MeasureCoreTempCpu46",
                         "MeasureCoreTempCpu47",
                         "MeasureCoreTempCpu48",
                         "MeasureCoreTempCpu49",
                         "MeasureCoreTempCpu50",
                         "MeasureCoreTempCpu51",
                         "MeasureCoreTempCpu52",
                         "MeasureCoreTempCpu53",
                         "MeasureCoreTempCpu54",
                         "MeasureCoreTempCpu55",
                         "MeasureCoreTempCpu56",
                         "MeasureCoreTempCpu57",
                         "MeasureCoreTempCpu58",
                         "MeasureCoreTempCpu59",
                         "MeasureCoreTempCpu60",
                         "MeasureCoreTempCpu61",
                         "MeasureCoreTempCpu62",
                         "MeasureCoreTempCpu63",
                         "MeasureCoreTempCpu64" }

  asSpeedFanMeasures = { "MeasureSpeedFanCpu1",
                         "MeasureSpeedFanCpu2",
                         "MeasureSpeedFanCpu3",
                         "MeasureSpeedFanCpu4",
                         "MeasureSpeedFanCpu5",
                         "MeasureSpeedFanCpu6",
                         "MeasureSpeedFanCpu7",
                         "MeasureSpeedFanCpu8",
                         "MeasureSpeedFanCpu9",
                         "MeasureSpeedFanCpu10",
                         "MeasureSpeedFanCpu11",
                         "MeasureSpeedFanCpu12",
                         "MeasureSpeedFanCpu13",
                         "MeasureSpeedFanCpu14",
                         "MeasureSpeedFanCpu15",
                         "MeasureSpeedFanCpu16",
                         "MeasureSpeedFanCpu17",
                         "MeasureSpeedFanCpu18",
                         "MeasureSpeedFanCpu19",
                         "MeasureSpeedFanCpu20",
                         "MeasureSpeedFanCpu21",
                         "MeasureSpeedFanCpu22",
                         "MeasureSpeedFanCpu23",
                         "MeasureSpeedFanCpu24",
                         "MeasureSpeedFanCpu25",
                         "MeasureSpeedFanCpu26",
                         "MeasureSpeedFanCpu27",
                         "MeasureSpeedFanCpu28",
                         "MeasureSpeedFanCpu29",
                         "MeasureSpeedFanCpu30",
                         "MeasureSpeedFanCpu31",
                         "MeasureSpeedFanCpu32",
                         "MeasureSpeedFanCpu33",
                         "MeasureSpeedFanCpu34",
                         "MeasureSpeedFanCpu35",
                         "MeasureSpeedFanCpu36",
                         "MeasureSpeedFanCpu37",
                         "MeasureSpeedFanCpu38",
                         "MeasureSpeedFanCpu39",
                         "MeasureSpeedFanCpu40",
                         "MeasureSpeedFanCpu41",
                         "MeasureSpeedFanCpu42",
                         "MeasureSpeedFanCpu43",
                         "MeasureSpeedFanCpu44",
                         "MeasureSpeedFanCpu45",
                         "MeasureSpeedFanCpu46",
                         "MeasureSpeedFanCpu47",
                         "MeasureSpeedFanCpu48",
                         "MeasureSpeedFanCpu49",
                         "MeasureSpeedFanCpu50",
                         "MeasureSpeedFanCpu51",
                         "MeasureSpeedFanCpu52",
                         "MeasureSpeedFanCpu53",
                         "MeasureSpeedFanCpu54",
                         "MeasureSpeedFanCpu55",
                         "MeasureSpeedFanCpu56",
                         "MeasureSpeedFanCpu57",
                         "MeasureSpeedFanCpu58",
                         "MeasureSpeedFanCpu59",
                         "MeasureSpeedFanCpu60",
                         "MeasureSpeedFanCpu61",
                         "MeasureSpeedFanCpu62",
                         "MeasureSpeedFanCpu63",
                         "MeasureSpeedFanCpu64" }

  asHWiNFOMeasures = { "MeasureHWiNFOCpu1",
                       "MeasureHWiNFOCpu2",
                       "MeasureHWiNFOCpu3",
                       "MeasureHWiNFOCpu4",
                       "MeasureHWiNFOCpu5",
                       "MeasureHWiNFOCpu6",
                       "MeasureHWiNFOCpu7",
                       "MeasureHWiNFOCpu8",
                       "MeasureHWiNFOCpu9",
                       "MeasureHWiNFOCpu10",
                       "MeasureHWiNFOCpu11",
                       "MeasureHWiNFOCpu12",
                       "MeasureHWiNFOCpu13",
                       "MeasureHWiNFOCpu14",
                       "MeasureHWiNFOCpu15",
                       "MeasureHWiNFOCpu16",
                       "MeasureHWiNFOCpu17",
                       "MeasureHWiNFOCpu18",
                       "MeasureHWiNFOCpu19",
                       "MeasureHWiNFOCpu20",
                       "MeasureHWiNFOCpu21",
                       "MeasureHWiNFOCpu22",
                       "MeasureHWiNFOCpu23",
                       "MeasureHWiNFOCpu24",
                       "MeasureHWiNFOCpu25",
                       "MeasureHWiNFOCpu26",
                       "MeasureHWiNFOCpu27",
                       "MeasureHWiNFOCpu28",
                       "MeasureHWiNFOCpu29",
                       "MeasureHWiNFOCpu30",
                       "MeasureHWiNFOCpu31",
                       "MeasureHWiNFOCpu32",
                       "MeasureHWiNFOCpu33",
                       "MeasureHWiNFOCpu34",
                       "MeasureHWiNFOCpu35",
                       "MeasureHWiNFOCpu36",
                       "MeasureHWiNFOCpu37",
                       "MeasureHWiNFOCpu38",
                       "MeasureHWiNFOCpu39",
                       "MeasureHWiNFOCpu40",
                       "MeasureHWiNFOCpu41",
                       "MeasureHWiNFOCpu42",
                       "MeasureHWiNFOCpu43",
                       "MeasureHWiNFOCpu44",
                       "MeasureHWiNFOCpu45",
                       "MeasureHWiNFOCpu46",
                       "MeasureHWiNFOCpu47",
                       "MeasureHWiNFOCpu48",
                       "MeasureHWiNFOCpu49",
                       "MeasureHWiNFOCpu50",
                       "MeasureHWiNFOCpu51",
                       "MeasureHWiNFOCpu52",
                       "MeasureHWiNFOCpu53",
                       "MeasureHWiNFOCpu54",
                       "MeasureHWiNFOCpu55",
                       "MeasureHWiNFOCpu56",
                       "MeasureHWiNFOCpu57",
                       "MeasureHWiNFOCpu58",
                       "MeasureHWiNFOCpu59",
                       "MeasureHWiNFOCpu60",
                       "MeasureHWiNFOCpu61",
                       "MeasureHWiNFOCpu62",
                       "MeasureHWiNFOCpu63",
                       "MeasureHWiNFOCpu64" }

  asHWiNFOClockMeasures = { "MeasureHWiNFOClockCore0",
                            "MeasureHWiNFOClockCore1",
                            "MeasureHWiNFOClockCore2",
                            "MeasureHWiNFOClockCore3",
                            "MeasureHWiNFOClockCore4",
                            "MeasureHWiNFOClockCore5",
                            "MeasureHWiNFOClockCore6",
                            "MeasureHWiNFOClockCore7",
                            "MeasureHWiNFOClockCore8",
                            "MeasureHWiNFOClockCore9",
                            "MeasureHWiNFOClockCore10",
                            "MeasureHWiNFOClockCore11",
                            "MeasureHWiNFOClockCore12",
                            "MeasureHWiNFOClockCore13",
                            "MeasureHWiNFOClockCore14",
                            "MeasureHWiNFOClockCore15",
                            "MeasureHWiNFOClockCore16",
                            "MeasureHWiNFOClockCore17",
                            "MeasureHWiNFOClockCore18",
                            "MeasureHWiNFOClockCore19",
                            "MeasureHWiNFOClockCore20",
                            "MeasureHWiNFOClockCore21",
                            "MeasureHWiNFOClockCore22",
                            "MeasureHWiNFOClockCore23",
                            "MeasureHWiNFOClockCore24",
                            "MeasureHWiNFOClockCore25",
                            "MeasureHWiNFOClockCore26",
                            "MeasureHWiNFOClockCore27",
                            "MeasureHWiNFOClockCore28",
                            "MeasureHWiNFOClockCore29",
                            "MeasureHWiNFOClockCore30",
                            "MeasureHWiNFOClockCore31",
                            "MeasureHWiNFOClockCore32",
                            "MeasureHWiNFOClockCore33",
                            "MeasureHWiNFOClockCore34",
                            "MeasureHWiNFOClockCore35",
                            "MeasureHWiNFOClockCore36",
                            "MeasureHWiNFOClockCore37",
                            "MeasureHWiNFOClockCore38",
                            "MeasureHWiNFOClockCore39",
                            "MeasureHWiNFOClockCore40",
                            "MeasureHWiNFOClockCore41",
                            "MeasureHWiNFOClockCore42",
                            "MeasureHWiNFOClockCore43",
                            "MeasureHWiNFOClockCore44",
                            "MeasureHWiNFOClockCore45",
                            "MeasureHWiNFOClockCore46",
                            "MeasureHWiNFOClockCore47",
                            "MeasureHWiNFOClockCore48",
                            "MeasureHWiNFOClockCore49",
                            "MeasureHWiNFOClockCore50",
                            "MeasureHWiNFOClockCore51",
                            "MeasureHWiNFOClockCore52",
                            "MeasureHWiNFOClockCore53",
                            "MeasureHWiNFOClockCore54",
                            "MeasureHWiNFOClockCore55",
                            "MeasureHWiNFOClockCore56",
                            "MeasureHWiNFOClockCore57",
                            "MeasureHWiNFOClockCore58",
                            "MeasureHWiNFOClockCore59",
                            "MeasureHWiNFOClockCore60",
                            "MeasureHWiNFOClockCore61",
                            "MeasureHWiNFOClockCore62",
                            "MeasureHWiNFOClockCore63" }

  return
end                                                                                    -- Initialize

function Update()
  --
  -- this function is called when the script measure is updated
  --
  return "success"
end

function Configure(sType)
  --
  -- this function configures the temperature measures for use with CoreTemp, SpeedFan, or HWiNFO
  --
  -- Where:  sType = 0 for no monitoring detected or monitoring disabled
  --                 1 for CoreTemp
  --                 2 for SpeedFan
  --                 3 for HWiNFO
  --
  local aMeasureNames
  local i
  local nCoreIndex
  local nCpuIndex
  local nIndex
  local nLogicalCoresPerSkin
  local nPhysicalCoresPerSkin
  local nType = tonumber(sType)
  local sFormat = "%d"

  -- get skin options
  local nDisabled = tonumber(SKIN:GetVariable("DisableTemps", "1"))
  local nHideTempBar = tonumber(SKIN:GetVariable("HideTempBar", "1"))
  local nUseLeadingZeros = tonumber(SKIN:GetVariable("UseLeadingZeros", "0"))
  local nUseOneBasedCoreNums = tonumber(SKIN:GetVariable("UseOneBasedCoreNums", "1"))

  -- get Windows version (used to detect Windows 7 and earlier) and legacy mode option
  local nWinVersion = SKIN:GetMeasure("MeasureOSVersion"):GetValue()
  local nUseLegacyMode = tonumber(SKIN:GetVariable("UseLegacyMode", "0"))

  -- get total physical CPUs
  local nTotalPhysicalCpus = SKIN:GetMeasure("MeasureCPUPhysicalCPUs"):GetValue()

  -- get total processor groups
  local nTotalProcessorGroups = SKIN:GetMeasure("MeasureCPUGroups"):GetValue()

  -- get total NUMA nodes (if processor groups is 1 and this value equals nTotalPhysicalCpus then the CPU is not in NUMA mode)
  local nTotalNumaNodes = SKIN:GetMeasure("MeasureCPUNumaNodes"):GetValue()

  -- get physical cores per CPU
  local nPhysicalCoresPerCpu = SKIN:GetMeasure("MeasureCPUPhysicalCoresPerCpu"):GetValue()

  -- get logical-to-physical core map table (from CSV string)
  local tCoreMap = Split(SKIN:GetMeasure("MeasureCPULogicalToPhysicalCoreMap"):GetStringValue(), ',')

  -- get 0-based skin index (i.e., skin number)
  local nSkinIndex = tonumber(SKIN:GetVariable("SkinIndex", "0"))

  --
  -- CPU configuration
  --
  -- validate CPU configuration; if zero CPUs, the plugin has failed or is not loaded
  if nTotalPhysicalCpus == 0 then
    nTotalPhysicalCpus = 1
    nTotalProcessorGroups = 1
    nTotalNumaNodes = 1
    nPhysicalCoresPerCpu = 1
    tCoreMap = { 1 }
    
    SKIN:Bang("!Log", "Failed to detect CPU configuration; ActiveNet plugin missing. Reinstalling the Gadgets may correct this error.", "Error")
  end

  -- get total logical cores across all physical CPUs (sockets * logical cores per cpu)
  local nTotalLogicalCores = #tCoreMap

  -- calculate total physical cores across all physical CPUs
  local nTotalPhysicalCores = nTotalPhysicalCpus * nPhysicalCoresPerCpu

  -- calculate logical cores per NUMA node; this value should never exceed 64 in Windows
  local nLogicalCoresPerNumaNode = nTotalLogicalCores / nTotalNumaNodes

  -- calculate logical cores per processor group; this value should never exceed 64 in Windows
  local nLogicalCoresPerGroup = nTotalLogicalCores / nTotalProcessorGroups

  -- calculate physical cores per processor group
  local nPhysicalCoresPerGroup = nTotalPhysicalCores / nTotalProcessorGroups

  -- calculate physical cores per NUMA node
  local nPhysicalCoresPerNumaNode = nTotalPhysicalCores / nTotalNumaNodes

  --
  -- validate configuration type and log info
  --
  if nType == 1 then
    SKIN:Bang("!Log", "CoreTemp detected.", "Notice")

    aMeasureNames = asCoreTempMeasures

  elseif nType == 2 then
    SKIN:Bang("!Log", "SpeedFan detected.", "Notice")

    aMeasureNames = asSpeedFanMeasures

  elseif nType == 3 then
    SKIN:Bang("!Log", "HWiNFO detected.", "Notice")

    aMeasureNames = asHWiNFOMeasures

  else
    nType = 0
    aMeasureNames = asCoreTempMeasures

    if nDisabled == 0 then
      SKIN:Bang("!Log", "No temperature monitor detected.", "Warning")
    else
      SKIN:Bang("!Log", "Temperature monitoring disabled.", "Notice")
    end
  end

  --
  --  skin configuration
  --
  if nTotalProcessorGroups == 1 then
    nCpuIndex = math.floor(nSkinIndex * (nTotalPhysicalCpus / nTotalNumaNodes))
    nLogicalCoresPerSkin = nLogicalCoresPerNumaNode
    nPhysicalCoresPerSkin = nPhysicalCoresPerNumaNode
  else
    nCpuIndex = math.floor(nSkinIndex * (nTotalPhysicalCpus / nTotalProcessorGroups))
    nLogicalCoresPerSkin = nLogicalCoresPerGroup
    nPhysicalCoresPerSkin = nPhysicalCoresPerGroup
  end

  -- core number formatting (used only when temperature monitoring is active)
  if nUseLeadingZeros == 1 then
    if nTotalLogicalCores > 99 then
      sFormat = "%03d"
    elseif nTotalLogicalCores > 9 then
      sFormat = "%02d"
    end
  end

  --
  -- configure logical CPU performance measures for the node/cpu
  --
  for i = 1, 64 do
    -- set performance counter category and counter name
    if i > nLogicalCoresPerSkin then
      SKIN:Bang("!DisableMeasure", "MeasureCPU" .. i)
    else
      if nWinVersion < 6.2 then
        -- if Windows 7 or earlier, reset UsageMonitor Category/Counter settings to legacy mode
        if ((i - 1) + (nSkinIndex * nLogicalCoresPerSkin)) > 64 then
          SKIN:Bang("!DisableMeasure", "MeasureCPU" .. i)
        else
          SKIN:Bang("!SetOption", "MeasureCPU" .. i, "Category", "Processor")
          SKIN:Bang("!SetOption", "MeasureCPU" .. i, "Counter", "% Processor Time")
          SKIN:Bang("!SetOption", "MeasureCPU" .. i, "Name", (i - 1) + (nSkinIndex * nLogicalCoresPerSkin))
        end
      else
        -- calculate the logical core for counter name ("<index>,<logical core>")
        --
        -- NOTE:  If total number of processor groups is:
        --   = 1, the counter is named in "<node index>,<logical core index>" format
        --   > 1, the counter is named in "<group index>,<logical core index>" format
        --   where:  logical core index = the 0-based logical core position on the NUMA node/processor group
        --
        nCoreIndex = (i - 1) % nLogicalCoresPerSkin

        if nUseLegacyMode == 1 then
          -- if using Win7-style counters, reset UsageMonitor Counter setting to legacy mode
          SKIN:Bang("!SetOption", "MeasureCPU" .. i, "Counter", "% Processor Time")
        end
        SKIN:Bang("!SetOption", "MeasureCPU" .. i, "Name", nSkinIndex .. "," .. nCoreIndex)
      end
      SKIN:Bang("!SetOption", "MeasureCPU" .. i, "Reload", 1)
    end
  end
  -- configure overall CPU performance measure
  if nWinVersion < 6.2 then
    -- if Windows 7 or earlier, reset UsageMonitor Category/Counter settings to legacy mode
    SKIN:Bang("!SetOption", "MeasureCPU", "Category", "Processor")
    SKIN:Bang("!SetOption", "MeasureCPU", "Counter", "% Processor Time")
    SKIN:Bang("!SetOption", "MeasureCPU", "Name", "_Total")
    SKIN:Bang("!SetOption", "MeasureCPU", "Reload", 1)
  elseif nUseLegacyMode == 1 then
    -- if using Win7-style counters, reset UsageMonitor Counter setting to legacy mode
    SKIN:Bang("!SetOption", "MeasureCPU", "Counter", "% Processor Time")
    SKIN:Bang("!SetOption", "MeasureCPU", "Reload", 1)
  end

  --
  -- configure the CPU core temperature measures
  --
  for i = 1, #aMeasureNames do
    -- calculate 0-based logical core index (the logical core position on the NUMA node or group)
    nCoreIndex = (nSkinIndex * nLogicalCoresPerSkin) + (i - 1)

    if nType == 0 then
      -- configure temperature meters
      SKIN:Bang("!SetOption", "MeterCore" .. i, "Text", "Core " .. (nCoreIndex + nUseOneBasedCoreNums))
      SKIN:Bang("!SetOption", "MeterCore" .. i, "DynamicVariables", "0")

      -- disable temperature measures
      SKIN:Bang("!DisableMeasure", asCoreTempMeasures[i])
      SKIN:Bang("!DisableMeasure", asSpeedFanMeasures[i])
      SKIN:Bang("!DisableMeasure", asHWiNFOMeasures[i])
    else
      -- configure temperature meters
      if nHideTempBar == 1 then
        -- single temp bar hidden; temps are per core (e.g. for Intel CPUs)
        SKIN:Bang("!SetOption", "MeterCore" .. i, "Text", string.format(sFormat, nCoreIndex + nUseOneBasedCoreNums) .. " [[" .. aMeasureNames[i] .. ":0]°#TempUOM#]")
        SKIN:Bang("!SetOption", "MeterCore" .. i, "DynamicVariables", "1")
      else
        -- single temp bar shown (e.g., for AMD CPUs)
        SKIN:Bang("!SetOption", "MeterCore" .. i, "Text", "Core " .. (nCoreIndex + nUseOneBasedCoreNums))
        SKIN:Bang("!SetOption", "MeterCore" .. i, "DynamicVariables", "0")
      end

      -- enable/disable temperature measures
      if i > nLogicalCoresPerSkin or nCoreIndex > (#tCoreMap - 1) then
        SKIN:Bang("!DisableMeasure", asCoreTempMeasures[i])
        SKIN:Bang("!DisableMeasure", asSpeedFanMeasures[i])
        SKIN:Bang("!DisableMeasure", asHWiNFOMeasures[i])
      else
        -- get the 0-based physical core index from the logical core map table
        nCoreIndex = tCoreMap[nCoreIndex + 1]

        -- configure temperature measures
        if nType == 1 then
          SKIN:Bang("!SetOption", asCoreTempMeasures[i], "CoreTempIndex", nCoreIndex)

          SKIN:Bang("!EnableMeasure", asCoreTempMeasures[i])
          SKIN:Bang("!DisableMeasure", asSpeedFanMeasures[i])
          SKIN:Bang("!DisableMeasure", asHWiNFOMeasures[i])
        elseif nType == 2 then
          SKIN:Bang("!SetOption", asSpeedFanMeasures[i], "SpeedFanNumber", nCoreIndex)

          SKIN:Bang("!DisableMeasure", asCoreTempMeasures[i])
          SKIN:Bang("!EnableMeasure", asSpeedFanMeasures[i])
          SKIN:Bang("!DisableMeasure", asHWiNFOMeasures[i])
        else
          SKIN:Bang("!SetOption", asHWiNFOMeasures[i], "RegValue", "ValueRaw#HWiNFO_CPU" .. nCpuIndex .. "_DTS_Core" .. nCoreIndex .. "Temp#")

          SKIN:Bang("!DisableMeasure", asCoreTempMeasures[i])
          SKIN:Bang("!DisableMeasure", asSpeedFanMeasures[i])
          SKIN:Bang("!EnableMeasure", asHWiNFOMeasures[i])
        end
      end
    end
  end

  --
  -- enable/disable temp bar measures/meters for percent of TjMax
  --
  if nType == 1 and nHideTempBar == 0 then
    SKIN:Bang("!EnableMeasure", "MeasureCoreTempMaxTemp")
    SKIN:Bang("!EnableMeasure", "MeasureCoreTempTjMax")
    SKIN:Bang("!EnableMeasure", "CalcCoreTempPercentTjMax")

    SKIN:Bang("!DisableMeasure", "MeasureSpeedFanMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureSpeedFanTjMax")
    SKIN:Bang("!DisableMeasure", "CalcSpeedFanPercentTjMax")

    SKIN:Bang("!DisableMeasure", "MeasureHWiNFOMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureHWiNFODistToTjMax")
    SKIN:Bang("!DisableMeasure", "CalcHWiNFOPercentTjMax")

    SKIN:Bang("!SetOption", "MeterBarTemperature", "MeasureName", "CalcCoreTempPercentTjMax")
    SKIN:Bang("!SetOption", "MeterBarTemperature", "Reload", 1)
    SKIN:Bang("!SetOption", "MeterMaxTemperature", "Text", "[MeasureCoreTempMaxTemp:0]°#TempUOM#")
    SKIN:Bang("!SetOption", "MeterMaxTemperature", "Reload", 1)

  elseif nType == 2 and nHideTempBar == 0 then
    SKIN:Bang("!DisableMeasure", "MeasureCoreTempMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureCoreTempTjMax")
    SKIN:Bang("!DisableMeasure", "CalcCoreTempPercentTjMax")

    SKIN:Bang("!EnableMeasure", "MeasureSpeedFanMaxTemp")
    SKIN:Bang("!EnableMeasure", "MeasureSpeedFanTjMax")
    SKIN:Bang("!EnableMeasure", "CalcSpeedFanPercentTjMax")

    SKIN:Bang("!DisableMeasure", "MeasureHWiNFOMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureHWiNFODistToTjMax")
    SKIN:Bang("!DisableMeasure", "CalcHWiNFOPercentTjMax")

    SKIN:Bang("!SetOption", "MeterBarTemperature", "MeasureName", "CalcSpeedFanPercentTjMax")
    SKIN:Bang("!SetOption", "MeterBarTemperature", "Reload", 1)
    SKIN:Bang("!SetOption", "MeterMaxTemperature", "Text", "[MeasureSpeedFanMaxTemp:0]°#TempUOM#")
    SKIN:Bang("!SetOption", "MeterMaxTemperature", "Reload", 1)

  elseif nType == 3 and nHideTempBar == 0 then
    SKIN:Bang("!DisableMeasure", "MeasureCoreTempMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureCoreTempTjMax")
    SKIN:Bang("!DisableMeasure", "CalcCoreTempPercentTjMax")

    SKIN:Bang("!DisableMeasure", "MeasureSpeedFanMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureSpeedFanTjMax")
    SKIN:Bang("!DisableMeasure", "CalcSpeedFanPercentTjMax")

    SKIN:Bang("!SetOption", "MeasureHWiNFOMaxTemp", "RegValue", "ValueRaw#HWiNFO_CPU" .. nCpuIndex .. "_DTS_CoreMax#")
    SKIN:Bang("!SetOption", "MeasureHWiNFOMaxTemp", "Reload", 1)
    SKIN:Bang("!EnableMeasure", "MeasureHWiNFOMaxTemp")
    SKIN:Bang("!SetOption", "MeasureHWiNFODistToTjMax", "RegValue", "ValueRaw#HWiNFO_CPU" .. nCpuIndex .. "_DTS_DistToTjMax#")
    SKIN:Bang("!SetOption", "MeasureHWiNFODistToTjMax", "Reload", 1)
    SKIN:Bang("!EnableMeasure", "MeasureHWiNFODistToTjMax")
    SKIN:Bang("!EnableMeasure", "CalcHWiNFOPercentTjMax")

    SKIN:Bang("!SetOption", "MeterBarTemperature", "MeasureName", "CalcHWiNFOPercentTjMax")
    SKIN:Bang("!SetOption", "MeterBarTemperature", "Reload", 1)
    SKIN:Bang("!SetOption", "MeterMaxTemperature", "Text", "[MeasureHWiNFOMaxTemp:0]°#TempUOM#")
    SKIN:Bang("!SetOption", "MeterMaxTemperature", "Reload", 1)

  else
    SKIN:Bang("!DisableMeasure", "MeasureCoreTempMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureCoreTempTjMax")
    SKIN:Bang("!DisableMeasure", "CalcCoreTempPercentTjMax")

    SKIN:Bang("!DisableMeasure", "MeasureSpeedFanMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureSpeedFanTjMax")
    SKIN:Bang("!DisableMeasure", "CalcSpeedFanPercentTjMax")

    SKIN:Bang("!DisableMeasure", "MeasureHWiNFOMaxTemp")
    SKIN:Bang("!DisableMeasure", "MeasureHWiNFODistToTjMax")
    SKIN:Bang("!DisableMeasure", "CalcHWiNFOPercentTjMax")

    SKIN:Bang("!SetOption", "MeterBarTemperature", "MeasureName", "CalcCoreTempPercentTjMax")
    SKIN:Bang("!SetOption", "MeterBarTemperature", "Reload", 1)
    SKIN:Bang("!SetOption", "MeterMaxTemperature", "Text", "[MeasureCoreTempMaxTemp:0]°#TempUOM#")
    SKIN:Bang("!SetOption", "MeterMaxTemperature", "Reload", 1)
  end

  --
  -- configure CPU fan speed measures
  --
  if nType == 3 then
    if nCpuIndex == 0 then
      SKIN:Bang("!SetOption", "MeasureHWiNFOCPUFanRpm", "RegValue", "ValueRaw#HWiNFO_MOBO_CPUFanSpeed#")
    else
      SKIN:Bang("!SetOption", "MeasureHWiNFOCPUFanRpm", "RegValue", "ValueRaw#HWiNFO_MOBO_CPU" .. nCpuIndex .. "FanSpeed#")
    end

    SKIN:Bang("!SetOption", "MeterFanRpm", "MeasureName", "MeasureHWiNFOCPUFanRpm")
    SKIN:Bang("!SetOption", "MeterPercentFan", "MeasureName", "MeasureHWiNFOCPUFanUsage")
    SKIN:Bang("!SetOption", "MeterBarFanUsage", "MeasureName", "MeasureHWiNFOCPUFanUsage")
    SKIN:Bang("!SetOption", "MeterLineFanUsage", "MeasureName", "MeasureHWiNFOCPUFanUsage")
  else
    SKIN:Bang("!SetOption", "MeasureSpeedFanCPUFanRpm", "SpeedFanNumber", nCpuIndex)

    SKIN:Bang("!SetOption", "MeterFanRpm", "MeasureName", "MeasureSpeedFanCPUFanRpm")
    SKIN:Bang("!SetOption", "MeterPercentFan", "MeasureName", "MeasureSpeedFanCPUFanUsage")
    SKIN:Bang("!SetOption", "MeterBarFanUsage", "MeasureName", "MeasureSpeedFanCPUFanUsage")
    SKIN:Bang("!SetOption", "MeterLineFanUsage", "MeasureName", "MeasureSpeedFanCPUFanUsage")
  end

  --
  -- configure CPU clock measures
  --
  if nType == 3 then
    -- using HWiNFO
    for i = 1, #asHWiNFOClockMeasures do
      if i > nPhysicalCoresPerSkin then
        SKIN:Bang("!DisableMeasure", asHWiNFOClockMeasures[i])
      else
        -- calculate 0-based physical core index (the physical core position on the CPU)
        nCoreIndex = (nSkinIndex * nPhysicalCoresPerSkin + (i - 1)) % nPhysicalCoresPerCpu

        SKIN:Bang("!SetOption", asHWiNFOClockMeasures[i], "RegValue", "ValueRaw#HWiNFO_CPU" .. nCpuIndex .. "_Core" .. nCoreIndex .. "Clock#")

        SKIN:Bang("!EnableMeasure", asHWiNFOClockMeasures[i])
      end
    end

    SKIN:Bang("!DisableMeasure", "MeasureCPUSpeedCoreTemp")
    SKIN:Bang("!EnableMeasure",  "MeasureCPUSpeedHWiNFO")
    SKIN:Bang("!SetOption",      "MeterCPUClock", "MeasureName", "MeasureCPUSpeedHWiNFO")
    SKIN:Bang("!UpdateMeter",    "MeterCPUClock")
  else
    -- no monitoring or using CoreTemp/SpeedFan; disable HWiNFO clock measures
    for i = 1, #asHWiNFOClockMeasures do
      SKIN:Bang("!DisableMeasure", asHWiNFOClockMeasures[i])
    end

    if nType == 1 then
      -- using CoreTemp
      SKIN:Bang("!EnableMeasure",  "MeasureCPUSpeedCoreTemp")
      SKIN:Bang("!DisableMeasure", "MeasureCPUSpeedHWiNFO")
      SKIN:Bang("!SetOption",      "MeterCPUClock", "MeasureName", "MeasureCPUSpeedCoreTemp")
      SKIN:Bang("!UpdateMeter",    "MeterCPUClock")
    else
      -- no monitoring/SpeedFan
      SKIN:Bang("!DisableMeasure", "MeasureCPUSpeedCoreTemp")
      SKIN:Bang("!DisableMeasure", "MeasureCPUSpeedHWiNFO")
      SKIN:Bang("!SetOption",      "MeterCPUClock", "MeasureName", "MeasureCPUSpeed")
      SKIN:Bang("!UpdateMeter",    "MeterCPUClock")
    end
  end

  -- force all temperature measures to be reloaded
  for i = 1, #asCoreTempMeasures do
    SKIN:Bang("!SetOption", asCoreTempMeasures[i], "Reload", 1)
  end
  for i = 1, #asSpeedFanMeasures do
    SKIN:Bang("!SetOption", asSpeedFanMeasures[i], "Reload", 1)
  end
  for i = 1, #asHWiNFOMeasures do
    SKIN:Bang("!SetOption", asHWiNFOMeasures[i], "Reload", 1)
  end

  return
end                                                                                     -- Configure

function MaxValue(...)
  --
  -- this function returns the largest value from a list of values
  --   by JSMorley (https://forum.rainmeter.net/viewtopic.php?f=5&t=27600)
  --
  -- NOTE: Requires DynamicValues=1 on the calling measure/meter.
  --       Functions like Max() can be nested only 32 deep; this function has no such limit.
  --       This function works with arguments of any type.
  --
  -- Usage:
  --   [&GadgetScript:MaxValue(#Var1#, #Var2#, #Var3#, #Var4#)]
  --   [&GadgetScript:MaxValue([&Measure1], [&Measure2], [&Measure3], [&Measure4])]
  --
  local i
  local valueTable = {}

  -- load table with function parameter values
  for i = 1, #arg do
    table.insert(valueTable, arg[i])
  end

  -- sort table largest to smallest
  table.sort(valueTable, function(a, b) return a > b end)

  -- return the first (highest) value
  return valueTable[1]
end                                                                                      -- MaxValue

function Split(s, delimiter)
  --
  -- this function splits a delimited string into a table
  --   from https://www.codegrepper.com/code-examples/lua/lua+split+string+into+table
  --
  result = {};
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match);
  end

  return result
end                                                                                         -- Split