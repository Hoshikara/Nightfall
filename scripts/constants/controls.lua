local controls = {
  ['general'] = {
    [1] = {
      ['action'] = '',
      ['button'] = 'KEYBOARD',
      ['heading'] = true
    },
    [2] = {
      ['action'] = 'TOGGLE FULLSCREEN',
      ['button'] = '[ALT]  +  [ENTER]'
    },
    [3] = {
      ['action'] = 'RELOAD SKIN',
      ['button'] = '[F9]'
    }
  },
  ['songSelect'] = {
    [1] = {
      ['action'] = '',
      ['button'] = 'CONTROLLER',
      ['heading'] = true
    },
    [2] = {
      ['action'] = 'START SONG',
      ['button'] = '[START]'
    },
    [3] = {
      ['action'] = 'SELECT LEVEL',
      ['button'] = '[KNOB-L]'
    },
    [4] = {
      ['action'] = 'SELECT SONG',
      ['button'] = '[KNOB-R]'
    },
    [5] = {
      ['action'] = 'FILTER SONGS BY FOLDER / COLLECTION',
      ['button'] = '[FX-L]'
    },
    [6] = {
      ['action'] = 'FILTER SONGS BY LEVEL',
      ['button'] = '[FX-L]  +  [START]'
    },
    [7] = {
      ['action'] = 'SORT SONGS',
      ['button'] = '[FX-R]'
    },
    [8] = {
      ['action'] = 'OPEN GAMEPLAY SETTINGS',
      ['button'] = '[FX-L]  +  [FX-R]'
    },
    [9] = {
      ['action'] = 'OPEN SONG COLLECTIONS',
      ['button'] = '[BT-B]  +  [BT-C]',
      ['lineBreak'] = true
    },
    [10] = {
      ['action'] = '',
      ['button'] = 'KEYBOARD',
      ['heading'] = true
    },
    [11] = {
      ['action'] = 'SEARCH SONGS',
      ['button'] = '[TAB]'
    },
    [12] = {
      ['action'] = 'START SONG IN AUTOPLAY MODE',
      ['button'] = '[CTRL]  +  [START]'
    },
    [13] = {
      ['action'] = 'SELECT RANDOM SONG',
      ['button'] = '[F2]'
    },
    [14] = {
      ['action'] = 'START DEMO MODE',
      ['button'] = '[F8]'
    },
    [15] = {
      ['action'] = 'OPEN SELECTED SONG IN EDITOR',
      ['button'] = '[F11]'
    },
    [16] = {
      ['action'] = 'OPEN SELECTED SONG IN FILE EXPLORER',
      ['button'] = '[F12]'
    }
  },
  ['gameplaySettings'] = {
    [1] = {
      ['action'] = '',
      ['button'] = 'CONTROLLER',
      ['heading'] = true
    },
    [2] = {
      ['action'] = 'CHANGE TABS',
      ['button'] = '[FX-L]  /  [FX-R]'
    },
    [3] = {
      ['action'] = 'CHANGE FIELD',
      ['button'] = '[KNOB-L]'
    },
    [4] = {
      ['action'] = 'DECREASE / TOGGLE VALUE',
      ['button'] = '[BT-A]  /  [BT-B]'
    },
    [5] = {
      ['action'] = 'INCREASE / TOGGLE VALUE',
      ['button'] = '[BT-C]  /  [BT-D]'
    },
    [6] = {
      ['action'] = 'ADJUST VALUE',
      ['button'] = '[KNOB-R]'
    }
  },
  ['gameplay'] = {
    [1] = {
      ['action'] = '',
      ['button'] = 'CONTROLLER',
      ['heading'] = true
    },
    [2] = {
      ['action'] = 'ADJUST HISPEED',
      ['button'] = '[START]*'
    },
    [3] = {
      ['action'] = 'ADJUST HIDDEN / SUDDEN CUTOFF',
      ['button'] = '[START]*  +  [BT-B]*'
    },
    [4] = {
      ['action'] = 'ADJUST HIDDEN / SUDDEN FADE',
      ['button'] = '[START]*  +  [BT-C]*',
      ['lineBreak'] = true
    },
    [5] = {
      ['action'] = '',
      ['button'] = '* HOLD BUTTON, USE  [KNOB-L]  /  [KNOB-R]  TO ADJUST',
      ['lineBreak'] = true
    },
    [6] = {
      ['action'] = '',
      ['button'] = 'KEYBOARD',
      ['heading'] = true
    },
    [7] = {
      ['action'] = 'RESTART SONG',
      ['button'] = '[F5]'
    }
  },
  ['results'] = {
    [1] = {
      ['action'] = '',
      ['button'] = 'CONTROLLER',
      ['heading'] = true
    },
    [2] = {
      ['action'] = 'DISPLAY ADVANCED STATS',
      ['button'] = '[FX-L]'
    },
    [3] = {
      ['action'] = 'OPEN SONG COLLECTIONS',
      ['button'] = '[BT-B]  +  [BT-C]',
      ['lineBreak'] = true
    },
    [4] = {
      ['action'] = '',
      ['button'] = 'KEYBOARD',
      ['heading'] = true
    },
    [5] = {
      ['action'] = 'CAPTURE SCREENSHOT',
      ['button'] = '[F12]'
    }
  },
  ['multiplayer'] = {
    [1] = {
      ['action'] = '',
      ['button'] = 'CONTROLLER',
      ['heading'] = true
    },
    [2] = {
      ['action'] = 'TOGGLE GAUGE TYPE',
      ['button'] = '[FX-L]'
    },
    [3] = {
      ['action'] = 'TOGGLE MIRROR MODE',
      ['button'] = '[FX-R]',
      ['lineBreak'] = true
    },
    [4] = {
      ['action'] = '',
      ['button'] = 'KEYBOARD',
      ['heading'] = true
    },
    [5] = {
      ['action'] = 'TOGGLE CHAT WINDOW',
      ['button'] = '[F8]'
    }
  },
  ['nautica'] = {
    [1] = {
      ['action'] = '',
      ['button'] = 'CONTROLLER',
      ['heading'] = true
    },
    [2] = {
      ['action'] = 'DOWNLOAD SONG',
      ['button'] = '[START]'
    },
    [3] = {
      ['action'] = 'PREVIEW SONG',
      ['button'] = '[BT-A]'
    },
    [4] = {
      ['action'] = 'SELECT SONG',
      ['button'] = '[KNOB-R]'
    },
    [5] = {
      ['action'] = 'FILTER SONGS BY LEVEL',
      ['button'] = '[FX-L]'
    },
    [6] = {
      ['action'] = 'SORT SONGS',
      ['button'] = '[FX-R]'
    }
  }
};

return controls;