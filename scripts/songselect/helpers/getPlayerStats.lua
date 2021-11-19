--#region Require

local Clears = require("common/constants/Clears")
local DifficultyNames = require("common/constants/DifficultyNames")
local Grades = require("common/constants/Grades")
local PlayerStatsKeys = require("playerinfo/constants/PlayerStatsKeys")
local JsonTable = require("common/JsonTable")
local getDateTemplate = require("common/helpers/getDateTemplate")
local getVolforce = require("common/helpers/getVolforce")
local isOfficialChart = require("common/helpers/isOfficialChart")

--#endregion

local OFFICIAL_FOLDER = "OFFICIAL SOUND VOLTEX CHARTS"

local ceil = math.ceil
local sort = table.sort

--#region Helpers

---@param folders string[]
---@param isClear boolean
---@return PlayerStatsClears|PlayerStatsGrades
local function makeClearOrGradeTables(folders, isClear)
  local tables = {}

  for _, key in ipairs(PlayerStatsKeys[(isClear and "Clears") or "Grades"]) do
    tables[key] = {}

    local current = tables[key]

    for __, folder in ipairs(folders) do
      current[folder] = {}
    end
  end

  return tables
end

---@param folders string[]
---@return PlayerStatsLevel
local function makeLevelTable(folders)
  local clears = makeClearOrGradeTables(folders, true)
  local grades = makeClearOrGradeTables(folders)

  local clearTotals = {}
  local diffTotals = {}
  local gradeTotals = {}
  local scoreStats = {}

  for _, folder in ipairs(folders) do
    clearTotals[folder] = 0
    diffTotals[folder] = 0
    gradeTotals[folder] = 0
    scoreStats[folder] = {
      avg = 0,
      count = 0,
      max = 0,
      min = 0,
      total = 0,
    }
  end

  return {
    clears = clears,
    clearTotals = clearTotals,
    diffTotals = diffTotals,
    grades = grades,
    gradeTotals = gradeTotals,
    scoreStats = scoreStats,
  }
end

---@param folders string[]
---@return PlayerStatsLevels
local function makeLevelTables(folders)
  local levels = {}

  for _, level in ipairs(PlayerStatsKeys.Levels) do
    levels[level] = makeLevelTable(folders)
  end

  return levels
end

---@param play PlayerStatsTopPlay|Difficulty
---@return PlayerStatsTopPlay
local function makeTopPlay(play)
  local topPlay = {
    bpm = play.bpm,
    clear = Clears:get(play.topBadge),
    difficulty = DifficultyNames:get(play.jacketPath, play.difficulty),
    grade = Grades:get(play.scores[1].score),
    jacketPath = play.jacketPath,
    level = ("%02d"):format(play.level),
    score = play.scores[1].score,
    title = play.title,
    volforce = play.volforce,
  }

  if play.artist then
    topPlay.artist = play.artist
    topPlay.effector = play.effector
    topPlay.timestamp = os.date(getDateTemplate(), play.scores[1].timestamp)
  end

  return topPlay
end

---@param plays PlayerStatsTopPlay[]
---@return PlayerStatsTopPlay[]
local function makeTop50(plays)
  sort(plays, function (l, r)
    if l.volforce == r.volforce then
      return l.scores[1].score > r.scores[1].score
    end

    return l.volforce > r.volforce
  end)

  local top50 = {}

  for i, play in ipairs(plays) do
    if play.volforce == 0 then
      break
    end

    if i > 1 then
      play.artist = nil
      play.effector = nil
      play.timestamp = nil
    end

    top50[i] = makeTopPlay(play)

    if i == 50 then
      break
    end
  end

  return top50
end

---@param folders string[]
---@param songPath string
local function updateProps(folders, songPath)
  for __, folder in ipairs(folders) do
    if songPath:find(folder) then
      return folder, isOfficialChart(songPath)
    end
  end
end

---@param diff Difficulty
---@param artist artist
---@param bpm BPM
---@param title title
---@return PlayerStatsTopPlay
local function updateDiff(diff, artist, bpm, title)
  diff.artist = artist
  diff.bpm = bpm
  diff.title = title
  diff.volforce = getVolforce({}, diff)

  return diff
end

---@param clearOrGrade PlayerStatsClear|PlayerStatsGrade
---@param folder string
---@param isOfficial boolean
---@param artist string
---@param title string
---@param score integer
local function updateCharts(clearOrGrade, folder, isOfficial, artist, title, score)
  if not clearOrGrade[folder] then
    return
  end

  local chart = {
    artist = artist,
    score = score,
    title = title
  }

  clearOrGrade[folder][#clearOrGrade[folder] + 1] = chart
  clearOrGrade.All[#clearOrGrade.All + 1] = chart

  if isOfficial then
    clearOrGrade[OFFICIAL_FOLDER][#clearOrGrade[OFFICIAL_FOLDER] + 1] = chart
  end
end

---@param scoreStat PlayerStatsScoreStats
---@param score integer
local function updateScoreStat(scoreStat, score)
  scoreStat.count = scoreStat.count + 1
  scoreStat.total = scoreStat.total + (score / 10000)

  if (score < scoreStat.min) or (scoreStat.min == 0) then
    scoreStat.min = score
  end

  if (score > scoreStat.max) or (scoreStat.max == 0) then
    scoreStat.max = score
  end
end

---@param scoreStats table<string, PlayerStatsScoreStats>
---@param folder string
---@param isOfficial boolean
---@param score integer
local function updateScoreStats(scoreStats, folder, isOfficial, score)
  if not scoreStats[folder] then
    return
  end

  updateScoreStat(scoreStats[folder], score)
  updateScoreStat(scoreStats.All, score)

  if isOfficial then
    updateScoreStat(scoreStats[OFFICIAL_FOLDER], score)
  end
end

---@param totals PlayerStatsTotals
---@param folder string
---@param isOfficial boolean
local function updateTotal(totals, folder, isOfficial)
  if not totals[folder] then
    return
  end

  totals[folder] = totals[folder] + 1
  totals.All = totals.All + 1

  if isOfficial then
    totals[OFFICIAL_FOLDER] = totals[OFFICIAL_FOLDER] + 1
  end
end

---@param level PlayerStatsLevel
---@param folder string
---@param isOfficial boolean
---@param diff Difficulty
---@param artist string
---@param title string
local function updateAll(level, folder, isOfficial, diff, artist, title)
  if diff.topBadge > 0 then
    local score = diff.scores[1].score

    updateCharts(level.clears[Clears:get(diff.topBadge)], folder, isOfficial, artist, title, score)
    updateTotal(level.clearTotals, folder, isOfficial)

    if score >= 8700000 then
      updateCharts(level.grades[Grades:get(score)], folder, isOfficial, artist, title, score)
      updateTotal(level.gradeTotals, folder, isOfficial)
      updateScoreStats(level.scoreStats, folder, isOfficial, score)
    end
  end

  updateTotal(level.diffTotals, folder, isOfficial)
end

---@param clearsOrGrades PlayerStatsClears|PlayerStatsGrades
---@param folder string
local function sortCharts(clearsOrGrades, folder)
  ---@type PlayerStatsClear|PlayerStatsGrade
  for _, clearOrGrade in pairs(clearsOrGrades) do
    local charts = clearOrGrade[folder]

    if #charts > 1 then
      sort(charts, function(l, r)
        return l.score > r.score
      end)
    end
  end
end

---@param levels PlayerStatsLevels
---@param folders string[]
local function formatStats(levels, folders)
  ---@type PlayerStatsLevel
  for _, level in pairs(levels) do
    for __, folder in ipairs(folders) do
      local scoreStats = level.scoreStats[folder]

      if scoreStats.count > 0 then
        scoreStats.avg = ceil((scoreStats.total / scoreStats.count) * 10000)
      end

      sortCharts(level.clears, folder)
      sortCharts(level.grades, folder)
    end
  end
end

--#endregion

---@return PlayerStats
local function getPlayerStats()
  ---@type string[]
  local folders = JsonTable.new("folders"):get()

  if #folders == 0 then
    return
  end

  local currentFolder = ""
  local levels = makeLevelTables(folders)
  local isOfficial = false
  local plays = {}
  local playCount = 0

  for _, song in ipairs(songwheel.allSongs) do
    currentFolder, isOfficial = updateProps(folders, song.path)

    for __, diff in ipairs(song.difficulties) do
      if isOfficial and diff.scores[1] then
        plays[#plays + 1] = updateDiff(diff, song.artist, song.bpm, song.title)
      end

      if diff.level >= 10 then
        playCount = playCount + #diff.scores

        updateAll(
          levels[tostring(diff.level)],
          currentFolder,
          isOfficial,
          diff,
          song.artist,
          song.title
        )
      end
    end
  end

  formatStats(levels, folders)

  return {
    folders = folders,
    levels = levels,
    playCount = playCount,
    top50 = makeTop50(plays),
  }
end

return getPlayerStats

--#region Interfaces

---@class PlayerData
---@field stats PlayerStats
---@field version string
---@field volforce integer

---@class PlayerStats
---@field folders string[]
---Index with any of the following:
---* `"10"`
---* `"11"`
---* `"12"`
---* `"13"`
---* `"14"`
---* `"15"`
---* `"16"`
---* `"17"`
---* `"18"`
---* `"19"`
---* `"20"`
---@field levels PlayerStatsLevels
---@field playCount integer
---@field top50 PlayerStatsTopPlay[]

---@class PlayerStatsTopPlay
---@field artist? artist
---@field bpm BPM
---@field clear string
---@field difficulty string
---@field effector? effector
---@field grade string
---@field jacketPath jacketPath
---@field level string
---@field score score
---@field timestamp? string
---@field title title
---@field volforce integer

---@class PlayerStatsLevels
---@field ['10'] PlayerStatsLevel
---@field ['11'] PlayerStatsLevel
---@field ['12'] PlayerStatsLevel
---@field ['13'] PlayerStatsLevel
---@field ['14'] PlayerStatsLevel
---@field ['15'] PlayerStatsLevel
---@field ['16'] PlayerStatsLevel
---@field ['17'] PlayerStatsLevel
---@field ['18'] PlayerStatsLevel
---@field ['19'] PlayerStatsLevel
---@field ['20'] PlayerStatsLevel

---@class PlayerStatsLevel
---Index with any of the following:
---* `"NORMAL"`
---* `"HARD"`
---* `"UC"`
---* `"PUC"`
---@field clears PlayerStatsClears
---@field clearTotals PlayerStatsTotals
---@field diffTotals PlayerStatsTotals
---Index with any of the following:
---* `"A"`
---* `"A+"`
---* `"AA"`
---* `"AA+"`
---* `"AAA"`
---* `"AAA+"`
---* `"S"`
---@field grades PlayerStatsGrades
---@field gradeTotals PlayerStatsTotals
---@field scoreStats table<string, PlayerStatsScoreStats> # Index with any folder name.

---@alias PlayerStatsClear table<string, PlayerStatsChart[]> # Index with any folder name.

---@class PlayerStatsClears
---@field ['PLAYED'] PlayerStatsClear
---@field ['NORMAL'] PlayerStatsClear
---@field ['HARD'] PlayerStatsClear
---@field ['UC'] PlayerStatsClear
---@field ['PUC'] PlayerStatsClear

---@alias PlayerStatsGrade table<string, PlayerStatsChart[]> # Index with any folder name.

---@class PlayerStatsGrades
---@field ['A'] PlayerStatsGrade
---@field ['A+'] PlayerStatsGrade
---@field ['AA'] PlayerStatsGrade
---@field ['AA+'] PlayerStatsGrade
---@field ['AAA'] PlayerStatsGrade
---@field ['AAA+'] PlayerStatsGrade
---@field ['S'] PlayerStatsGrade

---@class PlayerStatsChart
---@field artist artist
---@field score score
---@field title title

---@alias PlayerStatsTotals table<string, integer> # Index with any folder name.

---@class PlayerStatsScoreStats
---@field avg integer
---@field count integer
---@field max integer
---@field min integer
---@field total number

--#endregion
