return function(params)
  local label = gfx.CreateLabel(
    params.text or 'NO TEXT PROVIDED FOR LABEL',
    params.size or 42,
    0
  );
  local w, h = gfx.LabelSize(label);
  local wrapped = {
    label = label,
    size = params.size or 42,
    text = params.text or 'NO TEXT PROVIDED FOR LABEL',
    w = w,
    h = h,

    draw = function(self, params);
      local x = params.x or 0;
      local y = params.y or 0;
      local alpha = params.alpha or 255;
      local maxWidth = params.maxWidth or -1;

      if (params.override) then
        gfx.DrawLabel(self.label, x, y, maxWidth);
      else
        if (params.scrolling) then
          self:drawScrolling({
            x = x,
            y = y,
            alpha = alpha,
            color = params.color or 'normal',
            scale = params.scale or 1,
            timer = params.timer or 0,
            width = params.width or 0,
          });
        else
          setFill('dark', alpha * 0.5);
          gfx.DrawLabel(self.label, x + 1, y + 1, maxWidth);
      
          setFill(params.color, alpha);
          gfx.DrawLabel(self.label, x, y, maxWidth);
        end
      end
    end,

    update = function(self, params)
      gfx.UpdateLabel(
        self.label,
        params.new or '',
        params.size or self.size,
        0
      );

      self.w, self.h = gfx.LabelSize(self.label);
    end,
  };

  if (params.scrolling) then
    wrapped.drawScrolling = function(self, params)
      local labelX = self.w * 1.2;
      local duration = (labelX / 80) * 0.75;
      local phase = math.max(
        (params.timer % (duration + 1.5)) - 1.5,
        0
      ) / duration;

      gfx.Save();

      gfx.BeginPath();
      gfx.Scissor(
        (params.x + 2) * params.scale,
        params.y * params.scale,
        params.width,
        self.h * 1.25
      );

      alignText('left');

      setFill('dark', params.alpha * 0.5);
      gfx.DrawLabel(
        self.label,
        params.x + 1 - (phase * labelX),
        params.y,
        -1
      );
      gfx.DrawLabel(
        self.label,
        params.x + 1 - (phase * labelX) + labelX,
        params.y,
        -1
      );

      setFill(params.color, params.alpha);
      gfx.DrawLabel(
        self.label,
        params.x - (phase * labelX),
        params.y,
        -1
      );
      gfx.DrawLabel(
        self.label,
        params.x - (phase * labelX) + labelX,
        params.y,
        -1
      );

      gfx.ResetScissor();

      gfx.Restore();
    end
  end

  return wrapped;
end