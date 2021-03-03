local New = function()
  local labels = {};

  labels.search = New.Label({
    font = 'medium',
    text = 'SEARCH',
    size = 18,
  });
  
  labels.input = New.Label({
    font = 'jp',
    text = '',
    size = 24,
  });

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

      self.labels.input:update({ new = string.upper(searchText) });

      local cursorOffset = math.min(self.labels.input.w + 2, self.w - 24);

      gfx.Save();

      drawRectangle({
        x = self.x + 2,
        y = self.y - 6,
        w = (self.w - 3) * self.timer.fade,
        h = self.h + 12,
        alpha = 150,
        color = 'black',
        fast = true,
      });

      if (isActive) then
        drawRectangle({
          x = self.x + 2,
          y = self.y - 6,
          w = (self.w - 3) * self.timer.fade,
          h = self.h + 12,
          alpha = 0,
          color = 'black',
          stroke = {
            alpha = alpha,
            color = 'normal',
            size = 2,
          },
        });
      end

      drawLabel({
        x = self.x + 7,
        y = self.y - 4,
        alpha = alpha,
        color = 'normal',
        label = self.labels.search,
      });

      if (shouldShow) then
        drawRectangle({
          x = self.x + 8 + cursorOffset,
          y = self.y + (self.h / 2) - 4,
          w = 2,
          h = 28,
          alpha = 255 * cursorAlpha,
          color = 'white',
        });

        drawLabel({
          x = self.x + 8,
          y = self.y + 20,
          color = 'white',
          label = self.labels.input,
          maxWidth = self.w - 24,
        });
      end

      gfx.Restore();
    end,
  };
end

return { New = New };