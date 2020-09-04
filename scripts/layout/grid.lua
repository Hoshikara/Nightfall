CONSTANTS = require('constants/songwheel');

local _ = {
  ['dropdown'] = {
    [1] = {},
    [2] = {},
    [3] = {},
    ['padding'] = 24,
    ['start'] = 0,
    ['y'] = 0
  },
  ['field'] = {
    [1] = {},
    [2] = {},
    [3] = {},
    ['y'] = 0
  },
  ['grid'] = {},
  ['labels'] = nil,
};

_.setAllSizes = function(self, scaledW, scaledH)
  if (not self['labels']) then
    gfx.LoadSkinFont('GothamMedium.ttf');

    self['labels'] = {};

    for name, str in pairs(CONSTANTS['labels']['grid']) do
      self['labels'][name] = gfx.CreateLabel(str, 18, 0);
    end

    self['tempLabel'] = gfx.CreateLabel('TEMPLABEL', 24, 0);

    self['field']['height'] = getLabelInfo(self['tempLabel'])['h'];
    self['labels']['height'] = getLabelInfo(self['labels']['sort'])['h'];
  end

  self['jacketSize'] = scaledH / 4;
  self['grid']['gutter'] = self['jacketSize'] / 8;
  self['grid']['size'] = (self['jacketSize'] + self['grid']['gutter']) * 4;
  self['grid']['x'] = scaledW - self['grid']['size'] + (self['grid']['gutter'] * 7);

  self['labels']['spacing'] = (self['jacketSize'] * 2) / 3.5;
  self['labels']['x'] = self['grid']['x'];
  self['labels']['y'] = scaledH / 20;

  self['field'][1]['x'] = self['labels']['x'] - 4;
  self['field'][2]['x'] = self['field'][1]['x']
    + getLabelInfo(self['labels']['sort'])['w']
    + self['labels']['spacing'];
  self['field'][3]['x'] = self['field'][2]['x']
    + getLabelInfo(self['labels']['difficulty'])['w']
    + self['labels']['spacing'];
  self['field']['y'] = self['labels']['y'] + (self['labels']['height'] * 1.25);

  self['dropdown'][1]['x'] = self['field'][1]['x'] + 2;
  self['dropdown'][2]['x'] = self['field'][2]['x'];
  self['dropdown'][3]['x'] = self['field'][3]['x'];
  self['dropdown'][3]['maxWidth'] = (self['jacketSize'] * 1.65) - (self['dropdown']['padding'] * 2);
  self['dropdown']['start'] = self['dropdown']['padding'] - 7;
  self['dropdown']['y'] = self['field']['y'] + (self['field']['height'] * 1.25);
end

return _;