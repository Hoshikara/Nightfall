---@meta

---
---The global `IRData` table.  
---Available for all scripts.  
---[Official Documentation](https://uscir.readthedocs.io/en/latest/skinning/globals.html#irdata)
---
---@class IRData
---
---@field Active boolean # If `true`, an IR URL has been set in the settings menu.
---
IRData = {
  States = {
    Unused = 0,
    Pending = 10,
    Success = 20,
    BadRequest = 40,
    Unauthorized = 41,
    ChartRefused = 42,
    Forbidden = 43,
    NotFound = 44,
    ServerError = 50,
    RequestFailure = 60,
  },
}

---
---Executes a Chart Tracked request for the chart with the given `chartHash`.
---
---@param chartHash string
---@param callback function
function IRData.ChartTracked(chartHash, callback) end

---
---Executes a Heartbeat request.
---
---@param callback function
function IRData.Heartbeat(callback) end

---
---Executes a Leaderboard request for the chart with the given `chartHash`.
---
---@param chartHash string
---@param displayMode string #
---* `"best"` - Personal Bests
---* `"rivals"` - Personal Bests of designated rivals
---@param numScores integer
---@param callback function 
function IRData.Leaderboard(chartHash, displayMode, numScores, callback) end

