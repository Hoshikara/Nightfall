local _ = {
  ['clears'] = {
    [1] = 'COMPLETE',
    [2] = 'NORMAL',
    [3] = 'HARD',
    [4] = 'UC',
    [5] = 'PUC'
  },
  ['controls'] = {
    [1] = '[TAB]',
    [2] = '[FX-R]',
    [3] = '[FX-L]  >  [START]',
    [4] = '[FX-L]'
  },
  ['difficulties'] = {
    [1] = 'NOVICE',
    [2] = 'ADVANCED',
    [3] = 'EXHAUST',
    [4] = 'MAXIMUM'
  },
  ['grades'] = {
    [1] = {
      ['minimum'] = 9900000,
      ['grade'] = 'S'
    },
    [2] = {
      ['minimum'] = 9800000,
      ['grade'] = 'AAA+'
    },
    [3] = {
      ['minimum'] = 9700000,
      ['grade'] = 'AAA'
    },
    [4] = {
      ['minimum'] = 9500000,
      ['grade'] = 'AA+'
    },
    [5] = {
      ['minimum'] = 9300000,
      ['grade'] = 'AA'
    },
    [6] = {
      ['minimum'] = 9000000,
      ['grade'] = 'A+'
    },
    [7] = {
      ['minimum'] = 8700000,
      ['grade'] = 'A'
    },
    [8] = {
      ['minimum'] = 7500000,
      ['grade'] = 'B'
    },
    [9] = {
      ['minimum'] = 6500000,
      ['grade'] = 'C'
    },
    [10] = {
      ['minimum'] = 0,
      ['grade'] = 'D'
    }
  },
  ['labels'] = {
    ['grid'] = {
      ['collection'] = 'COLLECTION',
      ['difficulty'] = 'DIFFICULTY',
      ['sort'] = 'SORT'
    },
    ['info'] = {
      ['artist'] = 'ARTIST',
      ['bpm'] = 'BPM',
      ['clear']= 'CLEAR',
      ['difficulty'] = 'DIFFICULTY',
      ['effector'] = 'EFFECTOR',
      ['grade'] = 'GRADE',
      ['highScore'] = 'HIGH SCORE',
      ['title'] = 'TITLE'
    }
  },
  ['levels'] = {
    [1] = '01',
    [2] = '02',
    [3] = '03',
    [4] = '04',
    [5] = '05',
    [6] = '06',
    [7] = '07',
    [8] = '08',
    [9] = '09',
    [10] = '10',
    [11] = '11',
    [12] = '12',
    [13] = '13',
    [14] = '14',
    [15] = '15',
    [16] = '16',
    [17] = '17',
    [18] = '18',
    [19] = '19',
    [20] = '20'
  },
  ['settings'] = {
    [1] = {
      [1] = {
        ['label'] = 'GLOBAL OFFSET',
        ['values'] = {
          [1] = ''
        }
      },
      [2] = {
        ['label'] = 'INPUT OFFSET',
        ['values'] = {
          [1] = ''
        }
      },
      [3] = {
        ['label'] = 'CURRENT SONG OFFSET',
        ['values'] = {
          [1] = ''
        }
      }
    },
    [2] = {
      [1] = {
        ['label'] = 'SPEED MOD',
        ['values'] = {
          [1] = 'XMOD',
          [2] = 'MMOD',
          [3] = 'CMOD'
        }
      },
      [2] = {
        ['label'] = 'HI-SPEED',
        ['values'] = {
          [1] = ''
        }
      },
      [3] = {
        ['label'] = 'MOD SPEED',
        ['values'] = {
          [1] = ''
        }
      }
    },
    [3] = {
      [1] = {
        ['label'] = 'GAUGE TYPE',
        ['values'] = {
          [1] = 'NORMAL',
          [2] = 'HARD'
        }
      },
      [2] = {
        ['label'] = 'RANDOM MODE',
        ['values'] = {
          [1] = 'DISABLED',
          [2] = 'ENABLED'
        }
      },
      [3] = {
        ['label'] = 'MIRROR MODE',
        ['values'] = {
          [1] = 'DISABLED',
          [2] = 'ENABLED'
        }
      },
      [4] = {
        ['label'] = 'BACKGROUNDS',
        ['values'] = {
          [1] = 'ENABLED',
          [2] = 'DISABLED'
        }
      },
      [5] = {
        ['label'] = 'SCORE DISPLAY MODE',
        ['values'] = {
          [1] = 'ADDITIVE',
          [2] = 'SUBTRACTIVE',
          [3] = 'AVERAGE'
        }
      },
      [6] = {
        ['label'] = 'AUTOPLAY'
      },
      [7] = {
        ['label'] = 'PRACTICE MODE'
      }
    },
    [4] = {
      [1] = {
        ['label'] = 'STATUS',
        ['values'] = {
          [1] = 'ENABLED',
          [2] = 'DISABLED'
        }
      },
      [2] = {
        ['label'] = 'HIDDEN CUTOFF',
        ['values'] = {
          [1] = ''
        }
      },
      [3] = {
        ['label'] = 'HIDDEN FADE',
        ['values'] = {
          [1] = ''
        }
      },
      [4] = {
        ['label'] = 'SUDDEN CUTOFF',
        ['values'] = {
          [1] = ''
        }
      },
      [5] = {
        ['label'] = 'SUDDEN FADE',
        ['values'] = {
          [1] = ''
        }
      },
      [6] = {
        ['label'] = 'TRACK COVER',
        ['values'] = {
          [1] = 'DISABLED',
          [2] = 'ENABLED'
        }
      }
    },
    [5] = {
      [1] = {
        ['label'] = 'CRITICAL WINDOW',
        ['values'] = {
          [1] = ''
        }
      },
      [2] = {
        ['label'] = 'NEAR WINDOW',
        ['values'] = {
          [1] = ''
        }
      },
      [3] = {
        ['label'] = 'HOLD WINDOW',
        ['values'] = {
          [1] = ''
        }
      },
      [4] = {
        ['label'] = 'DEFAULT VALUES'
      },
      [5] = {
        ['label'] = 'HARD VALUES'
      }
    }
  },
  ['sorts'] = {
    [1] = {
      ['name'] = 'TITLE',
      ['direction'] = 'down'
    },
    [2] = {
      ['name'] = 'TITLE',
      ['direction'] = 'up'
    },
    [3] = {
      ['name'] = 'SCORE',
      ['direction'] = 'down'
    },
    [4] = {
      ['name'] = 'SCORE',
      ['direction'] = 'up'
    },
    [5] = {
      ['name'] = 'DATE',
      ['direction'] = 'down'
    },
    [6] = {
      ['name'] = 'DATE',
      ['direction'] = 'up'
    },
    [7] = {
      ['name'] = 'ARTIST',
      ['direction'] = 'down'
    },
    [8] = {
      ['name'] = 'ARTIST',
      ['direction'] = 'up'
    },
    [9] = {
      ['name'] = 'EFFECTOR',
      ['direction'] = 'down'
    },
    [10] = {
      ['name'] = 'EFFECTOR',
      ['direction'] = 'up'
    }
  },
  ['tabs'] = {
    [1] = 'OFFSETS',
    [2] = 'HI-SPEED',
    [3] = 'GAME MODIFIERS',
    [4] = 'HIDDEN AND SUDDEN',
    [5] = 'HIT WINDOWS'
  }
};

return _;

