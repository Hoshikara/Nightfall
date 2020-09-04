local _ = {
  ['general'] = {
    [1] = {
      ['action'] = 'TOGGLE FULLSCREEN',
      ['controller'] = '',
      ['keyboard'] = '[ALT]  +  [ENTER]'
    },
    [2] = {
      ['action'] = 'RELOAD SKIN',
      ['controller'] = '',
      ['keyboard'] = '[F9]'
    }
  },
  ['songSelect'] = {
    [1] = {
      ['action'] = 'START SONG',
      ['controller'] = '[START]',
      ['keyboard'] = ''
    },
    [2] = {
      ['action'] = 'SELECT DIFFICULTY',
      ['controller'] = '[KNOB-L]',
      ['keyboard'] = '[LEFT]  /  [RIGHT]'
    },
    [3] = {
      ['action'] = 'SELECT SONG',
      ['controller'] = '[KNOB-R]',
      ['keyboard'] = '[UP]  /  [DOWN]'
    },
    [4] = {
      ['action'] = 'FILTER SONGS BY COLLECTION',
      ['controller'] = '[FX-L]',
      ['keyboard'] = ''
    },
    [5] = {
      ['action'] = 'FILTER SONGS BY DIFFICULTY',
      ['controller'] = '[FX-L]  >  [START]',
      ['keyboard'] = ''
    },
    [6] = {
      ['action'] = 'SORT SONGS',
      ['controller'] = '[FX-R]',
      ['keyboard'] = ''
    },
    [7] = {
      ['action'] = 'OPEN GAMEPLAY SETTINGS',
      ['controller'] = '[FX-L]  +  [FX-R]',
      ['keyboard'] = ''
    },
    [8] = {
      ['action'] = 'OPEN SONG COLLECTIONS',
      ['controller'] = '[BT-B]  +  [BT-C]',
      ['keyboard'] = ''
    },
    [9] = {
      ['action'] = 'SEARCH SONGS',
      ['controller'] = '',
      ['keyboard'] = '[TAB]'
    },
    [10] = {
      ['action'] = 'START SONG IN AUTOPLAY MODE',
      ['controller'] = '',
      ['keyboard'] = '[CTRL]  +  [START]'
    },
    [11] = {
      ['action'] = 'DELETE SONG',
      ['controller'] = '',
      ['keyboard'] = '[DEL]'
    },
    [12] = {
      ['action'] = 'PREVIOUS SONG PAGE',
      ['controller'] = '',
      ['keyboard'] = '[PGUP]'
    },
    [13] = {
      ['action'] = 'NEXT SONG PAGE',
      ['controller'] = '',
      ['keyboard'] = '[PGDN]'
    },
    [14] = {
      ['action'] = 'SELECT RANDOM SONG',
      ['controller'] = '',
      ['keyboard'] = '[F2]'
    },
    [15] = {
      ['action'] = 'START DEMO MODE',
      ['controller'] = '',
      ['keyboard'] = '[F8]'
    },
    [16] = {
      ['action'] = 'OPEN SELECTED SONG FOLDER',
      ['controller'] = '',
      ['keyboard'] = '[F12]'
    }
  },
  ['gameplaySettings'] = {
    [1] = {
      ['action'] = 'CHANGE TABS',
      ['controller'] = '[FX-L]  /  [FX-R]',
      ['keyboard'] = ''
    },
    [2] = {
      ['action'] = 'CHANGE FIELD',
      ['controller'] = '[KNOB-L]',
      ['keyboard'] = '[UP]  /  [DOWN]'
    },
    [3] = {
      ['action'] = 'DECREASE VALUE',
      ['controller'] = '[BT-A]  /  [BT-B]',
      ['keyboard'] = '[LEFT]'
    },
    [4] = {
      ['action'] = 'INCREASE VALUE',
      ['controller'] = '[BT-C]  /  [BT-D]',
      ['keyboard'] = '[RIGHT]'
    },
    [5] = {
      ['action'] = 'ADJUST VALUE',
      ['controller'] = '[KNOB-R]',
      ['keyboard'] = ''
    },
    [6] = {
      ['action'] = 'TOGGLE VALUE',
      ['controller'] = '[START]',
      ['keyboard'] = ''
    }
  },
  ['gameplay'] = {
    [1] = {
      ['action'] = 'ADJUST HISPEED',
      ['controller'] = '[START]*',
      ['keyboard'] = ''
    },
    [2] = {
      ['action'] = 'ADJUST HIDDEN / SUDDEN CUTOFF',
      ['controller'] = '[START]*  +  [BT-B]*',
      ['keyboard'] = ''
    },
    [3] = {
      ['action'] = 'ADJUST HIDDEN / SUDDEN FADE',
      ['controller'] = '[START]*  +  [BT-C]*',
      ['keyboard'] = ''
    },
    [4] = {
      ['action'] = 'RESTART SONG',
      ['controller'] = '',
      ['keyboard'] = '[F5]',
      ['lineBreak'] = true
    },
    [5] = {
      ['action'] = '',
      ['controller'] = '* HOLD BUTTON, USE  [KNOB-L]  /  [KNOB-R]  TO ADJUST',
      ['keyboard'] = '',
      ['lineBreak'] = true
    }
  },
  ['results'] = {
    [1] = {
      ['action'] = 'DISPLAY ADVANCED STATS',
      ['controller'] = '[FX-L]',
      ['keyboard'] = ''
    },
    [2] = {
      ['action'] = 'OPEN SONG COLLECTIONS',
      ['controller'] = '[BT-B]  +  [BT-C]',
      ['keyboard'] = ''
    },
    [3] = {
      ['action'] = 'CAPTURE SCREENSHOT',
      ['controller'] = '',
      ['keyboard'] = '[F12]'
    }
  },
  ['multiplayer'] = {
    [1] = {
      ['action'] = 'TOGGLE GAUGE TYPE',
      ['controller'] = '[FX-L]',
      ['keyboard'] = ''
    },
    [2] = {
      ['action'] = 'TOGGLE MIRROR MODE',
      ['controller'] = '[FX-R]',
      ['keyboard'] = ''
    },
    [3] = {
      ['action'] = 'TOGGLE CHAT WINDOW',
      ['controller'] = '',
      ['keyboard'] = '[F8]'
    }
  },
  ['nautica'] = {
    [1] = {
      ['action'] = 'DOWNLOAD SONG',
      ['controller'] = '[START]',
      ['keyboard'] = ''
    },
    [2] = {
      ['action'] = 'PREVIEW SONG',
      ['controller'] = '[BT-A]',
      ['keyboard'] = ''
    },
    [3] = {
      ['action'] = 'SELECT SONG',
      ['controller'] = '[KNOB-R]',
      ['keyboard'] = '[UP]  /  [DOWN]'
    },
    [4] = {
      ['action'] = 'FILTER SONGS BY DIFFICULTY',
      ['controller'] = '[FX-L]',
      ['keyboard'] = ''
    },
    [5] = {
      ['action'] = 'SORT SONGS',
      ['controller'] = '[FX-R]',
      ['keyboard'] = ''
    }
  }
};

return _;