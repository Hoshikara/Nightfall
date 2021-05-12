---@class BestPlay : Song, Difficulty
---@field VF number
BestPlay = {};

---@class ChartMeta
---@field artist string
---@field title string
ChartMeta = {};

---@class FolderStats
---@field total integer # Total for the level -> clear/grade? -> folder
---@field charts ChartMeta[]|nil
FolderStats = {};

---@class Level
---@field clears table<string, table<string, FolderStats>> # Table of individual clear totals, indexed by clear name; clear totals indexed by folder name
---@field clearTotals table<string, FolderStats> # Table of all clear totals (cleared charts), indexed by folder name
---@field grades table<string, table<string, FolderStats>> # Table of individual grade totals, indexed by grade name; grade totals indexed by folder name
---@field gradeTotals table<string, FolderStats> # Table of all grade totals (grade above `B`), indexed by folder name
---@field diffTotals table<string, FolderStats> # Table of diff totals, indexed by folder name
---@field scoreStats table<string, ScoreStats> # Table of all score stats, indexed by folder name
Level = {};

---@class PlayerStats
---@field folders string[] # Array of folder names
---@field levels table<string, Level> # Table of Levels, indexed by level string
---@field playCount integer # Total play count (submitted scores)
---@field songCount integer # Total amount of charts
---@field top50 TopPlay[] # Array of top 50 (or up to 50) plays
PlayerStats = {};

---@class Player
---@field bestPlay BestPlay
---@field stats PlayerStats
---@field VF number
Player = {};

---@class ScoreStats
---@field avg integer # Average score
---@field count integer # Number of scores
---@field min integer # Minimum score
---@field max integer # Maximum score
---@field total integer # Total of all scores
ScoreStats = {};