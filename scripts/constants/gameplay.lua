local _ = {
  clearStates = {
    'TRACK CRASH',
    'TRACK COMPLETE',
    'TRACK COMPLETE',
    'ULTIMATE CHAIN',
    'PERFECT ULTIMATE CHAIN',
  },
  difficulties = {
    'NOVICE',
    'ADVANCED',
    'EXHAUST',
    'MAXIMUM',
  },
  ['settings'] = {
    {
      {
        label = 'USE CURRENT TIME AS START POINT',
      },
      {
        label = 'USE CURRENT TIME AS END POINT',
      },
      {
        label = 'AUTO-RESTART ON PASS',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'AUTO-RESTART ON FAIL',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'CONTROLLER INPUTS FOR SETUP',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'SONG SPEED',
        values = {
          type = 'PERCENTAGE',
          value = 100,
        },
      },
      {
        label = 'BEGIN PRACTICE',
      },
      {
        label = 'EXIT',
      },
    },
    {
      {
        label = 'SET START POINT',
      },
      {
        label = 'MEASURE',
        values = {
          value = '0'
        },
        indent = true,
      },
      {
        label = 'TIME',
        values = {
          type = 'TIME',
          value = '0',
        },
        indent = true,
      },
      {
        label = 'SET END POINT',
      },
      {
        label = 'MEASURE',
        values = {
          value = '0',
        },
        indent = true,
      },
      {
        label = 'TIME',
        values = {
          type = 'TIME',
          value = '0',
        },
        indent = true,
      },
      {
        label = 'CLEAR START POINT',
      },
      {
        label = 'CLEAR END POINT',
      },
    },
    {
      {
        label = 'AUTO-RESTART ON PASS',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'AUTO-RESTART ON FAIL',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'AUTO-INCREASE SONG SPEED ON PASS',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'SONG SPEED INCREASE INCREMENT',
        values = {
          type = 'PERCENTAGE',
          value = '0',
        },
        indent = true,
      },
      {
        label = 'PASS STREAK REQUIREMENT',
        values = {
          value = '1',
        },
        indent = true,
      },
      {
        label = 'AUTO-DECREASE SONG SPEED ON FAIL',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'SONG SPEED DECREASE DECREMENT',
        values = {
          type = 'PERCENTAGE',
          value = '0',
        },
        indent = true,
      },
      {
        label = 'MINIMUM SONG SPEED',
        values = {
          type = 'PERCENTAGE',
          value = '0',
        },
        indent = true,
      },
      {
        label = 'AUTO-RESTART FROM MEASURE',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'MEASURE',
        values = {
          value = '1',
        },
        indent = true,
      },
    },
    {
      {
        label = 'FAIL CONDITION',
        values = {
          'NONE',
          'SCORE',
          'GRADE',
          'MISS',
          'MISS AND NEAR',
          'GAUGE',
        },
      },
      {
        label = 'SCORE CANNOT FALL BELOW',
        values = {
          value = '10000000',
        },
      },
      {
        label = 'GRADE CANNOT FALL BELOW',
        values = {
          'D',
          'C',
          'B',
          'A',
          'A+',
          'AA',
          'AA+',
          'AAA',
          'AAA+',
          'S',
          '995',
          '998',
          '999',
          'PUC',
        },
      },
      {
        label = 'MISS COUNT CANNOT EXCEED',
        values = {
          value = '0',
        },
      },
      {
        label = 'MISS AND NEAR COUNT CANNOT EXCEED',
        values = {
          value = '0',
        },
      },
      {
        label = 'GAUGE CANNOT FALL BELOW',
        values = {
          type = 'PERCENTAGE',
          value = '0',
        },
      },
    },
    {
      {
        label = 'GLOBAL OFFSET',
        values = {
          type = 'TIME',
          value = '0',
        },
      },
      {
        label = 'CURRENT SONG OFFSET',
        values = {
          type = 'TIME',
          value = '0',
        },
      },
      {
        label = 'TEMPORARY SONG OFFSET',
        values = {
          type = 'TIME',
          value = '0',
        },
      },
      {
        label = 'LEAD-IN TIME',
        values = {
          type = 'TIME',
          value = '0',
        },
      },
      {
        label = 'CONTROLLER INPUTS FOR SETUP',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
      {
        label = 'AUTO-RETURN TO SETUP AFTER RESULTS',
        values = {
          ['true'] = 'ENABLED',
          ['false'] = 'DISABLED',
        },
      },
    },
  },
  tabs = {
    'GENERAL',
    'LOOP CONTROLS',
    'LOOP SETTINGS',
    'MISSION SETTINGS',
    'SETTINGS',
  },
};

return _;