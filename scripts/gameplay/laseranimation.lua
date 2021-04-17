local _ = {};

local loadFrames = function(path, count)
  local frames = {};

  for i = 1, count do
    frames[i] = gfx.CreateSkinImage(string.format('%s/%04d.png', path, i), 0);
  end

  return frames;
end

_.initializeLaser = function(self)
  local laser = {
    [1] = {
      ending = {
        pos = 0,
        queued = false,
      }
    },
    [2] = {
      ending = {
        pos = 0,
        queued = false,
      },
    },
    frameCount = 13,
    frameTime = (1.0 / 52.0),
  };

  for side = 1, 2 do
    local whichSide = ((side == 1) and 'l') or 'r';

    local dome = gfx.LoadSkinAnimation(
      string.format('gameplay/hit_animation/laser_%s/dome', whichSide),
      (1.0 / 30.0)
    );
    local frame = gfx.CreateSkinImage('gameplay/hit_animation/laser_l/dome/0001.png', 0);
    local tail = gfx.CreateSkinImage(
      string.format('gameplay/laser_cursor/tail_%s.png', whichSide),
      0
    );
    local width = gfx.ImageSize(frame);

    laser[side].active = {
      dome = dome,
      tail = tail,
      width = width * 0.625,
    };

    for cache = 1, 6 do
      laser[side].ending[cache] = {
        counter = 1,
        queued = false,
        timer = 0,
      };
    end

    for part = 1, 2 do
      local whichPart = ((part == 1) and 'inner') or 'outer';

      local frames = loadFrames(
        string.format('gameplay/hit_animation/laser_%s/%s', whichSide, whichPart),
        laser.frameCount
      );
      local width = gfx.ImageSize(frames[1]);

      laser[side].ending[whichPart] = {
        alpha = (((part == 1) and 2) or 1),
        blendOp = (((part == 1) and gfx.BLEND_OP_SOURCE_OVER) or gfx.BLEND_OP_LIGHTER),
        frames = frames,
        width = width * (((part == 1) and 0.75) or 0.625),
      };
    end
  end

  laser.drawAnimation = function(self, deltaTime, lsr, pos, scale, skew)
    local w = lsr.width * scale;

    gfx.Save();

    gfx.BeginPath();
    gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER);

    gfx.ImageRect(pos - (w / 2), -(w / 2), w, w, lsr.dome, 1.5, 0);
    gfx.TickAnimation(lsr.dome, deltaTime);

    gfx.SkewX(skew);
    gfx.ImageRect(pos - (w / 2), -(w / 2), w, w, lsr.tail, 1, 0);

    gfx.Restore();
  end

  laser.drawEnding = function(self, deltaTime, lsr, cached, inner, outer, scale)
    local pos = self[lsr].ending.pos;

    gfx.Save();

    cached.timer = cached.timer + deltaTime;

    if (cached.timer > self.frameTime) then
      cached.counter = cached.counter + 1;
      cached.timer = 0;
    end

    if (cached.timer < self.frameTime) then
      drawRectangle({
        x = pos - ((inner.width * scale) / 2),
        y = -((inner.width * scale * 0.925) / 2),
        w = inner.width * scale,
        h = inner.width * scale * 0.925,
        alpha = inner.alpha,
        blendOp = inner.blendOp,
        image = inner.frames[cached.counter],
      });

      drawRectangle({
        x = pos - ((outer.width * scale) / 2),
        y = -((outer.width * scale * 0.925) / 2),
        w = outer.width * scale,
        h = outer.width * scale * 0.925,
        alpha = outer.alpha,
        blendOp = outer.blendOp,
        image = outer.frames[cached.counter],
      });
    end
    if (cached.counter == self.frameCount) then
      cached.counter = 1;
      cached.queued = false;
      cached.timer = 0;
    end

    gfx.Restore();
  end

  return laser;
end

_.initializeAll = function(self)
  self.laser = self:initializeLaser();
end

_.queueEnding = function(self, lsr)
  for cache = 1, 6 do
    if (not self.laser[lsr].ending[cache].queued) then
      self.laser[lsr].ending[cache].queued = true;
      break;
    end
  end
end

_.render = function(self, deltaTime, lsr, pos, scale, skew)
  for laser = 1, 2 do
    if ((lsr == laser) and (not gameplay.laserActive[laser])) then
      for cache = 1, 6 do
        if (self.laser[lsr].ending[cache].queued) then
          self.laser:drawEnding(
            deltaTime,
            lsr,
            self.laser[lsr].ending[cache],
            self.laser[lsr].ending.inner,
            self.laser[lsr].ending.outer,
            scale
          );
          self.laser[lsr].ending.queued = false;
        end
      end
    end
  end

  if ((lsr == 1) and gameplay.laserActive[lsr]) then
    self.laser:drawAnimation(deltaTime, self.laser[lsr].active, pos, scale, skew);
    self.laser[lsr].ending.pos = pos;

    if (not self.laser[lsr].ending.queued) then
      self.laser[lsr].ending.queued = true;
      self:queueEnding(lsr);
    end
  end

  if ((lsr == 2) and gameplay.laserActive[lsr]) then
    self.laser:drawAnimation(deltaTime, self.laser[lsr].active, pos, scale, skew);
    self.laser[lsr].ending.pos = pos;

    if (not self.laser[lsr].ending.queued) then
      self.laser[lsr].ending.queued = true;
      self:queueEnding(lsr);
    end
  end
end

return _;