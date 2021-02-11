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
    w = w,
    h = h,

    draw = function(self, params);
      local x = params.x or 0;
      local y = params.y or 0;
      local a = params.a or 255;
      local color = params.color or 'White';
      local maxWidth = params.maxWidth or -1;

      if (params.override) then
        gfx.DrawLabel(self.label, x, y, maxWidth);
      else
        if (params.scrolling) then
          self:drawScrolling({
            x = x,
            y = y,
            a = a,
            color = color,
            scale = params.scale or 1,
            timer = params.timer or 0,
            width = params.width or 0,
          });
        else
          Fill.Dark(a * 0.5);
          gfx.DrawLabel(self.label, x + 1, y + 1, maxWidth);
      
          Fill[color](a);
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

      FontAlign.Left();

      Fill.Dark(params.a * 0.5);
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

      Fill[params.color](params.a);
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