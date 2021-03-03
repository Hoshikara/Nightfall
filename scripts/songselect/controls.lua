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
    
          list[i].action = New.Label({
            font = 'normal',
            text = CONTROL_LIST[category][i].action,
            size = 24,
          });
    
          list[i].controller = New.Label({
            font = 'medium',
            text = CONTROL_LIST[category][i].controller,
            size = 24,
          });
          list[i].keyboard = New.Label({
            font = 'medium',
            text = CONTROL_LIST[category][i].keyboard,
            size = 24,
          });
    
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
      self.headings = {
        main = New.Label({
          font = 'medium',
          text = 'CONTROLS',
          size = 60,
        }),
        general = New.Label({
          font = 'medium',
          text = 'GENERAL',
          size = 36,
        }),
        songSelect = New.Label({
          font = 'medium',
          text = 'SONG SELECT',
          size = 36,
        }),
        gameplaySettings = New.Label({
          font = 'medium',
          text = 'GAMEPLAY SETTINGS',
          size = 36,
        }),
        gameplay = New.Label({
          font = 'medium',
          text = 'GAMEPLAY',
          size = 36,
        }),
        practiceMode = New.Label({
          font = 'medium',
          text = 'PRACTICE MODE',
          size = 36,
        }),
        results = New.Label({
          font = 'medium',
          text = 'RESULTS',
          size = 36,
        }),
        controller = New.Label({
          font = 'medium',
          text = 'CONTROLLER',
          size = 30,
        }),
        keyboard = New.Label({
          font = 'medium',
          text = 'KEYBOARD',
          size = 30,
        }),
        btd = New.Label({
          font = 'medium',
          text = '[BT-D]',
          size = 24,
        }),
        next = New.Label({
          font = 'medium',
          text = 'NEXT PAGE',
          size = 24,
        }),
        maxWidth = 0,
      };
    end
  end,

  drawControls = function(self, list, initialX, initialY)
    local alpha = math.floor(255 * self.timer);
    local x = initialX;
    local y = initialY;

    drawLabel({
      x = x,
      y = y,
      alpha = alpha,
      color = 'white',
      label = self.headings.controller,
    });

    drawLabel({
      x = x + 350,
      y = y,
      alpha = alpha,
      color = 'white',
      label = self.headings.keyboard,
    });

    y = y + 60;

    for i = 1, #list do
      drawLabel({
        x = x,
        y = y,
        alpha = alpha,
        color = (list[i].note and 'white') or 'normal',
        label = list[i].controller,
      });

      drawLabel({
        x = x + 350,
        y = y,
        alpha = alpha,
        color = (list[i].note and 'white') or 'normal',
        label = list[i].keyboard,
      });

      drawLabel({
        x = x + 700,
        y = y,
        alpha = alpha,
        color = 'white',
        label = list[i].action, 
      });

      if ((i ~= #list) and (not list[i].note)) then
        drawRectangle({
          x = x + 1,
          y = y + 38,
          w = self.scaledW / 1.65,
          h = 2,
          alpha = 100 * self.timer,
          color = 'normal',
          fast = true,
        });
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

    drawLabel({
      x = x,
      y = y,
      alpha = (isActive and (255 * self.timer)) or (80 * self.timer),
      color = (isActive and 'normal') or 'white',
      label = heading,
    });

    if (heading.w > self.headings.maxWidth) then
      self.headings.maxWidth = heading.w;
    end

    return (heading.h * 2);
  end,

  drawScreen = function(self)
    local alpha = math.floor(255 * self.timer);

    drawRectangle({
      x = 0,
      y = 0,
      w = self.scaledW,
      h = self.scaledH,
      alpha = 235 * self.timer,
      color = 'black',
      fast = true,
    });

    gfx.Save();

    gfx.Translate(self.x, self.y);

    drawLabel({
      x = -3,
      y = 0,
      alpha = alpha,
      color = 'white',
      label = self.headings.main,
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

    drawRectangle({
      x = self.headings.maxWidth + 75,
      y = (self.headings.main.h * 2) + 10,
      w = 4,
      h = self.scaledH / 2.75,
      alpha = alpha,
      color = 'white',
      fast = true,
    });

    self:drawControls(
      self.controls[self.pages[self.selectedPage]],
      self.headings.maxWidth + 150,
      self.headings.main.h * 2
    );

    drawLabel({
      x = 0,
      y = self.scaledH - (self.scaledH / 7),
      alpha = alpha,
      color = 'normal',
      label = self.headings.btd,
    });

    drawLabel({
      x = self.headings.btd.w + 8,
      y = self.scaledH - (self.scaledH / 7) + 1,
      alpha = alpha,
      color = 'white',
      label = self.headings.next,
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