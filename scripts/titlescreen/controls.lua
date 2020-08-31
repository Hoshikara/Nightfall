controlList = require('constants/controls');

local _ = {
  ['initialized'] = false,
  ['buttonY'] = 0,
  ['colors'] = {
    ['action'] = {255, 255, 255, 255},
    ['button'] = {60, 110, 150, 255}
  },
  ['hoveredPage'] = nil,
  ['maxPages'] = 7,
  ['mousePosX'] = 0,
  ['mousePosY'] = 0,
  ['selectedPage'] = nil
};

_.initializeButton = function(self)
  gfx.LoadSkinFont('GothamMedium.ttf');

  local button = {
    [1] = {
      ['label'] = gfx.CreateLabel('GENERAL', 40, 0),
      ['page'] = 'general'
    },
    [2] = {
      ['label'] = gfx.CreateLabel('SONG SELECT', 40, 0),
      ['page'] = 'songSelect'
    },
    [3] = {
      ['label'] = gfx.CreateLabel('GAMEPLAY SETTINGS', 40, 0),
      ['page'] = 'gameplaySettings'
    },
    [4] = {
      ['label'] = gfx.CreateLabel('GAMEPLAY', 40, 0),
      ['page'] = 'gameplay'
    },
    [5] = {
      ['label'] = gfx.CreateLabel('RESULTS', 40, 0),
      ['page'] = 'results'
    },
    [6] = {
      ['label'] = gfx.CreateLabel('MULTIPLAYER', 40, 0),
      ['page'] = 'multiplayer'
    },
    [7] = {
      ['label'] = gfx.CreateLabel('NAUTICA', 40, 0),
      ['page'] = 'nautica'
    },
    ['activePage'] = 1,
    ['close'] = gfx.CreateLabel('[START]  /  [ESC] CLOSE', 30, 0),
    ['width'] = 300,
    ['height'] = 45,
    ['maxWidth'] = 0
  };

  button.drawButton = function(self, x, y, i, isActive)
    local w, h = gfx.LabelSize(self[i]['label']);
    local r = (isActive and 60) or 255;
    local g = (isActive and 110) or 255;
    local b = (isActive and 150) or 255;
    local a = (isActive and 255) or 80;

    gfx.BeginPath();
    gfx.FillColor(r, g, b, a);
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM);
    gfx.DrawLabel(self[i]['label'], x, y + (self['height'] / 2), -1);

    if (_:mouseClipped(x - 20, y - 25, w + 40, h + 35)) then
      _['hoveredPage'] = i;
    end

    if (w > self['maxWidth']) then
      self['maxWidth'] = w;
    end

    return (h + 40);
  end

  return button;
end

_.initializeControls = function(self)
  local controls = {
    ['general'] = {},
    ['songSelect'] = {},
    ['gameplaySettings'] = {},
    ['gameplay'] = {},
    ['results'] = {},
    ['multiplayer'] = {},
    ['nautica'] = {}
  };

  for category, list in pairs(controls) do
    for i = 1, #controlList[category] do
      local size = (controlList[category][i]['heading'] and 32) or 28;
      list[i] = {};

      gfx.LoadSkinFont('GothamBook.ttf');
      list[i]['action'] = gfx.CreateLabel(controlList[category][i]['action'], size, 0);

      gfx.LoadSkinFont('GothamMedium.ttf');
      list[i]['button'] = gfx.CreateLabel(controlList[category][i]['button'], size, 0);

      if (controlList[category][i]['heading']) then
        list[i]['heading'] = true;
      elseif (controlList[category][i]['lineBreak']) then
        list[i]['lineBreak'] = true;
      end
    end
  end

  controls.drawControls = function(self, category, initialX, initialY)
    local list = self[category];
    local y = initialY;

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM);

    for i = 1, #list do
      local x = (list[i]['heading'] and initialX) or initialX + 35;

      if (list[i]['heading']) then
        gfx.FillColor(255, 255, 255, 255);
      else
        gfx.FillColor(unpack(_['colors']['button']));
      end

      gfx.DrawLabel(list[i]['button'], x, y, -1);

      gfx.FillColor(unpack(_['colors']['action']));
      gfx.DrawLabel(list[i]['action'], x + 325 , y, -1);

      if (list[i]['lineBreak']) then
        y = y + 90;
      else
        y = y + 45;
      end
    end
  end

  return controls;
end

_.initializeLayout = function(self)
  local layout = {};

  layout.setupLayout = function(self)
    local resX, resY = game.GetResolution();

    self['scaledW'] = 1920;
    self['scaledH'] = self['scaledW'] * (resY / resX);
    self['scalingFactor'] = resX / self['scaledW'];
    self['padding'] = self['scaledH'] / 12;
  end

  layout:setupLayout();

  return layout;
end

_.initializeAll = function(self, selection)
  self.mouseClipped = function(self, x, y, w, h)
    local scaledX = x * self['layout']['scalingFactor'];
    local scaledY = y * self['layout']['scalingFactor'];
    local scaledW = scaledX + (w * self['layout']['scalingFactor']);
    local scaledH = scaledY + (h * self['layout']['scalingFactor']);

    return (self['mousePosX'] > scaledX)
      and (self['mousePosY'] > scaledY)
      and (self['mousePosX'] < scaledW)
      and (self['mousePosY'] < scaledH);
  end

  gfx.LoadSkinFont('GothamBold.ttf');
  self['heading'] = gfx.CreateLabel('CONTROLS', 60, 0);

  self['button'] = self:initializeButton();

  self['controls'] = self:initializeControls();

  self['layout'] = self:initializeLayout();

  self['initialized'] = true;
end

_.render = function(self, deltaTime, showControls, selectedPage)
  if (not showControls) then return end;

  self['selectedPage'] = selectedPage or 1;

  self['layout']:setupLayout();

  self['mousePosX'], self['mousePosY'] = game.GetMousePos();

  gfx.BeginPath();
  gfx.FillColor(0, 0, 0, 170);
  gfx.FastRect(0, 0, self['layout']['scaledW'], self['layout']['scaledH']);
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(255, 255, 255, 255);
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_BOTTOM);
  gfx.DrawLabel(
    self['heading'],
    self['layout']['padding'],
    self['layout']['padding'] * 1.5
  );
  gfx.FillColor(60, 110, 150, 255);
  gfx.DrawLabel(
    self['button']['close'],
    self['layout']['padding'],
    self['layout']['scaledH'] - self['layout']['padding']
  );

  self['buttonY'] = self['layout']['padding'] * 2.5;
  self['hoveredPage'] = nil;

  for category = 1, self['maxPages'] do
    self['buttonY'] = self['buttonY'] + self['button']:drawButton(
      self['layout']['padding'],
      self['buttonY'],
      category,
      category == self['selectedPage']
    );
  end

  gfx.BeginPath();
  gfx.FillColor(255, 255, 255, 255);
  gfx.FastRect(
    self['layout']['padding'] + self['button']['maxWidth'] + 75,
    (self['layout']['padding'] * 2.25) + 18,
    4,
    self['layout']['scaledH'] * 0.475
  );
  gfx.Fill();

  self['controls']:drawControls(
    self['button'][self['selectedPage']]['page'],
    self['layout']['padding'] + self['button']['maxWidth'] + 150,
    (self['layout']['padding'] * 2.25) + 39
  );

  return self['hoveredPage'];
end

return _;