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
    'INFINITE',
    'GRAVITY',
    'HEAVENLY',
    'VIVID',
  },
  grades = {
    { minimum = 9900000, grade = 'S' },
    { minimum = 9800000, grade = 'AAA+' },
    { minimum = 9700000, grade = 'AAA' },
    { minimum = 9500000, grade = 'AA+' },
    { minimum = 9300000, grade = 'AA' },
    { minimum = 9000000, grade = 'A+' },
    { minimum = 8700000, grade = 'A' },
    { minimum = 7500000, grade = 'B' },
    { minimum = 6500000, grade = 'C' },
    { minimum = 0, grade = 'D' },
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
      clear = 'CLEAR',
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
    ['Offsets'] = {
      name = 'OFFSETS',
      ['Global Offset'] = {
        name = 'GLOBAL  OFFSET',
        special = 'TIME',
      },
      ['Input Offset'] = {
        name = 'INPUT OFFSET',
        special = 'TIME',
      },
      ['Song Offset'] = {
        name = 'CURRENT SONG OFFSET',
        special = 'TIME',
      },
    },
    ['HiSpeed'] = {
      name = 'HI-SPEED',
      ['Speed Mod'] = {
        name = 'SPEED MOD',
        options = {
          'XMOD',
          'MMOD',
          'CMOD',
        },
      },
      ['HiSpeed'] = { name = 'HI-SPEED' },
      ['ModSpeed'] = { name = 'MOD SPEED' },
    },
    ['Game'] = {
      name = 'GAMEPLAY',
      ['Gauge'] = {
        name = 'GAUGE TYPE',
        options = {
          'NORMAL',
          'HARD',
        },
      },
      ['Random'] = {
        invert = false,
        name = 'RANDOM MODE',
      },
      ['Mirror'] = {
        invert = false,
        name = 'MIRROR MODE',
      },
      ['Hide Backgrounds'] = {
        invert = true,
        name = 'BACKGROUNDS',
      },
      ['Score Display'] = {
        name = 'SCORE DISPLAY MODE',
        options = {
          'ADDITIVE',
          'SUBTRACTIVE',
          'AVERAGE',
        },
      },
      ['Autoplay'] = { name = 'AUTOPLAY' },
      ['Practice'] = { name = 'PRACTICE MODE' },
    },
    ['Hid/Sud'] = {
      name = 'HIDDEN AND SUDDEN',
      ['Enable Hidden / Sudden'] = {
        invert = false,
        name = 'STATUS',
      },
      ['Hidden Cutoff'] = { name = 'HIDDEN CUTOFF' },
      ['Hidden Fade'] = { name = 'HIDDEN FADE' },
      ['Sudden Cutoff'] = { name = 'SUDDEN CUTOFF' },
      ['Sudden Fade'] = { name = 'SUDDEN FADE' },
      ['Show Track Cover'] = {
        invert = false,
        name = 'TRACK COVER',
      },
    },
    ['Judgement'] = {
      name = 'HIT WINDOWS',
      ['Crit Window'] = {
        name = 'CRIT WINDOW',
        special = 'TIME WINDOW',
      },
      ['Near Window'] = {
        name = 'NEAR WINDOW',
        special = 'TIME WINDOW',
      },
      ['Hold Window'] = {
        name = 'HOLD WINDOW',
        special = 'TIME WINDOW',
      },
      ['Set to NORMAL'] = { name = 'DEFAULT VALUES' },
      ['Set to HARD'] = { name = 'HARD VALUES' },
    },
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
      name = 'CLEAR',
      direction = 'down',
    },
    {
      name = 'CLEAR',
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
};

return _;

