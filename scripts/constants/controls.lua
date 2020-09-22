local _ = {
  general = {
    {
      action = 'TOGGLE FULLSCREEN',
      controller = '',
      keyboard = '[ALT]  +  [ENTER]',
    },
    {
      action = 'RELOAD SKIN',
      controller = '',
      keyboard = '[F9]',
    },
  },
  songSelect = {
    {
      action = 'START SONG',
      controller = '[START]',
      keyboard = '',
    },
    {
      action = 'SELECT DIFFICULTY',
      controller = '[KNOB-L]',
      keyboard = '[LEFT]  /  [RIGHT]',
    },
    {
      action = 'SELECT SONG',
      controller = '[KNOB-R]',
      keyboard = '[UP]  /  [DOWN]',
    },
    {
      action = 'FILTER SONGS BY COLLECTION',
      controller = '[FX-L]',
      keyboard = '',
    },
    {
      action = 'FILTER SONGS BY DIFFICULTY',
      controller = '[FX-L]  >  [START]',
      keyboard = '',
    },
    {
      action = 'SORT SONGS',
      controller = '[FX-R]',
      keyboard = '',
    },
    {
      action = 'OPEN GAMEPLAY SETTINGS',
      controller = '[FX-L]  +  [FX-R]',
      keyboard = '',
    },
    {
      action = 'OPEN SONG COLLECTIONS',
      controller = '[BT-B]  +  [BT-C]',
      keyboard = '',
    },
    {
      action = 'SEARCH SONGS',
      controller = '',
      keyboard = '[TAB]',
    },
    {
      action = 'START SONG IN AUTOPLAY MODE',
      controller = '',
      keyboard = '[CTRL]  +  [START]',
    },
    {
      action = 'START SONG IN PRACTICE MODE',
      controller = '',
      keyboard = '[ ` ]',
    },
    {
      action = 'DELETE SONG',
      controller = '',
      keyboard = '[DEL]',
    },
    {
      action = 'PREVIOUS SONG PAGE',
      controller = '',
      keyboard = '[PGUP]',
    },
    {
      action = 'NEXT SONG PAGE',
      controller = '',
      keyboard = '[PGDN]',
    },
    {
      action = 'SELECT RANDOM SONG',
      controller = '',
      keyboard = '[F2]',
    },
    {
      action = 'START DEMO MODE',
      controller = '',
      keyboard = '[F8]',
    },
    {
      action = 'OPEN SELECTED SONG FOLDER',
      controller = '',
      keyboard = '[F12]',
    },
  },
  gameplaySettings = {
    {
      action = 'CHANGE TABS',
      controller = '[FX-L]  /  [FX-R]',
      keyboard = '',
    },
    {
      action = 'CHANGE FIELD',
      controller = '[KNOB-L]',
      keyboard = '[UP]  /  [DOWN]',
    },
    {
      action = 'DECREASE VALUE',
      controller = '[BT-A]  /  [BT-B]',
      keyboard = '[LEFT]',
    },
    {
      action = 'INCREASE VALUE',
      controller = '[BT-C]  /  [BT-D]',
      keyboard = '[RIGHT]',
    },
    {
      action = 'ADJUST VALUE',
      controller = '[KNOB-R]',
      keyboard = '',
    },
    {
      action = 'TOGGLE  /  TRIGGER VALUE',
      controller = '[START]',
      keyboard = '',
    },
  },
  gameplay = {
    {
      action = 'ADJUST HISPEED',
      controller = '[START] *',
      keyboard = '',
    },
    {
      action = 'ADJUST EARLY  /  LATE POSITION',
      controller = '[START]  +  [BT-A]',
      keyboard = '',
    },
    {
      action = 'ADJUST HIDDEN / SUDDEN CUTOFF',
      controller = '[START] *  +  [BT-B] *',
      keyboard = '',
    },
    {
      action = 'ADJUST HIDDEN / SUDDEN FADE',
      controller = '[START] *  +  [BT-C] *',
      keyboard = '',
    },
    {
      action = 'RESTART SONG',
      controller = '',
      keyboard = '[F5]',
      lineBreak = true,
    },
    {
      action = '',
      controller = '*  HOLD BUTTON, USE  [KNOB-L]  /  [KNOB-R]  TO ADJUST',
      keyboard = '',
      note = true,
    },
  },
  results = {
    {
      action = 'INCREASE HIT GRAPH SCALE',
      controller = '[BT-A]',
      keyboard = '',
    },
    {
      action = 'PREVIOUS SCORE',
      controller = '[FX-L]',
      keyboard = '',
    },
    {
      action = 'NEXT SCORE',
      controller = '[FX-R]',
      keyboard = '',
    },
    {
      action = 'CAPTURE SCREENSHOT',
      controller = '',
      keyboard = '[F12]',
      lineBreak = true,
    },
  },
  multiplayer = {
    {
      action = 'TOGGLE GAUGE TYPE',
      controller = '[FX-L]',
      keyboard = '',
    },
    {
      action = 'TOGGLE MIRROR MODE',
      controller = '[FX-R]',
      keyboard = '',
    },
    {
      action = 'TOGGLE CHAT WINDOW',
      controller = '',
      keyboard = '[F8]',
    },
  },
  nautica = {
    {
      action = 'DOWNLOAD SONG',
      controller = '[START]',
      keyboard = '',
    },
    {
      action = 'PREVIEW SONG',
      controller = '[BT-A]',
      keyboard = '',
    },
    {
      action = 'SELECT SONG',
      controller = '[KNOB-R]',
      keyboard = '[UP]  /  [DOWN]',
    },
    {
      action = 'FILTER SONGS BY DIFFICULTY',
      controller = '[FX-L]',
      keyboard = '',
    },
    {
      action = 'SORT SONGS',
      controller = '[FX-R]',
      keyboard = '',
    },
  },
  practiceMode = {
    {
      action = 'OPEN PRACTICE MODE SETTINGS **',
      controller = '[FX-L]  +  [FX-R]*',
      keyboard = '[ESC]',
    },
    {
      action = 'PAUSE SONG',
      controller = '[FX-L]  /  [FX-R]',
      keyboard = '',
    },
    {
      action = 'SCRUB THROUGH SONG (NORMAL)',
      controller = '[KNOB-L]',
      keyboard = '',
    },
    {
      action = 'SCRUB THROUGH SONG (FAST)',
      controller = '[KNOB-R]',
      keyboard = '',
      lineBreak = true,
    },
    {
      action = '',
      controller = "*  [BACK]  /  [ESC]  IF   `CONTROLLER INPUTS FOR SETUP`   IS DISABLED",
      keyboard = '',
      note = true,
    },
    {
      action = '',
      controller = "**  SEE   'GAMEPLAY SETTINGS'   FOR CONTROLS",
      keyboard = '',
      lineBreak = true,
      note = true,
    },
    {
      action = '',
      controller = 'BASIC SETUP',
      keyboard = '',
      lineBreak = true,
      note = true,
    },
    {
      action = '',
      controller = '1.  ENTER PRACTICE MODE',
      keyboard = '',
      note = true,
    },
    {
      action = '',
      controller = '1.  CLOSE PRACTICE MODE SETTINGS,  SCRUB THROUGH SONG TO FIND START POINT',
      keyboard = '',
      note = true,
    },
    {
      action = '',
      controller = "2.  OPEN PRACTICE MODE SETTINGS,  TRIGGER  'USE CURRENT TIME AS START POINT'",
      keyboard = '',
      note = true,
    },
    {
      action = '',
      controller = '3.  CLOSE PRACTICE MODE SETTINGS,  SCRUB THROUGH SONG TO FIND END POINT',
      keyboard = '',
      note = true,
    },
    {
      action = '',
      controller = "4.  OPEN PRACTICE MODE SETTINGS,  TRIGGER  'USE CURRENT TIME AS END POINT'",
      keyboard = '',
      note = true,
    },
    {
      action = '',
      controller = "5A.  ENABLE  'AUTO-RESTART ON PASS'",
      keyboard = '',
      note = true,
    },
    {
      action = '',
      controller = "5B.  ENABLE  'AUTO-RESTART ON FAIL',  CONFIGURE  'MISSION SETTINGS'",
      keyboard = '',
      note = true,
    },
    {
      action = '',
      controller = "6.  TRIGGER  'BEGIN PRACTICE'",
      keyboard = '',
      note = true,
    },
  },
};

return _;