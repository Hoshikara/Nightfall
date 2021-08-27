return {
  ['Offsets'] = {
    name = 'OFFSETS',
    ['Global Offset'] = {
      desc = {
        'OFFSET TO SYNC AUDIO AND VISUALS',
        {
          { color = 'pos', text = 'INCREASE' },
          {
            color = 'white',
            text = 'IF OBJECTS APPEAR TO HIT THE CRITICAL LINE',
          },
          { color = 'early', text = 'EARLY' },
        },
        {
          { color = 'neg', text = 'DECREASE' },
          {
            color = 'white',
            text = 'IF OBJECTS APPEAR TO HIT THE CRITICAL LINE',
          },
          { color = 'late', text = 'LATE' },
        },
      },
      name = 'VISUAL OFFSET',
      special = 'TIME',
    },
    ['Button Input Offset'] = {
      desc = {
        'BUTTON-SPECIFIC OFFSET TO COMPENSATE FOR INPUT DEVICE DELAY',
        {
          { color = 'pos', text = 'INCREASE' },
          { color = 'white', text = 'IF OBJECTS ARE BEING HIT' },
          { color = 'early', text = 'EARLY' },
        },
        {
          { color = 'neg', text = 'DECREASE' },
          { color = 'white', text = 'IF OBJECTS ARE BEING HIT' },
          { color = 'late', text = 'LATE' },
        },
      },
      name = 'BUTTON INPUT OFFSET',
      special = 'TIME',
    },
    ['Laser Input Offset'] = {
      desc = {
        'LASER-SPECIFIC OFFSET TO COMPENSATE FOR INPUT DEVICE DELAY',
        {
          { color = 'white', text = 'IT IS RECOMMENDED TO USE' },
          { color = 'norm', text = 'BUTTON INPUT OFFSET' },
          { color = 'white', text = 'VALUE' },
        }
      },
      name = 'LASER INPUT OFFSET',
      special = 'TIME',
    },
    ['Song Offset'] = {
      name = 'OFFSET FOR SELECTED SONG',
      special = 'TIME',
      desc = {
        'SONG-SPECIFIC OFFSET TO COMPENSATE FOR TIMING ISSUES',
        {
          { color = 'pos', text = 'INCREASE' },
          { color = 'white', text = 'IF OBJECTS ARE BEING HIT' },
          { color = 'late', text = 'LATE' },
        },
        {
          { color = 'neg', text = 'DECREASE' },
          { color = 'white', text = 'IF OBJECTS ARE BEING HIT' },
          { color = 'early', text = 'EARLY' },
        },
      },
    },
    ['Compute Song Offset'] = {
      desc = {
        'AUTOMATICALLY COMPUTES THE SELECTED SONG OFFSET',
        {
          {
            color = 'white',
            text = 'USE AT YOUR OWN DISCRETION AS THE COMPUTED VALUE MAY BE'
          },
          { color = 'neg', text = 'INCORRECT' },
        },
      },
      name = 'AUTO-COMPUTE SONG OFFSET', 
    },
  },
  ['HiSpeed'] = {
    name = 'LANE-SPEED',
    ['Speed Mod'] = {
      desc = {
        'CURRENT LANE-SPEED MODE',
        {
          { color = 'white', text = 'XMOD :' },
          { color = 'norm', text = 'MULTIPLIER' },
          { color = 'white', text = ' X  BPM  =  LANE-SPEED THAT' },
          { color = 'neg', text = 'VARIES' },
          { color = 'white', text = 'PER CHART' },
        },
        {
          { color = 'white', text = 'MMOD : GAME-ADJUSTED MULTIPLIER  X  BPM  = ' },
          { color = 'norm', text = 'TARGET' },
          { color = 'white', text = 'LANE-SPEED  (RECOMMENDED)' },
        },
        {
          {
            color = 'white',
            text = 'CMOD : FUNCTIONALLY SIMILAR TO MMOD, BUT IGNORES BPM CHANGES  (DO NOT USE)'
          },
        }
      },
      name = 'MODE',
      options = {
        'XMOD',
        'MMOD',
        'CMOD',
      },
    },
    ['HiSpeed'] = {
      desc = {
        {
          { color = 'white', text = 'ADJUST THIS VALUE IF USING' },
          { color = 'norm', text = 'XMOD' },
        }
      },
      name = 'MULTIPLIER',
    },
    ['ModSpeed'] = {
      desc = {
        {
          { color = 'white', text = 'ADJUST THIS VALUE IF USING' },
          { color = 'norm', text = 'MMOD' },
        }
      },
      name = 'TARGET',
      special = 'LANE-SPEED',
    },
  },
  ['Game'] = {
    name = 'GAMEPLAY',
    ['Gauge'] = {
      desc = {
        'CURRENT GAUGE TYPE',
        {
          {
            color = 'white',
            text = 'EFFECTIVE :  0%  START, COMPLETE WITH  >=70%  FOR',
          },
          { color = 'pos', text = 'NORMAL CLEAR' },
        },
        {
          {
            color = 'white',
            text = 'EXCESSIVE :  100%  START, COMPLETE WITH  >0%  FOR',
          },
          { color = 'neg', text = 'HARD CLEAR' },
        },
        'PERMISSIVE :  100%  START,  SIMILAR TO EXCESSIVE BUT LESS DIFFICULT',
        'BLASTIVE :  100%  START;  SIMILAR TO EXCESSIVE BUT WITH ADJUSTABLE DIFFICULTY',
      },
      name = 'GAUGE TYPE',
      options = {
        'EFFECTIVE',
        'EXCESSIVE',
        'PERMISSIVE',
        'BLASTIVE',
      },
    },
    ['Blastive Rate Level'] = {
      desc = {
        'BLASTIVE RATE DIFFICULTY LEVEL',
        {
          { color = 'white', text = '0.50  -  2.00 : ' },
          { color = 'pos', text = 'NORMAL CLEAR' },
        },
        {
          { color = 'white', text = '>2.50 : ' },
          { color = 'neg', text = 'HARD CLEAR' },
        },
      },
      name = 'BLASTIVE RATE LEVEL',
    },
    ['Backup Gauge'] = {
      desc = {
        'BACKUP GAUGE  (ALTERNATIVE RATE SYSTEM  (ARS)) STATUS',
        {
          { color = 'white', text = 'GAUGE TYPE SWITCHES TO' },
          { color = 'norm', text = 'EFFECTIVE' },
          { color = 'white', text = 'UPON REACHING 0%' },
        },
      },
      invert = false,
      name = 'BACKUP GAUGE  (ARS)',
    },
    ['Random'] = {
      desc = {
        'RANDOM MODE STATUS',
        'BT OBJECTS APPEAR RANDOMLY',
        'FX OBJECTS MAY APPEAR RANDOMLY',
      },
      invert = false,
      name = 'RANDOM MODE',
    },
    ['Mirror'] = {
      desc = {
        'MIRROR MODE STATUS',
        'MIRRORS ALL OBJECTS HORIZONTALLY'
      },
      invert = false,
      name = 'MIRROR MODE',
    },
    ['Hide Backgrounds'] = {
      desc = { 'BACKGROUND STATUS' },
      invert = true,
      name = 'BACKGROUNDS',
    },
    ['Score Display'] = {
      desc = {
        'CURRENT SCORE DISPLAY MODE',
        'ADDITIVE : SCORE STARTS AT  0  (DEFAULT)',
        'SUBTRACTIVE : SCORE STARTS AT  10,000,000',
        'AVERAGE : SCORE STARTS AT  10,000,000',
      },
      name = 'SCORE DISPLAY MODE',
      options = {
        'ADDITIVE',
        'SUBTRACTIVE',
        'AVERAGE',
      },
    },
    ['Autoplay'] = {
      desc = { 'STARTS THE SELECTED SONG IN AUTOPLAY MODE' },
      name = 'START AUTOPLAY',
    },
    ['Practice'] = {
      desc = { 'STARTS THE SELECTED SONG IN PRACTICE MODE' },
      name = 'START PRACTICE MODE',
    },
  },
  ['Hid/Sud'] = {
    name = 'HIDDEN AND SUDDEN',
    ['Enable Hidden / Sudden'] = {
      desc = { 'HIDDEN  /  SUDDEN STATUS' },
      invert = false,
      name = 'STATUS',
    },
    ['Hidden Cutoff'] = {
      desc = { 'CUTOFF FROM TRACK START TO END' },
      name = 'HIDDEN CUTOFF',
    },
    ['Hidden Fade'] = {
      desc = { 'AMOUNT OF HIDDEN FADING' },
      name = 'HIDDEN FADE',
    },
    ['Sudden Cutoff'] = {
      desc = { 'CUTOFF FROM TRACK END TO START' },
      name = 'SUDDEN CUTOFF',
    },
    ['Sudden Fade'] = {
      desc = { 'AMOUNT OF SUDDEN FADING' },
      name = 'SUDDEN FADE',
    },
    ['Show Track Cover'] = {
      desc = { 'TRACK COVER STATUS' },
      invert = false,
      name = 'TRACK COVER',
    },
  },
  ['Judgement'] = {
    name = 'HIT WINDOWS',
    ['Crit Window'] = {
      desc = { 'TIMING WINDOW FOR BUTTON CRITICAL JUDGEMENT' },
      name = 'CRITICAL WINDOW',
      special = 'TIME WINDOW',
    },
    ['Near Window'] = {
      desc = { 'TIMING WINDOW FOR BUTTON NEAR JUDGEMENT' },
      name = 'NEAR WINDOW',
      special = 'TIME WINDOW',
    },
    ['Hold Window'] = {
      desc = { 'TIMING WINDOW FOR HOLD JUDGEMENT' },
      name = 'HOLD WINDOW',
      special = 'TIME WINDOW',
    },
    ['Slam Window'] = {
      desc = { 'TIMING WINDOW FOR LASER SLAM JUDGEMENT' },
      name = 'SLAM WINDOW',
      special = 'TIME WINDOW',
    },
    ['Set to NORMAL'] = {
      desc = {
        'SETS THE CRITICAL AND NEAR TIMING WINDOWS TO DEFAULT JUDGEMENT',
        'CRITICAL :  +/- 46 ms',
        'NEAR :  +/- 150 ms',
      },
      name = 'SET TO DEFAULT VALUES',
    },
    ['Set to HARD'] = {
      desc = {
        'SETS THE CRITICAL AND NEAR TIMING WINDOWS TO HARD JUDGEMENT',
        'CRITICAL :  +/- 23 ms',
        'NEAR :  +/- 75 ms',
      },
      name = 'SET TO HARD VALUES',
    },
  },
};