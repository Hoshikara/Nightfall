-- SettingsDiag Table

-- Song Select
SettingsDiag = {
  posX = 0.5,
  posY = 0.5,
  currentTab = 1 to #tabs,
  currentSetting = 1 to #tabs[currentTab].settings,
  tabs = {
    1 = {
      name = 'Offsets',
      settings = {
        1 = {
          name = 'Global Offset',
          type = 'int',
          value = 15,
          min = -200,
          max = 200
        },
        2 = {
          name = 'Input Offset',
          type = 'int',
          value = -3,
          min = -200,
          max = 200
        },
        3 = {
          name = 'Song Offset',
          type = 'int',
          value = 0,
          min = -200,
          max = 200
        }
      }
    },
    2 = {
      name = 'HiSpeed',
      settings = {
        1 = {
          name = 'Speed Mod',
          type = 'enum'
          value = 2,
          options = {
            1 = 'XMod',
            2 = 'MMod',
            3 = 'CMod'
          },
        },
        2 = {
          value = 6.66,
          min = 0.0,
          type = 'float',
          max = 16.0,
          name = 'HiSpeed'
        },
        3 = {
          name = 'ModSpeed',
          type = 'float',
          value = 800.0,
          min = 50.0,
          max = 1500.0
        }
      }
    },
    3 = {
      name = 'Game',
      settings = {
        1 = {
          name = 'Gauge',
          type = 'enum',
          value = 1,
          options = {
            1 = 'Normal',
            2 = 'Hard'
          },
        },
        2 = {
          name = 'Random',
          type = 'toggle',
          value = false
        },
        3 = {
          name = 'Mirror',
          type = 'toggle'
          value = false
        },
        4 = {
          name = 'Hide Backgrounds',
          type = 'toggle'
          value = true
        },
        5 = {
          name = 'Score Display',
          type = 'enum',
          value = 1,
          options = {
            1 = 'Additive',
            2 = 'Subtractive',
            3 = 'Average'
          }
        },
        6 = {
          name = 'Autoplay',
          type = 'button'
        },
        7 = {
          name = 'Practice',
          type = 'button'
        }
      }
    },
    4 = {
      name = 'Hid/Sud',
      settings = {
        1 = {
          name = 'Enable Hidden / Sudden',
          type = 'toggle',
          value = false
        },
        2 = {
          name = 'Hidden Cutoff',
          type = 'float',
          value = 0.0,
          min = 0.0,
          max = 1.0
        },
        3 = {
          name = 'Hidden Fade'
          type = 'float',
          value = 0.0,
          min = 0.0,
          max = 1.0
        },
        4 = {
          name = 'Sudden Cutoff'
          type = 'float',
          value = 1.0,
          min = 0.0,
          max = 1.0
        },
        5 = {
          name = 'Sudden Fade'
          type = 'float',
          value = 0.0,
          min = 0.0,
          max = 1.0
        },
        6 = {
          name = 'Show Track Cover',
          type = 'toggle'
          value = false
        }
      }
    },
    5 = {
      name = 'Judgement',
      settings = {
        1 = {
          name = 'Crit Window',
          type = 'int',
          value = 46,
          min = 0,
          max = 46
        },
        2 = {
          name = 'Near Window',
          type = 'int',
          value = 92,
          min = 0,
          max = 92
        },
        3 = {
          name = 'Hold Window'
          type = 'int',
          value = 138,
          min = 0,
          max = 138
        },
        4 = {
          name = 'Set to NORMAL',
          type = 'button'
        },
        5 = {
          name = 'Set to HARD',
          type = 'button'
        }
      }
    }
  }
};

-- Practice Mode
SettingsDiag = {
  posX = 0.75,
  posY = 0.75,
  currentTab = 1 to #tabs,
  currentSetting = 1 to #tabs[currentTab].settings,
  tabs = {
    1 = {
      name = 'Main',
      settings = {
        1 = {
          name = 'Set the start point (0ms) to here',
          type = 'button'
        },
        2 = {
          name = 'Set the end point (0ms) to here',
          type = 'button'
        },
        3 = {
          name = 'Loop on success',
          type = 'toggle',
          value = false,
        },
        4 = {
          name = 'Loop on fail',
          type = 'toggle',
          value = true
        },
        5 = {
          name = 'Enable navigation inputs for the setup',
          type = 'toggle',
          value = true,
        },
        6 = {
          name = 'Playback speed (%)',
          type = 'int',
          value = 100,
          min = 25,
          max = 100
        },
        7 = {
          name = 'Start practice',
          type = 'button'
        },
        8 = {
          name = 'Exit',
          type = 'button'
        }
      }
    },
    2 = {
      name = 'Looping',
      settings = {
        1 = {
          name = 'Set the start point to here',
          type = 'button'
        },
        2 = {
          name = '- in measure no.',
          type = 'int',
          value = 1
          min = 1,
          max = 90
        },
        3 = {
          name = '- in milliseconds',
          type = 'int',
          value = 0,
          min = 0,
          max = 125779
        },
        4 = {
          name = 'Set the end point to here',
          type = 'button'
        },
        5 = {
          name = '- in measure no.',
          type = 'int',
          value = 1,
          min = 1,
          max = 90
        },
        6 = {
          name = '- in milliseconds',
          type = 'int',
          value = 0,
          min = 0,
          max = 125779
        },
        7 = {
          name = 'Clear the start point',
          type = 'button'
        },
        8 = {
          name = 'Clear the end point',
          type = 'button'
        }
      }
    },
    3 = {
      name = 'LoopControl',
      settings = {
        1 = {
          name = 'Loop on success',
          type = 'toggle',
          value = false
        },
        2 = {
          name = 'Loop on fail',
          type = 'toggle',
          value = true
        },
        3 = {
          name = 'Increase speed on success',
          type = 'toggle',
          value = false
        },
        4 = {
          name = '- increment (%p)',
          type = 'int',
          value = 0,
          min = 1,
          max = 10
        },
        5 = {
          name = '- required streakes',
          type = 'int',
          value = 1
          min = 1,
          max = 10
        },
        6 = {
          name = 'Decrease speed on fail',
          type = 'toggle',
          value = false
        },
        7 = {
          name = '- decrement (%p)',
          type = 'int',
          value = 0
          min = 1,
          max = 10
        },
        8 = {
          name = '- minimum speed (%)',
          type = 'int',
          value = 10,
          min = 1,
          max = 10
        },
        9 = {
          name = 'Set maximum amount of rewinding on fail',
          type = 'toggle',
          value = false
        },
        10 = {
          name = '- amount in # of measures',
          type = 'int',
          value = 1,
          min = 0,
          max = 20
        }
      }
    },
    4 = {
      name = 'Mission',
      settings = {
        1 = {
          name = 'Fail condition',
          type = 'enum',
          value = 1,
          options = {
            1 = 'None',
            2 = 'Score',
            3 = 'Grade',
            4 = 'Miss',
            5 = 'MissAndNear',
            6 = 'Gauge'
          }
        },
        2 = {
          name = 'Score less than',
          type = 'int',
          value = 10000000,
          min = 8000000,
          max = 10000000
        },
        3 = {
          name = 'Grade less than',
          type = 'enum',
          value = 14,
          options = {
            1 = 'D',
            2 = 'C',
            3 = 'B',
            4 = 'A',
            5 = 'A+',
            6 = 'AA',
            7 = 'AA+',
            8 = 'AAA',
            9 = 'AAA+',
            10 = 'S',
            11 = '995',
            12 = '998',
            13 = '999',
            14 = 'PUC'
          }
        },
        4 = {
          name = 'Miss more than',
          type = 'int',
          value = 0,
          min = 0,
          max = 100
        },
        5 = {
          name = 'Miss+Near more than',
          type = 'int',
          value = 0,
          min = 0,
          max = 100

        },
        6 = {
          name = 'Gauge less than',
          type = 'int',
          value = 0,
          min = 0,
          max = 100
        }
      }
    },
    5 = {
      name = 'Settings',
      settings = {
        1 = {
          name = 'Global offset',
          type = 'int',
          value = 15,
          min = -200,
          max = 200
        },
        2 = {
          name = 'Chart offset',
          type = 'int',
          value = 0,
          min = -200,
          max = 200
        },
        3 = {
          name = 'Temporary offset',
          type = 'int',
          value = 0,
          min = -200,
          max = 200
        },
        4 = {
          name = 'Lead-in time for practices (ms)',
          type = 'int',
          value = 1500
          min = 250,
          max = 10000
        },
        5 = {
          name = 'Enable navigation inputs for the setup',
          type = 'toggle'
          value = true
        },
        6 = {
          name = 'Revert to the setup after the result is shown',
          type = 'toggle'
          value = false
        }
      }
    }
  }
};
