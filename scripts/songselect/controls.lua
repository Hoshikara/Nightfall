local CONTROL_LIST = require('constants/controls');

local _ = {
  buttons = nil,
  cache = { scaledW = 0, scaledH = 0 },
  controls = nil,
  headings = nil,
  headingY = 0,
  pages = {
    'general',
    'songSelect',
    'gameplaySettings',
    'gameplay',
    'practiceMode',
    'results',
  },
  pressedBTD = false,
  scaledW = 0,
  scaledH = 0,
  selectedPage = 1,
  timer = 0,

  setSizes = function(self, scaledW, scaledH)
    if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
      self.scaledW = scaledW;
      self.scaledH = scaledH;
      self.x = scaledW / 20;
      self.y = scaledH / 20;

      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
  end,

  setControls = function(self)
    if (not self.controls) then
      self.controls = {
        general = {},
        songSelect = {},
        gameplaySettings = {},
        gameplay = {},
        practiceMode = {},
        results = {}
      };
    
      for category, list in pairs(self.controls) do
        for i = 1, #CONTROL_LIST[category] do
          list[i] = {};
    
          Font.Normal();
          list[i].action = Label.New(CONTROL_LIST[category][i].action, 24);
    
          Font.Medium();
          list[i].controller = Label.New(CONTROL_LIST[category][i].controller, 24);
          list[i].keyboard = Label.New(CONTROL_LIST[category][i].keyboard, 24);
    
          if (CONTROL_LIST[category][i].lineBreak) then
            list[i].lineBreak = true;
          end

          if (CONTROL_LIST[category][i].note) then
            list[i].note = true;
          end
        end
      end
    end
  end,

  setHeadings = function(self)
    if (not self.headings) then
      Font.Medium();

      self.headings = {
        main = Label.New('CONTROLS', 60),
        general = Label.New('GENERAL', 36),
        songSelect = Label.New('SONG SELECT', 36),
        gameplaySettings = Label.New('GAMEPLAY SETTINGS', 36),
        gameplay = Label.New('GAMEPLAY', 36),
        practiceMode = Label.New('PRACTICE MODE', 36),
        results = Label.New('RESULTS', 36),
        controller = Label.New('CONTROLLER', 30),
        keyboard = Label.New('KEYBOARD', 30),
        btd = Label.New('[BT-D]', 24),
        next = Label.New('NEXT PAGE', 24),
        maxWidth = 0
      };
    end
  end,

  drawControls = function(self, list, initialX, initialY)
    local alpha = math.floor(255 * self.timer);
    local x = initialX;
    local y = initialY;

    gfx.BeginPath();
    FontAlign.Left();

    self.headings.controller:draw({
      x = x,
      y = y,
      a = alpha,
      color = 'White',
    });
    self.headings.keyboard:draw({
      x = x + 350,
      y = y,
      a = alpha,
      color = 'White',
    });

    y = y + 60;

    for i = 1, #list do
      list[i].controller:draw({
        x = x,
        y = y,
        a = alpha,
        color = (list[i].note and 'White') or 'Normal',
      });

      list[i].keyboard:draw({
        x = x + 350,
        y = y,
        a = alpha,
        color = (list[i].note and 'White') or 'Normal',
      });

      list[i].action:draw({
        x = x + 700,
        y = y,
        a = alpha,
        color = 'White',
      });

      if ((i ~= #list) and (not list[i].note)) then
        gfx.BeginPath();
        Fill.Normal(100 * self.timer)
        gfx.FastRect(x + 1, y + 38, self.scaledW / 1.65, 2);
        gfx.Fill();
      end

      if (list[i].lineBreak) then
        y = y + 90;
      else
        y = y + 45;
      end
    end
  end,

  drawHeading = function(self, x, y, page, isActive)
    local heading = self.headings[page];

    gfx.BeginPath();

    FontAlign.Left();
    heading:draw({
      x = x,
      y = y,
      a = (isActive and (255 * self.timer)) or (80 * self.timer),
      color = (isActive and 'Normal') or 'White',
    });

    if (heading.w > self.headings.maxWidth) then
      self.headings.maxWidth = heading.w;
    end

    return (heading.h * 2);
  end,

  drawScreen = function(self)
    local alpha = math.floor(255 * self.timer);

    gfx.BeginPath()
    Fill.Black(235 * self.timer);
    gfx.FastRect(0, 0, self.scaledW, self.scaledH);
    gfx.Fill();

    gfx.Save();

    gfx.Translate(self.x, self.y);

    gfx.BeginPath();
    FontAlign.Left();
    self.headings.main:draw({
      x = -3,
      y = 0,
      a = alpha,
      color = 'White',
    });

    self.headingY = self.headings.main.h * 2;

    for category = 1, #self.pages do
      self.headingY = self.headingY+ self:drawHeading(
        0,
        self.headingY,
        self.pages[category],
        category == self.selectedPage
      );
    end

    gfx.BeginPath();
    Fill.White(alpha);
    gfx.FastRect(
      self.headings.maxWidth + 75,
      (self.headings.main.h * 2) + 10,
      4,
      self.scaledH / 2.75
    );
    gfx.Fill();

    self:drawControls(
      self.controls[self.pages[self.selectedPage]],
      self.headings.maxWidth + 150,
      self.headings.main.h * 2
    );

    gfx.BeginPath();
    FontAlign.Left();
    self.headings.btd:draw({
      x = 0,
      y = self.scaledH - (self.scaledH / 7),
      a = alpha,
      color = 'Normal',
    });

    self.headings.next:draw({
      x = self.headings.btd.w + 8,
      y = self.scaledH - (self.scaledH / 7) + 1,
      a = alpha,
      color = 'White',
    });

    gfx.Restore();
  end,

  render = function(self, deltaTime, displaying, scaledW, scaledH)
    self:setControls();

    self:setHeadings();

    self:setSizes(scaledW, scaledH);

    if (not displaying) then
      if (game.GetButton(game.BUTTON_BTA)) then
        self.timer = math.min(self.timer + (deltaTime * 8), 1);
      elseif (self.timer > 0) then
        self.timer = math.max(self.timer - (deltaTime * 6), 0);
      end

      if ((not self.pressedBTD) and game.GetButton(game.BUTTON_BTD)) then
        if (self.selectedPage + 1 > #self.pages) then
          self.selectedPage = 1;
        else
          self.selectedPage = self.selectedPage + 1;
        end
      end
    end

    self.pressedBTD = game.GetButton(game.BUTTON_BTD);

    gfx.Save();

    self:drawScreen();

    gfx.Restore();
  end
};

return _;