return {
  cache = nil,
  colors = {
    crit = { 255, 235, 100 },
    early = { 255, 105, 255 },
    error = { 150, 150, 150 },
    late = { 105, 205, 255 },
  },
  lengthScale = 1,
  position = getSetting('hitErrorPosition', 'OFF'),
  scale = getSetting('hitErrorScale', 1.5),
  windows = {
    crit = get(gameplay, 'hitWindow.perfect', 46),
    near = get(gameplay, 'hitWindow.good', 92),
  },
  w = { crit = 0, near = 0 },
  h = 16,

  setCache = function(self)
    if (not self.cache) then
      self.cache = {};

      for rating = 1, 2 do
        self.cache[rating] = {};

        for button = 1, 6 do
          self.cache[rating][button] = {};

          for cache = 1, 24 do
            self.cache[rating][button][cache] = {
              delta = 0,
              queued = false,
              timer = 1,
            };
          end
        end
      end
    end
  end,

  queueHit = function(self, button, rating, delta)
    if ((button == game.BUTTON_STA) or (rating == 0) or (rating == 3)) then
      return
    end

    for cache = 1, 24 do
      if (not self.cache[rating][button + 1][cache].queued) then
        self.cache[rating][button + 1][cache].delta = delta;
        self.cache[rating][button + 1][cache].queued = true;

        break;
      end
    end
  end,

  drawHit = function(self, deltaTime, cache)
    local color = self.colors.crit;
    local x = cache.delta * self.lengthScale;

    if (cache.delta > self.windows.crit) then
      color = self.colors.late;
    elseif (cache.delta < -self.windows.crit) then
      color = self.colors.early;
    end

    cache.timer = math.max(cache.timer - (deltaTime / 4), 0);

    drawRectangle({
      x = x - 1,
      y = -((self.h - 4) / 2),
      w = 2,
      h = self.h - 4,
      alpha = 255 * (cache.timer ^ 2),
      blendOp = gfx.BLEND_OP_LIGHTER,
      color = color,
    });

    if (cache.timer == 0) then
      cache.delta = 0;
      cache.queued = false;
      cache.timer = 1;
    end
  end,

  render = function(self, deltaTime, w, h)
    if (self.position == 'OFF') then return end

    if ((w / 18) > self.windows.near) then
      self.lengthScale = (w / 8) / self.windows.near;

      self.w.crit = self.windows.crit * self.lengthScale;
      self.w.near = self.windows.near * self.lengthScale;
    end

    self:setCache();

    local y = h - 18;

    if (self.position == 'BOTTOM') then
      y = h - 18;
    elseif (self.position == 'MIDDLE') then
      y = h - (h / 4);
    elseif (self.position == 'TOP') then
      y = 40;
    end

    gfx.Save();

    gfx.Translate(w / 2, y);

    gfx.Scale(self.scale, self.scale);

    for rating = 1, 2 do
      for button = 1, 6 do
        for cache = 1, 24 do
          if (self.cache[rating][button][cache].queued) then
            self:drawHit(deltaTime, self.cache[rating][button][cache]);
          end
        end
      end
    end

    drawRectangle({
      x = -1,
      y = -(self.h / 2),
      w = 2,
      h = self.h,
      alpha = 200,
      color = 'white',
    });

    drawRectangle({
      x = -self.w.crit - 1,
      y = -(self.h / 2),
      w = 2,
      h = self.h,
      alpha = 100,
      color = self.colors.early,
    });

    drawRectangle({
      x = self.w.crit + 1,
      y = -(self.h / 2),
      w = 2,
      h = self.h,
      alpha = 100,
      color = self.colors.late,
    });

    drawRectangle({
      x = -self.w.near - 2,
      y = -(self.h / 2),
      w = 2,
      h = self.h,
      alpha = 100,
      color = 'white',
    });

    drawRectangle({
      x = self.w.near + 2,
      y = -(self.h / 2),
      w = 2,
      h = self.h,
      alpha = 100,
      color = 'white',
    });

    gfx.Restore();
  end,
};