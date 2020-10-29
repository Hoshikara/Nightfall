local help = require('helpers/songwheel');

local New = function(params)
  return {
    alpha = 0,
    margin = 0,
    timer = {
      ease = 0,
      flicker = 0,
      phase = 0,
    },
    w = 0,
    h = 0,
    x = {
      base = 0,
      previous = 0,
      current = 0,
    },
    y = {
      base = 0,
      previous = 0,
      current = 0,
    },

    setSizes = function(self, params)
      self.w = get(params, 'w', 0);
      self.h = get(params, 'h', 0);

      self.x.base = get(params, 'x', 0);
      self.y.base = get(params, 'y', 0);

      self.margin = get(params, 'margin', 0);
    end,

    setPosition = function(self, params)
      local current = get(params, 'current', 1);

      if (get(params, 'grid', false)) then
        local column, row = help.getPosition(current);

        self.x.current = (self.h + self.margin) * row;
        self.y.current = (self.h + self.margin) * column;
      else
        local index = get(params, 'total', 1);
        local total = get(params, 'total', 1);

        if ((current % total) > 0) then
          index = current % total;
        end

        if (get(params, 'vertical', false)) then
          local height = get(params, 'height', self.h);

          self.y.current = (height + self.margin) * (index - 1);
        else
          self.x.current = (self.w + self.margin) * (index - 1);
        end
      end

      self.timer.ease = 0;
    end,

    render = function(self, deltaTime, params)
      local size = get(params, 'size', 1);
      local stroke = get(params, 'stroke', 1);
      local changeX = 0;
      local changeY = 0;
      local offsetX = 0;
      local offsetY = 0;

      if (self.timer.ease < 1) then
        self.timer.ease = math.min(self.timer.ease + (deltaTime * 8), 1);
      end

      self.timer.phase = self.timer.phase + deltaTime;
      self.timer.flicker = self.timer.flicker + deltaTime;

      self.alpha = math.floor(self.timer.flicker * 30) % 2;

      if (self.timer.flicker >= 0.3) then
        self.alpha = math.abs(0.85 * math.cos(self.timer.phase * 5)) + 0.15;
      end

      local ease = Ease.OutQuad(self.timer.ease);

      if (get(params, 'grid', false)) then
        changeX = (self.x.current - self.x.previous) * ease;
        changeY = (self.y.current - self.y.previous) * ease;
        offsetX = self.x.previous + changeX;
        offsetY = self.y.previous + changeY;

        self.x.previous = offsetX;
        self.y.previous = offsetY;
      elseif (get(params, 'vertical', false)) then
        changeY = (self.y.current - self.y.previous) * ease;
        offsetY = self.y.previous + changeY;

        self.y.previous = offsetY;
      else
        changeX = (self.x.current - self.x.previous) * ease;
        offsetX = self.x.previous + changeX;

        self.x.previous = offsetX;
      end

      gfx.Save();

      drawCursor({
        w = self.w,
        h = self.h,
        x = self.x.base + offsetX,
        y = self.y.base + offsetY,
        alpha = self.alpha,
        size = size,
        stroke = stroke,
      });

      gfx.Restore();
    end,
  };
end

return { New = New };