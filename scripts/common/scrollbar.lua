local New = function()
  return {
    timer = 1,
    w = 0,
    h = {
      bar = 0,
      remaining = 0,
      track = 0,
    },
    x = 0,
    y = {
      bar = { current = 0, previous = 0 },
      track = 0,
    },

    setSizes = function(self, params)
      self.w = 8;

      self.h.bar = 32;
      self.h.track = params.h;
      self.h.remaining = self.h.track - self.h.bar;

      self.x = params.screenW - (params.screenW / 40) - 4;

      self.y.track = params.y;
    end,

    setPosition = function(self, params)
      self.y.bar.current = math.floor(
        self.h.remaining * ((params.current - 1) / (params.total - 1))
      );

      self.timer = 0;
    end,

    render = function(self, deltaTime)
      if (self.timer < 1) then
        self.timer = math.min(self.timer + (deltaTime * 8), 1);
      end

      local change = (self.y.bar.current - self.y.bar.previous)
        * Ease.OutQuad(self.timer);
      local offset = self.y.bar.previous + change;

      if (tostring(offset) == '-nan(ind)') then
        self.y.bar.previous = 0;
      else
        self.y.bar.previous = offset;
      end

      gfx.Save();

      gfx.BeginPath();
      Fill.Dark(120);
      gfx.Rect(self.x, self.y.track, self.w, self.h.track);
      gfx.Fill();

      gfx.Translate(self.x, self.y.track + offset);

      gfx.BeginPath();
      Fill.Normal();
      gfx.Rect(0, 0, self.w, self.h.bar);
      gfx.Fill();

      gfx.Restore();
    end,
  };
end

return { New = New };