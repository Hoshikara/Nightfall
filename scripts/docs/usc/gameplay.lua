-- gameplay `gameplay` table

---@class CritLine
---@field cursors LaserCursor[] # 
---@field line Line # Line from the left corner of the track to the right corner
---@field rotation number # The rotation of the crit line, in radians
---@field x integer # Screen x-coordinate of the center of the crit line
---@field y integer # Screen y-coordinate of the center of the crit line
CritLine = {};

---@class LaserCursor
---@field alpha number # Alpha channel value, `0.0` to `1.0`
---@field pos number # The x-position relative to the center of the crit line
---@field skew number # The x-skew of the cursor
LaserCursor = {};

---@class Gauge
---@field type integer # `0` = Effective, `1` = Excessive, `2` = Permissive, `3` = Blastive
---@field value number # Current gauge percentage, `0.0` to `1.0`
Gauge = {};

---@class Line
---@field x1 number # Starting x-coordinate
---@field y1 number # Starting y-coordinate
---@field x2 number # Ending x-coordinate
---@field y2 number # Ending y-coordinate
Line = {};

---@class ScoreReplay
---@field currentScore integer # Current score of the replay
---@field maxScore integer # Ending score of the replay
ScoreReplay = {};

---@class gameplay
---@field artist string # Chart artist
---@field bpm number # Chart BPM
---@field comboState integer # `0` = Normal, `1` = UC, `2` = PUC
---@field critLine CritLine # Table of crit line information
---@field demoMode boolean # Whether the game is in demo mode
---@field difficulty integer # Difficulty index
---@field gauge Gauge # Table of gauge information
---@field hiddenCutoff number # Hidden cutoff value, `0.0` to `1.0`
---@field hiddenFade number # Hidden fade value, `0.0` to `1.0`
---@field hispeed number # Current hispeed
---@field hitWindow HitWindow # Table of hit window information
---@field jacketPath string # Full filepath to the jacket image on the disk
---@field laserActive boolean[] # Array of laser active states, `1` = left, `2` = right
---@field level integer # Chart level
---@field noteHeld boolean[] # Array of button hold states, in order from 1 to 6: `BTA`, `BTB`, `BTC`, `BTD`, `FXL`, `FXR`
---@field practice_setup boolean|nil # `true` = practice setup, `false` = practicing, `nil` = not in practice mode
---@field progress number # Chart progress, `0.0` to `1.0`
---@field scoreReplays ScoreReplay[] # Array of previous scores for the chart
---@field suddenCutoff number # Sudden cutoff value, `0.0` to `1.0`
---@field suddenFade number # Sudden fade value, `0.0` to `1.0`
---@field title string # Chart title
---@field user_id nil|string # Only for multiplayer
gameplay = {};