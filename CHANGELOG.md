###### October 28, 2020
- Completed work for `Challenge Wheel`
  - `Challenge Result` WIP
  - only access if using beta build for USC courses (official courses not implemented at time of writing)
- Refactored some `Song Select` components for better responsive sizing

###### October 2, 2020
- Minor refactoring and visual adjustments for score displays and cursors

###### September 30, 2020
- Modified `Gameplay` appearance slightly
- Fixed Multiplayer results crashes (hopefully)
- Fixed Multiplayer scoreboard during gameplay updating with incorrect names

###### September 27, 2020
- Completed work for Multiplayer screens, features to note:
  - If host, hover over users to display host controls (transfer host or kick user)
- Added Username and Score Difference displays to `Gameplay`
- Added the following toggles to Skin Settings:
  - User Info during `Gameplay` (both Username and Score Difference)
  - Score Difference exclusively
  - `[BT-A]` shortcut for Controls during `Song Select`
  - `[FX-L]` shortcut for Hard Gauge during `Multiplayer`
  - `[FX-R]` shortcut for Mirror Mode during `Multiplayer`
- Added upscore display on `Results` info panel
- Fixed scaling issues in `Song Select`
- Fixed indexing of nil value in multiplayer `Results`

###### September 22, 2020
- Completed work for Practice Mode, `gameplay` and `gamesettingsdialog` scripts updated
- Completed work for Results screen, features to note:
  - Increase hit graph scale with `[BT-A]`
  - Select from list of highscores (or player scores for Multiplayer) with `[FX-L]` / `[FX-R]`
  - Select screenshot region from Skin Settings: `fullscreen` or `panel`
- Moved `Singleplayer` and `Multiplayer` main menu buttons to a separate 'screen' to make room for upcoming `Challenges` feature
- Added new 'Controls' page for Practice Mode controls and basic setup
- Added Skin Setting caching for active collection/level and volforce to prevent visual bugs on Song Select screen

###### September 13, 2020
- Re-arranged 'Sort', 'Difficulty', and 'Collection' labels in Song Select screen
- Addressed crash caused by newline character being inserted in `skin.cfg`
- Enabled Hit Error bar (again), set position in Skin Settings
- Added a null check to Game Settings labels
- Removed all backgrounds and unused textures

###### September 12, 2020
- Completed work for gameplay screen, including multiplayer scoreboard
- Changed accessiblity for 'Controls' screen during Song Select: Hold `[BT-A]` to show, and press `[BT-D]` to navigate pages
  - 'General', 'Gameplay', and 'Results' pages added
  - Previous controller icon and hover behavior removed
- Added an outline to Search and Collection Name input fields when active
- Added volforce display to Song Select screen
- Refactored and cleaned up various scripts

###### September 8, 2020
- Completed work on song select screen and related components including:
  - Filter and Sort wheels
  - Collection Dialog
  - Game settings dialog, currently incomplete/inaccessible for Practice Mode
- Added 'Song Select' and 'Gameplay Settings' controls screen to song select, hover over controller icon in bottom-left corner to display
- Combined 'Controller' and 'Keyboard' sections for controls to account for overlapping actions

###### August 31, 2020
- Created 'Controls' screen, controller-navigable and accessible from a new button in the main menu
- Modified load-in behavior slightly:
  - If an update is available, title is hidden until appropriate actions taken in the prompt
  - Title fades in and the first button is highlighted when menu is fully loaded

###### August 26, 2020
- Replaced textures and shaders for buttons, lasers, track, and more
- Refactored and integrated hit animation system from LucidWave; using different textures
- Added settings for position and scale of hit error bar to 'Skin Settings'
- Enabled hit error bar to resize and scale based on user-defined hit windows

###### August 21, 2020
- Created dialog box for update prompt instead of fullscreen overlay
- Enabled update buttons to be controller-navigable

###### August 20, 2020
- Created main menu assets
- Modified titlescreen script:
  - Extracted controller handling logic
  - Change made to prompt player to install/view update if available
- Implemented osu!-like hit error bar