---@meta

---
---The global `chalwheel` table.  
---Only available for `/scripts/songselect/chalwheel.lua`.  
---[Official Documentation](https://unnamed-sdvx-clone.readthedocs.io/en/latest/chalwheel.html#)
---
---@class chalwheel
---
---@field allChallenges Challenge[] # An array of all available challenges.
---
---@field challenges Challenge[] # An array of challenges with filtering and/or sorting applied.
---
---@field searchInputActive boolean # If `true`, search input is active.
---
---@field searchStatus string # The current challenge database status.
---
---@field searchText string # The current search input text.
chalwheel = {}
