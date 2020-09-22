local CONTROL_LIST = require('constants/controls');

local _ = {
  cache = {
    resX = 0,
    resY = 0
  },
  buttonY = 0,
  hoveredPage = nil,
  maxPages = 8,
  mousePosX = 0,
  mousePosY = 0,
  selectedPage = nil
};

_.initializeButton = function(self)
  font.medium();

  local button = {
    [1] = {
      label = cacheLabel('GENERAL', 36),
      page = 'general'
    },
    [2] = {
      label = cacheLabel('SONG SELECT', 36),
      page = 'songSelect'
    },
    [3] = {
      label = cacheLabel('GAMEPLAY SETTINGS', 36),
      page = 'gameplaySettings'
    },
    [4] = {
      label = cacheLabel('GAMEPLAY', 36),
      page = 'gameplay'
    },
    [5] = {
      label = cacheLabel('PRACTICE MODE', 36),
      page = 'practiceMode'
    },
    [6] = {
      label = cacheLabel('RESULTS', 36),
      page = 'results'
    },
    [7] = {
      label = cacheLabel('MULTIPLAYER', 36),
      page = 'multiplayer'
    },
    [8] = {
      label = cacheLabel('NAUTICA', 36),
      page = 'nautica'
    },
    activePage = 1,
    startEsc = cacheLabel('[START]  /  [ESC]', 24),
    close = cacheLabel('CLOSE', 24),
    maxWidth = 0
  };

  button.drawButton = function(self, x, y, i, isActive)
    gfx.BeginPath();

    if (isActive) then
      fill.normal()
    else
      fill.white(80);
    end
  
    align.left();
    self[i].label:draw({ x = x, y = y });

    if (_:mouseClipped(x - 20, y - 10, self[i].label.w + 40, self[i].label.h + 30)) then
      _.hoveredPage = i;
    end

    if (self[i].label.w > self.maxWidth) then
      self.maxWidth = self[i].label.w;
    end

    return self[i].label.h * 2;
  end

  return button;
end

_.initializeControls = function(self)
  local controls = {
    general = {},
    songSelect = {},
    gameplaySettings = {},
    gameplay = {},
    practiceMode = {},
    results = {},
    multiplayer = {},
    nautica = {},
  };

  for category, list in pairs(controls) do
    for i = 1, #CONTROL_LIST[category] do
      list[i] = {};

      font.normal();
      list[i].action = cacheLabel(CONTROL_LIST[category][i].action, 24);

      font.medium();
      list[i].controller = cacheLabel(CONTROL_LIST[category][i].controller, 24);
      list[i].keyboard = cacheLabel(CONTROL_LIST[category][i].keyboard, 24);

      if (CONTROL_LIST[category][i].lineBreak) then
        list[i].lineBreak = true;
      end

      if (CONTROL_LIST[category][i].note) then
        list[i].note = true;
      end
    end
  end

  controls.drawControls = function(self, category, initialX, initialY)
    local list = self[category];
    local x = initialX;
    local y = initialY;

    gfx.BeginPath();
    align.left();
    fill.white();

    _.controller:draw({ x = x, y = y });
    _.keyboard:draw({ x = x + 350, y = y });

    y = y + 60;

    for i = 1, #list do
      if (list[i].note) then
        fill.white();
      else
        fill.normal();
      end
      list[i].controller:draw({ x = x, y = y });

      list[i].keyboard:draw({ x = x + 350, y = y });

      fill.white();
      list[i].action:draw({ x = x + 700, y = y });

      if ((i ~= #list) and (not list[i].note)) then
        gfx.BeginPath();
        fill.normal(100);
        gfx.FastRect(x + 1, y + 38, _.layout.scaledW / 1.65, 2);
        gfx.Fill();
      end

      if (list[i].lineBreak) then
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

    if ((_.cache.resX ~= resX) or (_.cache.resY ~= resY)) then
      self.scaledW = 1920;
      self.scaledH = self.scaledW * (resY / resX);
      self.scalingFactor = resX / self.scaledW;

      _.cache.resX = resX;
      _.cache.resY = resY;
    end
  end

  layout:setupLayout();

  return layout;
end

_.initializeAll = function(self, selection)
  self.mouseClipped = function(self, x, y, w, h)
    local scaledX = x * self.layout.scalingFactor;
    local scaledY = y * self.layout.scalingFactor;
    local scaledW = scaledX + (w * self.layout.scalingFactor);
    local scaledH = scaledY + (h * self.layout.scalingFactor);

    return (self.mousePosX > scaledX)
      and (self.mousePosY > scaledY)
      and (self.mousePosX < scaledW)
      and (self.mousePosY < scaledH);
  end

  font.medium();
  self.heading = cacheLabel('CONTROLS', 60);
  self.controller = cacheLabel('CONTROLLER', 30);
  self.keyboard = cacheLabel('KEYBOARD', 30);

  self.button = self:initializeButton();
  self.controls = self:initializeControls();
  self.layout = self:initializeLayout();
end

_.render = function(self, deltaTime, showControls, selectedPage)
  if (not showControls) then return end;

  self.selectedPage = selectedPage or 1;

  self.layout:setupLayout();

  self.mousePosX, self.mousePosY = game.GetMousePos();

  gfx.BeginPath();
  fill.black(170);
  gfx.FastRect(0, 0, self.layout.scaledW, self.layout.scaledH);
  gfx.Fill();

  local x = self.layout.scaledW / 20;
  local y = self.layout.scaledH / 20;

  gfx.BeginPath();
  align.left();
  fill.white();
  self.heading:draw({ x = x - 3, y = y });

  self.buttonY = y + self.heading.h * 2;
  self.hoveredPage = nil;

  for category = 1, self.maxPages do
    self.buttonY = self.buttonY + self.button:drawButton(
      x,
      self.buttonY,
      category,
      category == self.selectedPage
    );
  end

  gfx.BeginPath();
  fill.white();
  gfx.FastRect(
    x + self.button.maxWidth + 75,
    y + (self.heading.h * 2) + 10,
    4,
    self.layout.scaledH * 0.475
  );
  gfx.Fill();

  self.controls:drawControls(
    self.button[self.selectedPage].page,
    x + self.button.maxWidth + 150,
    y + (self.heading.h * 2)
  );

  gfx.BeginPath();
  align.left();
  fill.normal();
  self.button.startEsc:draw({
    x = x,
    y = y + self.layout.scaledH - (self.layout.scaledH / 7)
  });

  fill.white();
  self.button.close:draw({
    x = x + self.button.startEsc.w + 8,
    y = y + self.layout.scaledH - (self.layout.scaledH / 7)
  });

  return self.hoveredPage;
end

return _;