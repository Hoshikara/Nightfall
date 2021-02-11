local New = function()
  local labels = {};

  Font.Medium();

  labels.search = New.Label({ text = 'SEARCH', size = 18 });
  
  Font.JP();

  labels.input = New.Label({ text = '', size = 24 });

  return {
    labels = labels,
    timer = { cursor = 0, fade = 0 },
    w = 0,
    h = 0,
    x = 0,
    y = 0,

    setSizes = function(self, params)
      self.w = get(params, 'w', 0);
      self.h = get(params, 'screenH', 0) / 22;

      self.x = get(params, 'screenW', 0) / 20;
      self.y = get(params, 'screenH', 0) / 40;
    end,

    render = function(self, deltaTime, params)
      local isActive = get(params, 'isActive', false);
      local searchText = get(params, 'searchText', '');
      local shouldShow = (string.len(searchText) > 0) or isActive;

      if (shouldShow) then
        self.timer.cursor = self.timer.cursor + deltaTime;
        self.timer.fade = math.min(self.timer.fade + (deltaTime * 6), 1);
      elseif ((not shouldShow) and (self.timer.fade > 0)) then
        self.timer.cursor = 0;
        self.timer.fade = math.max(self.timer.fade - (deltaTime * 6), 0);
      end

      local alpha = math.floor(255 * math.min(self.timer.fade * 2, 1));
      local cursorAlpha = 0;

      if (isActive) then
        cursorAlpha = math.abs(0.9 * math.cos(self.timer.cursor * 5)) + 0.1;
      end

      Font.JP();

      self.labels.input:update({ new = string.upper(searchText) });

      local cursorOffset = math.min(self.labels.input.w + 2, self.w - 24);

      gfx.Save();

      gfx.BeginPath();
      Fill.Black(150);
      gfx.FastRect(
        self.x + 2,
        self.y - 6,
        (self.w - 3) * self.timer.fade,
        self.h + 12
      );
      gfx.Fill();

      if (isActive) then
        gfx.BeginPath();
        gfx.StrokeWidth(2);
        gfx.StrokeColor(60, 110, 160, alpha);
        Fill.Black(0);
        gfx.Rect(
          self.x + 2,
          self.y - 6,
          (self.w - 3) * self.timer.fade,
          self.h + 12
        );
        gfx.Fill();
        gfx.Stroke();
      end

      gfx.BeginPath();
      FontAlign.Left();

      self.labels.search:draw({
        x = self.x + 7,
        y = self.y - 4,
        a = alpha,
        color = 'Normal',
      });

      if (shouldShow) then
        gfx.BeginPath();
        Fill.White(255 * cursorAlpha);
        gfx.FastRect(
          self.x + 8 + cursorOffset,
          self.y + (self.h / 2) - 4,
          2,
          28
        );
        gfx.Fill();

        gfx.BeginPath();
        FontAlign.Left();

        self.labels.input:draw({
          x = self.x + 8,
          y = self.y + 20,
          color = 'White',
          maxWidth = self.w - 24,
        });
      end

      gfx.Restore();
    end,
  };
end

return { New = New };