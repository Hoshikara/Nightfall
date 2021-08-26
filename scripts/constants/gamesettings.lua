return {
  ['Offsets'] = {
    name = 'OFFSETS',
    ['Global Offset'] = {
      name = 'VISUAL OFFSET',
      special = 'TIME',
    },
    ['Button Input Offset'] = {
      name = 'BUTTON INPUT OFFSET',
      special = 'TIME',
    },
    ['Laser Input Offset'] = {
      name = 'LASER INPUT OFFSET',
      special = 'TIME',
    },
    ['Song Offset'] = {
      name = 'OFFSET FOR CURRENT SONG',
      special = 'TIME',
    },
    ['Compute Song Offset'] = { name = 'AUTO-COMPUTE SONG OFFSET' },
  },
  ['HiSpeed'] = {
    name = 'LANE-SPEED',
    ['Speed Mod'] = {
      name = 'MODE',
      options = {
        'XMOD',
        'MMOD  (RECOMMENDED)',
        'CMOD',
      },
    },
    ['HiSpeed'] = { name = 'STATIC MULTIPLIER  (XMOD)' },
    ['ModSpeed'] = {
      name = 'TARGET VALUE  (MMOD)',
      special = 'LANE-SPEED',
    },
  },
  ['Game'] = {
    name = 'GAMEPLAY',
    ['Gauge'] = {
      name = 'GAUGE TYPE',
      options = {
        'EFFECTIVE',
        'EXCESSIVE',
        'PERMISSIVE',
        'BLASTIVE',
      },
    },
    ['Blastive Rate Level'] = { name = 'BLASTIVE RATE LEVEL' },
    ['Backup Gauge'] = {
      invert = false,
      name = 'BACKUP GAUGE  (ARS)',
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
    ['Autoplay'] = { name = 'START AUTOPLAY' },
    ['Practice'] = { name = 'START PRACTICE MODE' },
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
      name = 'CRITICAL WINDOW',
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
    ['Slam Window'] = {
      name = 'SLAM WINDOW',
      special = 'TIME WINDOW',
    },
    ['Set to NORMAL'] = { name = 'SET TO DEFAULT VALUES' },
    ['Set to HARD'] = { name = 'SET TO HARD VALUES' },
  },
};