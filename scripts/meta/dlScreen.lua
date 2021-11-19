---@meta

---
---The global `dlScreen` table.  
---Only available for `/scripts/downloadscreen.lua`.
---
---@class dlScreen
dlScreen = {}

---
---Downloads the chart from the `encodedURI`.
---
---@param encodedURI string
---@param header header
---@param songId string
---@param callback function
function dlScreen.DownloadArchive(encodedURI, header, songId, callback) end

---
---Exits the download screen.
---
function dlScreen.Exit() end

---
---Gets the file path to the `songs` folder
---
---@return string filePath
function dlScreen.GetSongsPath() end

---
---Starts playback of the chart preview from the `encodedURI`.
---
---@param encodedURI string
---@param header header
---@param songId string
function dlScreen.PlayPreview(encodedURI, header, songId) end

---
---Stops any chart preview playback.
---
function dlScreen.StopPreview() end
