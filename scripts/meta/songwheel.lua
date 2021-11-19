---@meta

---
---The global `songwheel` table.  
---Only available for `/scripts/songselect/songwheel.lua`.  
---[Official Documentation](https://unnamed-sdvx-clone.readthedocs.io/en/latest/songwheel.html)
---
---@class songwheel
---
---@field allSongs Song[] # An array of all available charts.
---
---@field searchInputActive boolean # If `true`, search input is active.
---
---@field searchStatus string # The current song database status.
---
---@field searchText string # The current search input text.
---
---@field songs Song[] # An array of charts with filtering and/or sorting applied.
songwheel = {}
