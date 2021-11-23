---@meta

---
---The global `IR` table.  
---Available for all scripts.  
---[Official Documentation](https://uscir.readthedocs.io/en/latest/skinning/globals.html)
---
---@class IR
---
---@field Active boolean # If `true`, an IR URL has been set in the settings menu.
---
IR = {}

---
---Executes a Chart Tracked request for the chart with the given `chartHash`.
---Used to check if the IR server will accept the score for the given chart.
---
---@param chartHash difficultyHash
---@param callback function
function IR.ChartTracked(chartHash, callback) end

---
---Executes a Heartbeat request.
---
---@param callback function # Function called with `HeartbeatResponse` when the request is complete.
function IR.Heartbeat(callback) end

---
---Executes a Leaderboard request for the chart with the given `chartHash`.
---
---@param chartHash difficultyHash
---@param displayMode string #
---* `"best"` - Personal Bests
---* `"rivals"` - Personal Bests of designated rivals
---@param numScores integer
---@param callback function # Function called with `LeaderboardResponse` when the request is complete.
function IR.Leaderboard(chartHash, displayMode, numScores, callback) end

---
---Executes a Record request for the chart with the given `chartHash`.
---
---@param chartHash difficultyHash
---@param callback function # Function called with `RecordResponse` when the request is complete.
function IR.Record(chartHash, callback) end

---
---The `IRResponse` object returned by `IR.Heartbeat`
---
---@class HeartbeatResponse : IRResponse
---
---@field body HeartbeatResponseBody
---

---
---The body of a `HeartbeatResponse` in `JSON` format.
---
---@class HeartbeatResponseBody
---
---@field serverName string # The name of the IR server.
---
---@field serverTime integer # The current Unix time according to the server.
---
---@field irVersion string # The specification version implemented by the IR.
---

---
---The `IRResponse` object returned by `IR.Leaderboard`
---
---@class LeaderboardResponse : IRResponse
---
---@field body { scores: IRScore[] }
---

---
---The `IRResponse` object returned by `IR.Record`
---
---@class RecordResponse : IRResponse
---
---@field body { record: IRScore }
---
