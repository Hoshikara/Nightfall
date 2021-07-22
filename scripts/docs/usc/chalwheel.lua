-- chalwheel `chalwheel` table

---@class Challenge
---@field bestScore integer # Best score for the challenge
---@field charts Chart[] # Array of charts for the challenge
---@field grade string # Best grade achieved for the challenge
---@field id integer # Challenge id, unique static identifier
---@field missing_chart boolean # `true` if a chart is missing
---@field requirement_text string # Challenge requirements, separated by newline character `"\n"`
---@field title string # Challenge title
---@field topBadge integer -- `0 = Never Played`, `1 = Played`, `2 = Cleared`, `3 = Hard Cleared`, `4 = Full Chain`, `5 = Perfect Chain`
Challenge = {};

---@class Chart
---@field artist string # Chart artist
---@field bpm number # Chart BPm
---@field difficulty integer # Difficulty index
---@field effector string # Chart effector
---@field id integer # Chart id, unique static identifier
---@field illustrator string # Chart jacket illustrator
---@field jacketPath string -- Full filepath to the jacket image on the disk
---@field level integer # Chart level
---@field title string # Chart title
Chart = {};

---@class chalwheel
---@field allChallenges Challenge[] # Array of all available challenges
---@field challenges Challenge[] # Array of challenges with the current filters/sorting applied
---@field searchInputActive boolean # Search status
---@field searchStatus string # Current challenge database status
---@field searchText string # Search input text
chalwheel = {};