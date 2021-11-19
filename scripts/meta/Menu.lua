---@meta

---
---The global `Menu` table.  
---Only available for `/scripts/titlescreen.lua`.
---
---@class Menu
Menu = {}

---Enters the challenges screen.
function Menu.Challenges() end

---Enters the downloads screen (Nautica).
function Menu.DLScreen() end

---Exits the game.
function Menu.Exit() end

---Enters the multiplayer screen.
function Menu.Multiplayer() end

---Enters the settings screen.
function Menu.Settings() end

---Enters the song select screen.
function Menu.Start() end

---Updates the game.
function Menu.Update() end

---
---The global `menu` table.  
---Only available for `/scripts/collectiondialog.lua`.
---
---@class menu
menu = {}

---
---Closes the `Collection Dialog` window.
---
function menu.Cancel() end

---
---Toggles between navigation and text entry modes.
---
function menu.ChangeState() end

---
---Adds/removes the current song to/from the given collection.
---
---@param collectionName string
function menu.Confirm(collectionName) end
