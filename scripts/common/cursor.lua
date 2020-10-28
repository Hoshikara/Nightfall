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
      local height = get(params, 'height', self.h);
      local index = get(params, 'total', 1);
      local total = get(params, 'total', 1);

      if ((current % total) > 0) then
        index = current % total;
      end

      if (get(params, 'vertical', false)) then
        self.y.current = (height + self.margin) * (index - 1);
      else
        self.x.current = (self.w + self.margin) * (index - 1);
      end

      self.timer.ease = 0;
    end,

    render = function(self, deltaTime, params)
      if (self.timer.ease < 1) then
        self.timer.ease = math.min(self.timer.ease + (deltaTime * 8), 1);
      end

      self.timer.phase = self.timer.phase + deltaTime;
      self.timer.flicker = self.timer.flicker + deltaTime;

      self.alpha = math.floor(self.timer.flicker * 30) % 2;

      if (self.timer.flicker >= 0.3) then
        self.alpha = math.abs(0.85 * math.cos(self.timer.phase * 5)) + 0.15;
      end

      gfx.Save();

      if (params.vertical) then
        local change = (self.y.current - self.y.previous)
          * Ease.OutQuad(self.timer.ease);
        local offset = self.y.previous + change;

        self.y.previous = offset;

        drawCursor({
          w = self.w,
          h = self.h,
          x = self.x.base,
          y = self.y.base + offset,
          alpha = self.alpha,
          size = params.size,
          stroke = params.stroke,
        });
      else
        local change = (self.x.current - self.x.previous)
          * Ease.OutQuad(self.timer.ease);
        local offset = self.x.previous + change;

        self.x.previous = offset;

        drawCursor({
          w = self.w,
          h = self.h,
          x = self.x.base + offset,
          y = self.y.base,
          alpha = self.alpha,
          size = params.size,
          stroke = params.stroke,
        });
      end

      gfx.Restore();
    end,
  };
end

return { New = New };