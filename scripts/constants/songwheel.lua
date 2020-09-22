local _ = {
  clears = {
    'PLAYED',
    'NORMAL',
    'HARD',
    'UC',
    'PUC',
  },
  difficulties = {
    'NOVICE',
    'ADVANCED',
    'EXHAUST',
    'MAXIMUM',
  },
  grades = {
    {
      minimum = 9900000,
      grade = 'S',
    },
    {
      minimum = 9800000,
      grade = 'AAA+',
    },
    {
      minimum = 9700000,
      grade = 'AAA',
    },
    {
      minimum = 9500000,
      grade = 'AA+',
    },
    {
      minimum = 9300000,
      grade = 'AA',
    },
    {
      minimum = 9000000,
      grade = 'A+',
    },
    {
      minimum = 8700000,
      grade = 'A',
    },
    {
      minimum = 7500000,
      grade = 'B',
    },
    {
      minimum = 6500000,
      grade = 'C',
    },
    {
      minimum = 0,
      grade = 'D',
    },
  },
  labels = {
    grid = {
      collection = 'COLLECTION',
      difficulty = 'DIFFICULTY',
      sort = 'SORT',
    },
    info = {
      artist = 'ARTIST',
      bpm = 'BPM',
      clear= 'CLEAR',
      difficulty = 'DIFFICULTY',
      effector = 'EFFECTOR',
      grade = 'GRADE',
      highScore = 'HIGH SCORE',
      title = 'TITLE',
    },
  },
  levels = {
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
  },
  settings = {
    {
      {
        label = 'GLOBAL OFFSET',
        values = {
          value = '',
        },
      },
      {
        label = 'INPUT OFFSET',
        values = {
          value = '',
        },
      },
      {
        label = 'CURRENT SONG OFFSET',
        values = {
          value = '',
        },
      },
    },
    {
      {
        label = 'SPEED MOD',
        values = {
          'XMOD',
          'MMOD',
          'CMOD',
        },
      },
      {
        label = 'HI-SPEED',
        values = {
          value = '',
        },
      },
      {
        label = 'MOD SPEED',
        values = {
          value = '',
        },
      },
    },
    {
      {
        label = 'GAUGE TYPE',
        values = {
          'NORMAL',
          'HARD',
        },
      },
      {
        label = 'RANDOM MODE',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'MIRROR MODE',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'BACKGROUNDS',
        values = {
          ['true'] = 'DISABLED',
          ['false'] = 'ENABLED',
        },
      },
      {
        label = 'SCORE DISPLAY MODE',
        values = {
          'ADDITIVE',
          'SUBTRACTIVE',
          'AVERAGE',
        },
      },
      {
        label = 'AUTOPLAY',
      },
      {
        label = 'PRACTICE MODE',
      },
    },
    {
      {
        label = 'STATUS',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'HIDDEN CUTOFF',
        values = {
          value = '',
        },
      },
      {
        label = 'HIDDEN FADE',
        values = {
          value = '',
        },
      },
      {
        label = 'SUDDEN CUTOFF',
        values = {
          value = '',
        },
      },
      {
        label = 'SUDDEN FADE',
        values = {
          value = '',
        },
      },
      {
        label = 'TRACK COVER',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      }
    },
    {
      {
        label = 'CRITICAL WINDOW',
        values = {
          value = '',
        },
      },
      {
        label = 'NEAR WINDOW',
        values = {
          value = '',
        },
      },
      {
        label = 'HOLD WINDOW',
        values = {
          value = '',
        },
      },
      {
        label = 'DEFAULT VALUES',
      },
      {
        label = 'HARD VALUES',
      },
    }
  },
  sorts = {
    {
      name = 'TITLE',
      direction = 'down',
    },
    {
      name = 'TITLE',
      direction = 'up',
    },
    {
      name = 'SCORE',
      direction = 'down',
    },
    {
      name = 'SCORE',
      direction = 'up',
    },
    {
      name = 'DATE',
      direction = 'down',
    },
    {
      name = 'DATE',
      direction = 'up',
    },
    {
      name = 'ARTIST',
      direction = 'down',
    },
    {
      name = 'ARTIST',
      direction = 'up',
    },
    {
      name = 'EFFECTOR',
      direction = 'down',
    },
    {
      name = 'EFFECTOR',
      direction = 'up',
    },
  },
  tabs = {
    'OFFSETS',
    'HI-SPEED',
    'GAME MODIFIERS',
    'HIDDEN AND SUDDEN',
    'HIT WINDOWS',
  },
};

return _;

