### 1.5.7 - November 9, 2024
- `Practice Mode` changes
  - Fixed BPM and playback speed not displaying correcting when playback speed is above 100%

### 1.5.6 - September 10, 2024
- `Gameplay` changes
  - Improved performance of animations (Thanks to skade)

### 1.5.5 - June 26, 2024
- Contribution by @zzunja [Fixed crash on hitDeltaBar if pressing buttons before chart is loaded](https://github.com/Hoshikara/Nightfall/pull/18)

### 1.5.4 - June 16, 2024
- `Gameplay` changes
  - Adjusted shadow of UI elements to improve readability when using backgrounds
  - Fixed laser animations not rotating with the critical line
  - Removed black backgrounds from hit animations so they do not appear when using backgrounds

### 1.5.3 - April 20, 2024
- `Gameplay` changes
  - Re-implemented assist tick setting
- `Results` changes
  - Clear raise is now shown if applicable e.g. `NORMAL > HARD`, `HARD > PUC`, etc.

### 1.5.2 - January 29, 2024
- Added Practice Mode information which includes goal, pass rate, score, and a button rating graph
- Added a skin setting to filter the `ALL` folder stats to only show stats for official charts
- Fixed Practice Mode controls not appearing

### 1.5.1 - January 11, 2024
- Fixed slow animations at lower framerates (Thanks to skade)
- Fixed an error that occurred when attempting to preview a Nautica chart with no preview audio (Thanks to t3s)
- Fixed Results song offset suggestion displaying incorrect values
- Fixed the Early / Late opacity setting missing from Gameplay Settings

### 1.5.0 - January 9, 2024
- Moderate design update which includes changes of varying degree to animations, fonts, UI elements, screen layouts, and more
- Added JPG image support
- Added a skin settings to disable the tinting and adjust the dim of the common background image
- Modified layout logic to support more aspect ratios; elements will no longer be cut off but instead be scaled to fit within the horizontal/vertical edges
- Standardized knob behavior to be left knob for horizontal navigation and right knob for vertical navigation
- `Main Menu` changes:
  - Added `VOLFORCE TARGET` page which calculates and displays a list of scores required for a given target volforce value
  - Removed `PLAYER INFO` page
- `Song Select` changes:
  - Added a Top 50 display that can be opened with `BT-A`
  - Added a folder stats display that appears during folder/level selection; this can be disabled in skin settings
  - Added effect radar display for known converts
  - Added support for defining custom chart effect radar, see `radar.lua` for more information
  - Added a slide-out window to display local and online scores (if applicable), revealed with `BT-D`
  - Removed density graph display
- `Gameplay` changes:
  - Added a player card component which displays:
    - Avatar (image file is `/textures/gameplay/avatar.png`)
    - Player name
    - Volforce value
    - Dan level (user configurable)
  - Added new textures for buttons and fx buttons; including holds
  - Added new laser textures; they are now configurable via the USC laser color setting
  - Added a new track texture which matches the configured laser colors
  - Removed the chain burst animation due to large memory consumption
  - Added an EX SCORE percentage display
  - Holding down `START` now shows the lane-speed range of the current chart (if applicable)
- `Gameplay Settings` changes:
  - Renamed from `In-game Preview`
  - Added a setting to change the position of the hit delta bar
  - Added a setting to change the position and opacity of the chain display
  - Added settings to change the scale of all elements
  - Added settings to change the hue of hit/hold/laser animations
  - Added various player card settings
  - Added settings to change the fill and percentage displys for the gauge bar
- `Results` changes:
  - Added a score and object "replay" feature in place of the previous hover-to-zoom hit stat graph--the lengths of hold and laser objects may be inaccurate due to skinning limitations
  - Added a skin setting to disable the color coding of rating texts
  - Added absolute mean delta and standard deviation information
  - Added an EX SCORE percentage display
  - Added support for IR leaderboards which can be toggled with `BT-D`

### 1.4.8 - October 9, 2021
- Changed Blastive Level display to pull from appropriate sources; effectively fixes challenges with forced Blastive Rate displaying the incorrect level

### 1.4.7 - September 3, 2021
- Added skin settings to change the gameplay chain state colors

### 1.4.6 - August 29, 2021
- Added a skin setting to toggle `Early / Late` flicker
- Added `BEST` and `TOTAL` columns to the `Results` screen breakdown chart
- Fixed lane-speed display not changing after the last BPM change (if any)
- Fixed overflowing challenge requirement lines
- Removed skin setting to adjust `Early / Late` flicker speed

### 1.4.5 - August 26, 2021
- Added an additional window for settings descriptions to the `Game Settings` window

### 1.4.4 - August 26, 2021
- Added a `CMOD` indicator for results/challenge results if it is used on charts containing BPM changes
- Added an additional check to ignore the user's USC folder name when verifying converts' folder paths
- Changed various `HI-SPEED` usages to `LANE-SPEED`; displayed value has been changed accordingly

### 1.4.3 - August 25, 2021
- `Results` changes
  - Added button/hold/laser breakdown chart
  - Removed best stat delta display and skin setting
- Added a skin setting to enable assist tick
- Enabled stop preview functionality for `Nautica` screen
- Increased display name cutoff from 9 characters to 12

### 1.4.2 - August 23, 2021
- Changed various gauges to display one decimal place
- Fixed an error that occured when starting the game with `player.json` carried over from an older version
- Fixed volforce rounding errors
- General developer chores and improvements (no user experience changes)

### 1.4.1 - August 9, 2021
- Added the following skin settings (adjustable via `In-game Preview`):
  - `Hit Animations` enable / disable
  - `Hit Animations` use SDVX hit animations
- Increased brightness of skin background
- Modified the appearance of the following textures:
  - FX chip
  - FX hold
  - Error hit

### 1.4.0 - August 4, 2021
- Changed default skin background
- Decreased brightness of lasers slightly
- Modified chain burst animation to expand more
- Removed skin setting to use critical color for critical delta display; now uses early/late colors by default

### 1.3.8 - July 27, 2021
- Added an `S-CRITICAL` breakpoint to the hit delta bar along with a skin setting to toggle it
- `Develop Channel`
  - Fixed permissive/blastive clears showing as `CRASH` on the results screen

### 1.3.7 - July 26, 2021
- `In-game Preview` changes
  - New skin settings added/now adjustable from this screen:
    - `Early / Late` flicker speed
    - `Early / Late` opacity
    - `Hi-Speed` ignore change hint
    - `Hit Delta Bar` decay time
    - `Score Difference` update delay time
  - Modified the appearance of the components above to better reflect effects of their corresponding settings
  - Modified the appearance of the settings window:
    - Now opens from outside of the screen
    - Open tabs auto-collapse when a new tab is expanded
    - Radio buttons to toggle the various settings
- `Results` changes
  - Added ARS text to simple view gauge display
  - Fixed VF increase text showing when the truncated value is `0.000`
  - Fixed incorrect VF increase text if VF has been gained from the chart previously (it is your top 50 plays)
  - Fixed a crash that occurred after completing a chart
- Added `EX SCORE` display for gameplay (thanks to t3s for collection logic)
- Added a preview video and a link to FAQ to the `README`
- Added an additional check for new skin versions
- Changed button to load player info from `BT-A` to `BT-D`

### 1.3.6 - July 23, 2021
- Added a number to `Song Select` jackets to indicate the chart's ranking within a player's top 50 charts
- Changed ring animation appearance (slightly) and behavior (attempt to prevent the animation from locking up)
- Changed skin version hover hint to show even when there is no update available

### 1.3.5 - July 22, 2021
- Decreased size of laser cursors
- Decreased thickness of lasers
- Fixed update check failing

### 1.3.4 - July 21, 2021
- Added the ability to click the skin version number of the titlescreen to open a link to the `CHANGELOG`
- Added the ability to navigate multiplayer room list with arrow keys
- Changed skin version number appearance when a new version is available
- Color-coded appropriate `In-game Preview` settings
- Fixed `Player Info` charts for `ALL` level not being sorted by score
- General developer chores

### 1.3.3 - July 19, 2021
- Added skin settings to change the color of the following:
  - Hit stats which includes `S-CRITICAL`, `CRITICAL`, `EARLY`, `LATE`, and `ERROR`; these are reflected during the gameplay and results screens where applicable
  - Positive and negative values (e.g. score difference, result stat comparisons, truthy/falsy settings, etc.)
- Fixed laser miss state being too bright (again)

### 1.3.2 - July 19, 2021
- `Nautica` changes
  - Added the ability to blacklist uploaders by pressing `BT-B` when a song is selected
  - Redesigned screen and added control hints, uploader name, and upload date
  - **NOTE:** `nautica.json` inside the `JSON` folder will be used instead of `nautica.json` in the root skin folder; these two files are not interchangable so treat the new file as your cache (it will hold blacklisted uploaders as well)
- Increased speed of loading spinner
- Removed transparency from search bar

### 1.3.1 - July 17, 2021
- Fixed miss state for holds being indistinguishable from idle state

### 1.3.0 - July 16, 2021
- `Results` changes
  - Added `EX SCORE` and `VOLFORCE` fields, the latter will show increased value if applicable
  - Added `S-CRITICAL` stats to both graphs
  - Limited player names to 9 characters
  - Modified layout to accomdate these changes
  - Replaced song collection control hint
  - Split and changed the simple (top) and detailed (bottom) graphs to be toggled between with `BT-A` (the selected view is persisted)
- Added a skin setting to increase the delay of score difference updates
- Added a skin setting to change the overall skin color scheme
- Changed screen transition to reveal from the side instead of the center
- Changed the mouse color to a neutral color
- Fixed active laser animation persisting
- Fixed an error occuring when opening the collection dialog with no collections
- Fixed console front being visible for landscape orientation
- Replaced `Song Select` and `Challenge Wheel` sort arrows with appropriate subtext

### 1.2.7 - July 8, 2021
- `Player Info` changes
  - Added score and total charts fields to the chart display screen; charts are now be sorted by score
  - Changed hint to click on clear/grade totals to only appear on mouse hover

### 1.2.6 - July 3, 2021
- `Develop Channel`
  - Fixed error when entering practice mode

### 1.2.5 - July 1, 2021
- `Develop Channel`
  - Added blastive rate level display to gameplay and results screen

### 1.2.4 - June 29, 2021
- Added a chart loading indicator to song select
- Added an update check indicator to the main menu
- Fixed a note density graph bug potentially
- Reduced the brightness of gameplay hit beams
- `Develop Channel` 
  - Added color-coding for gameplay XMOD/MMOD adjustments
  - Added support for permissive and blastive gauges

### 1.2.3 - June 27, 2021
- Updated gameplay shader files

### 1.2.2 - June 20, 2021
- Added a skin setting to distinguish early and late critical hit delta by different colors
- Fixed excessive warning color being too bright

### 1.2.1 - June 16, 2021
- Added the ability to mouse over the best critical/near/error counts which will cause the corresponding score in the score list to be selected
- Fixed hit stat graph letters and circles being too high
- Modified all gauge colors for gameplay and results screen
- Moved the results screen hit window labels to the right side of the main panel

### 1.2.0 - June 15, 2021
- Added a display for critical hit delta and skin settings to toggle and adjust the minimum value required to display
- Added a small fade transition when entering and exiting the play options menu
- Added the multiplayer scoreboard for portrait orientation
- Changed game settings hit window texts to be red if it is below the default values
- Changed the multiplayer lobby `Players Not Ready` button text to show `Select Chart` on mouse hover
- Changed result hit graph letters to circles when not hovered and increased letter size for better readability
- Changed the mouse cursor
- Fixed multiplayer scoreboard names not matching up with their respective scores
- Fixed multiplayer room list control hints overlapping with the `Create Room` button for portrait orientation
- Modified hold textures and shaders to potentially fix a visual artifact when a new hold is started while one is currently active

### 1.1.12 - June 10, 2021
- Added a new gauge text to indicate if ARS is enabled
- Added a new ring animation for holds and lasers
- Added a new start and ending animation for holds
- Added new skin settings to select the color for the laser ring, tail, and slam animations (no effect on laser cursor and alert colors)
- Removed optional laser animation colors as a result of the changes above
- Removed several images used for animations as a result of the changes above

### 1.1.11 - June 9, 2021
- Portrait-specific changes:
  - Added button lights to the console
  - Added knob animations to indicate active state and upcoming lasers
  - Separated console and console front textures so they respond to tilt effects properly
- Fixed scaling issue for game settings window during multiplayer

### 1.1.10 - June 8, 2021
- `Multiplayer` changes:
  - Added control hints for selecting and entering a room when viewing the room list
  - Removed the ability to toggle hard gauge and mirror with `FX-L` / `FX-R` as they conflicted with the controls to open the game settings window
  - Removed the respective skin settings for the change above
- Fixed the gap on the left side of the practice mode window
- Potentially fixed a crash that occurred when entering and starting practice mode

### 1.1.9 - June 2, 2021
- Added a display for current playback speed during practice mode; the displayed BPM will also change accordingly
- Fixed a dip occuring at 0 for the result histogram
- Fixed player info being loaded when search input is active
- Increased hit delta bar and laser slam animation queues to decrease chances of either not playing

### 1.1.8 - May 30, 2021
- Brightened laser textures slightly
- Modified yellow laser textures to be less yellow
- Reduced brightness of lasers that are missed

### 1.1.7 - May 25, 2021
- Fixed `TOP 20/50` label not appearing immediately after setting a play that would fall into either category
- Fixed the following after reloading player info
  - Folder dropdown height being increased
  - Incorrect folder stats being shown
  - Stale folder data (list of charts, clear/grade totals, etc.)

### 1.1.6 - May 23, 2021
- Modified song transition to show effector and illustrator
- Fixed a challenge wheel error occuring after completing a challenge
- Fixed best play jacket not updating when a new best play was set
- Fixed landscape `In-game Preview` not showing chain

### 1.1.5 - May 22, 2021
- Added the `In-game Preview` screen, accessible by a button on the second menu page of the titlescreen
  - Real-time preview of specific gameplay elements
  - The following settings can be adjusted or enabled/disabled in this screen:
    - `Early / Late` type and position
    - `Hi-Speed` position
    - `Score Difference` position
    - `Hit Delta Bar` scale
- Removed the following skin settings, in favor of new ones to work with the screen above
  - `Early / Late Position`
  - `Hi-Speed Position`
  - `Score Difference Position`
- Removed the option to enable/disable `User Info`, username will now always be shown
- Removed the `Main Menu` button on the second menu page of the titlescreen, a button prompt will be shown instead

### 1.1.4 - May 21, 2021
- Fixed laser texture segments being visible

### 1.1.3 - May 21, 2021
- Added a score check for song select Top 50 charts to prevent cases where charts would fall into the incorrect label breakpoint
- Changed song select `BEST 20/50` label to `TOP 20/50`
- Decreased lead-in time for gameplay
- Increased laser cursor size slightly
- Fixed ARS gauge graph displaying incorrect switch point when a chart was restarted with F5
- Fixed ARS gauge graph zoom portion
- Fixed down score being displayed for scores that were tied with best

### 1.1.2 - May 17, 2021
- Fixed an error occuring after clearing a chart

### 1.1.1 - May 17, 2021
- Add display for down score to results screen
- Added a check to only show up/down score if a chart has been completed

### 1.1.0 - May 17, 2021
- Added support for portrait orientation
- Added a check to automatically refresh player info when a play meeting the collection criteria is made (level >= 10 chart cleared with at least 8700000 score)
- Fixed a results screen crash from invalid density graph data

### 1.0.4 - May 17, 2021
- Fixed challenge wheel error

### 1.0.3 - May 13, 2021
- Adjusted crit line texture color and size slightly
- Fixed results screen crash from missing histogram data
- Fixed chart length not rolling over properly at 60 seconds
- Removed some unused files

### 1.0.2 - May 13, 2021
- Fixed BPM data getting wiped on excessive fail
- Fixed incoming BPM change not appearing when restarting a chart with `F5`
- Fixed bars for hit delta bar persisting after restarting a chart with `F5`

### 1.0.1 - May 12, 2021
- Fixed Top 50 tab for `Player Info` not scaling properly
- Prevented player info from being loaded if any menus are open (filtering, sorting, etc.)

### 1.0.0 - May 12, 2021
- Added `Player Info` screen to the main menu
  - To load player info, enter `Song Select` and press `BT-A`, doing this also ensures your player info is fully updated
  - Stats are organized by the folder they belong to, along with an additional folder for official Sound Voltex charts (converts)
    - Press `FX-L` to open up folder dropdown, navigate with knobs or click on folder names to select
  - For `Clears` and `Grades` tabs:
    - Totals for a level and clear/grade are hoverable to show overall completion percentage
    - Those same totals are also clickable to view the titles and artists of the charts that make up that total
    - Press `FX-L` or `FX-R` while viewing the charts to navigate chart pages (if applicable)
- `Song Select` changes:
  - Added a note per second graph display but requires the chart to be played at least once; this can be disabled in skin settings
  - Added a scrollbar to the game settings and song collection windows
  - Fixed jacket labels rendering on top of the sorting dropdown
  - Optimized jacket loading for lower memory consumption
  - Removed `BT-A` shortcut to view controls
- `Gameplay` changes:
  - Added upcoming BPM and Hi-Speed change indicators but requires the chart to be played at least once
  - Added a display for Hi-Speed in the middle of the screen when `START` is held; the position can be changed in skin settings
  - Added a flashing indicator for excessive gauge below 30%
  - Added a skin setting to change hit bar decay time for the hit delta bar
  - Added a skin setting to display hit delta from 0 instead of from the current critical window (only relevant when using `TEXT + DELTA` or `DELTA` for `Early / Late Display Type`)
  - Added a skin setting to ignore incoming Hi-Speed changes for the middle Hi-Speed display
  - Added a small animation to the outro text display
  - Added current hit window indicators to the hit delta bar; these fade out after gameplay starts
  - Inverted colors of BPM and Hi-Speed labels and values
  - Fixed hit delta bar not scaling properly for harder hit timing windows
  - Fixed slam animations playing at incorrect positions
  - Modified button, fx, and track tick textures
  - Modified laser textures for more distinct active state
  - Removed laser ending animations (consequence of the change above)
  - Removed `Hit Windows` field for User Info
  - Removed skin setting to change hit delta bar position, now is only displayed at the top of the screen
- `Results` changes:
  - Added a hit bar graph to represent `critical`, `early`, `late`, `early error`, and `late error` counts; hold and laser errors fall into the `late error` category
  - Added a display for current and total score (play) amounts
  - Added a number indicator for comparing best overall critical/near/error count to corresponding stats; this can be disabled in skin settings
  - Added a skin setting to disable recommended offset text
  - Added a skin setting to choose the minimum offset required to show recommended text
  - Changed gauge graph to show both effective and excessive gauge progress when using ARS
  - Changed suggested offset change (increase/decrease by) text to instead recommend the value that the song offset should be set to
  - Fixed gauge graph size
  - Removed the hit window field, instead added as indicators to the hit stat graph
  - Restored button letter indicators for hit stat graph from the default skin; rating colors changed for consistency
- `Challenge Wheel` changes:
  - Fixed challenge wheel results not being displayed immediately after completion
  - More than 3 charts can now be displayed by scrolling with `BT-A`
- Volforce changes
  - Added a check to only allow gain from converts (chart must exist in a folder that contains `SOUND VOLTEX` or `SDVX`, case insensitive)
  - Modified display and calculation to align with Exceed Gear

### March 6, 2021
- Added labels to indicate controls for the following:
  - `Song Select` and `Challenge Wheel`
    - Activating search input
    - Changing current song collection/difficulty filter
    - Changing current song sort
    - Opening gameplay settings
  - `Results`
    - Capturing a screenshot
- Moved practice mode controls and instructions to `Practice Mode`, both can be disabled by newly added skin settings

### March 3, 2021
- Added current hit window display during gameplay; this can be disabled in skin settings
- Adjusted some scrolling animations
- Changed various scrolling labels to reset when not visisble
- Fixed a bug where some skin settings were not being consumed properly
- Fixed a memory leak caused by excessive jacket loading

### February 24, 2021
- Added line highlighting for filter and sort wheels
- Added a skin option to only show high scores with harder hit windows for the results screen
- Fixed a crash that occurred when opening the collection dialog
- Moved some single use functions out of `common.lua`
- Reduced the opacity of hit error bar dividers

### February 22, 2021
- `gamesettingsdialog` changes:
  - Added highlighting to the currently selected setting
  - Added an arrow indicator for tabs that have more than 7 settings
  - Changed text color for settings that can be enabled or disabled
  - Increased the opacity of non-selected settings
- `Song Select` changes:
  - Adjusted spacing and arrangement of song info labels
  - Increased size of grade and clear labels
- `Gameplay` changes:
  - Changed track time display format
  - Refactored script and modified design of hit error bar
- Added color indicators for hit stats on the results panel
- Added a skin setting to change early / late display type, options are the following:
  - DELTA: only displays the hit delta (difference (in ms) between the hit's timing and t he current critical hit window timing)
  - TEXT: only displays the 'EARLY' or 'LATE' text
  - TEXT + DELTA: displays both the text and the hit delta
- Added a skin setting to specify the folder that Nautica charts are saved to
- Previous changes from other commits:
  - Added a suggestion to the results screen on how to adjust current song offset
  - Score difference is now displayed in red if player is behind the top score
- Rewrote and replaced the usages of common functions

### February 11, 2021
- `Gameplay` changes:
  - Added skin setting to change score difference position
  - Current and total track time is now displayed with the progress bar
  - Modified BT and FX chip textures for easier distinction again
- Organized some common functions and provided warnings for missing parameters

### February 6, 2021
- Completed work for `Challenge Result`

### February 2, 2021
- Changes made to support backup gauge option
- Fixed red laser end texture being slightly too short

### January 16, 2021
- `Challenge Wheel` changes:
  - Changed chart display to only show chart title and difficulty to make more room
  - Changed requirements display to a vertical list, limited to 6 lines
  - Fixed incorrect opacity for inactive scrolling challenge names
  - Fixed fixed long challenge names all scrolling at the same time
  - Limited the number of charts displayed for a challenge to 3
- Gameplay-unrelated changes:
  - Implemented a JSON loader, currently being used for value caching
  - Removed developer options from skin settings

### January 11, 2021
- Added timestamp to main result panel and changed stat display orders accordingly
- Changed difficulty level display behavior to allow for non-standard values

### January 8, 2021
- Adjusted scoring threshold for determining `Average` score display
- Carried over the following for `Challenge Wheel`:
  - Adjustable jacket quality
  - Jacket loading improvements
  - Infinite/Gravity/Heavenly/Vivid difficulty names (also fixes incorrect difficulty being displayed)

### December 15, 2020
- Added Skin Setting for adjusting `Song Select` jacket quality

### December 14, 2020
- Improved jacket loading time in `Song Select`
- Fixed labels in list-like components getting cut off on resolutions higher than 1080P
- Fixed challenge names overflowing in `Challenge Wheel`
- Fixed challenge requirements overflowing in `Challenge Wheel`
- Fixed Best 20/50 indicators incorrectly appearing when no scores have submitted

### December 7, 2020
- Added highest grade achieved onto the jackets of the song grid in `Song Select`
- Modified track texture for less distinction between lanes
- Modified BT textures for easier distinction when on top of FX chips or holds
- Fixed track cover not covering lane fully/track invisible effect not working
correctly

### December 6, 2020
- Added scrolling to collection wheel to prevent rendering off the screen
- Fixed Best 20/50 indicator being cut off under certain conditions
- Fixed sort wheel displaying with incorrect labels and position (hopefully)
- Refactored `gamesettingsdialog` to prevent crashes from new/unknown settings

### December 5, 2020
- Infinite/Gravity/Heavenly/Vivid difficulty names are now used if available
- Added an indicator for Best 20/50 songs that contribute to volforce during Song Select
- Fixed sort wheel not showing the correct labels for Song Select
- Fixed maximum chain not resetting on chart restart (F5)

### October 29, 2020
- Refactored more `Song Select` components for reusability and design consistency
- Removed unused `easing` library
- Fixed a crash that occurred when list-like components are empty

### October 28, 2020
- Completed work for `Challenge Wheel`
  - `Challenge Result` WIP
  - only access if using beta build for USC courses (official courses not implemented at time of writing)
- Refactored some `Song Select` components for better responsive sizing

### October 2, 2020
- Minor refactoring and visual adjustments for score displays and cursors

### September 30, 2020
- Modified `Gameplay` appearance slightly
- Fixed Multiplayer results crashes (hopefully)
- Fixed Multiplayer scoreboard during gameplay updating with incorrect names

### September 27, 2020
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

### September 22, 2020
- Completed work for Practice Mode, `gameplay` and `gamesettingsdialog` scripts updated
- Completed work for Results screen, features to note:
  - Increase hit graph scale with `[BT-A]`
  - Select from list of highscores (or player scores for Multiplayer) with `[FX-L]` / `[FX-R]`
  - Select screenshot region from Skin Settings: `fullscreen` or `panel`
- Moved `Singleplayer` and `Multiplayer` main menu buttons to a separate 'screen' to make room for upcoming `Challenges` feature
- Added new 'Controls' page for Practice Mode controls and basic setup
- Added Skin Setting caching for active collection/level and volforce to prevent visual bugs on Song Select screen

### September 13, 2020
- Re-arranged 'Sort', 'Difficulty', and 'Collection' labels in Song Select screen
- Addressed crash caused by newline character being inserted in `skin.cfg`
- Enabled Hit Error bar (again), set position in Skin Settings
- Added a null check to Game Settings labels
- Removed all backgrounds and unused textures

### September 12, 2020
- Completed work for gameplay screen, including multiplayer scoreboard
- Changed accessiblity for 'Controls' screen during Song Select: Hold `[BT-A]` to show, and press `[BT-D]` to navigate pages
  - 'General', 'Gameplay', and 'Results' pages added
  - Previous controller icon and hover behavior removed
- Added an outline to Search and Collection Name input fields when active
- Added volforce display to Song Select screen
- Refactored and cleaned up various scripts

### September 8, 2020
- Completed work on song select screen and related components including:
  - Filter and Sort wheels
  - Collection Dialog
  - Game settings dialog, currently incomplete/inaccessible for Practice Mode
- Added 'Song Select' and 'Gameplay Settings' controls screen to song select, hover over controller icon in bottom-left corner to display
- Combined 'Controller' and 'Keyboard' sections for controls to account for overlapping actions

### August 31, 2020
- Created 'Controls' screen, controller-navigable and accessible from a new button in the main menu
- Modified load-in behavior slightly:
  - If an update is available, title is hidden until appropriate actions taken in the prompt
  - Title fades in and the first button is highlighted when menu is fully loaded

### August 26, 2020
- Replaced textures and shaders for buttons, lasers, track, and more
- Refactored and integrated hit animation system from LucidWave; using different textures
- Added settings for position and scale of hit error bar to 'Skin Settings'
- Enabled hit error bar to resize and scale based on user-defined hit windows

### August 21, 2020
- Created dialog box for update prompt instead of fullscreen overlay
- Enabled update buttons to be controller-navigable

### August 20, 2020
- Created main menu assets
- Modified titlescreen script:
  - Extracted controller handling logic
  - Change made to prompt player to install/view update if available
- Implemented osu!-like hit error bar
