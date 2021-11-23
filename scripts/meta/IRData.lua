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
    Accepted = 22,
    BadRequest = 40,
    Unauthorized = 41,
    ChartRefused = 42,
    Forbidden = 43,
    NotFound = 44,
    ServerError = 50,
    RequestFailure = 60,
  },
}
