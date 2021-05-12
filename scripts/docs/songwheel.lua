-- songwheel `songwheel` table

---@class Difficulty
---@field difficulty integer # Difficulty index
---@field hash string # Difficulty hash
---@field id integer # Difficulty id, unique static identifier
---@field illustrator string # Difficulty jacket illustrator
---@field jacketPath string # Full filepath to the jacket image on the disk
---@field level integer # Difficulty level
---@field scores Score[] # Scores for the current difficulty
---@field topBadge integer # `0 = Never Played`, `1 = Played`, `2 = Cleared`, `3 = Hard Cleared`, `4 = Full Chain`, `5 = Perfect Chain`
Difficulty = {};

---@class Song
---@field artist string # Chart artist
---@field difficulties Difficulty[] # Array of difficulties for the current song
---@field bpm number # Chart BPM
---@field id integer # Song id, unique static identifier
---@field path string # Full filepath to the chart folder on the disk
---@field title string # Chart title
Song = {};

---@class songwheel
---@field allSongs Song[] # Array of all available songs
---@field searchInputActive boolean # Search status
---@field searchStatus string # Current song database status
---@field searchText string # Search input text
---@field songs Song[] # Array of songs with the current filters/sorting applied
songwheel = {};