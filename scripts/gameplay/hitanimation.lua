local _ = {
  laneMapper = {
    1,
    2,
    3,
    4,
    1.5,
    3.5,
  },
  scale = 0,
};

_.initializeHold = function(self)
  local hold = {
    inner = {
      frameCount = 14,
    },
    outer = {
      frameCount = 82,
    },
    ending = {
      frameCount = 8,
    },
  };

  for part, a in pairs(hold) do
    local frames = loadFrames(
      string.format('gameplay/hit_animation/hold/%s', part),
      hold[part].frameCount
    );
    local width = gfx.ImageSize(frames[1]);

    hold[part].alpha = ((part == 'inner') and 1.35) or 1.5;
    hold[part].blendOp = gfx.BLEND_OP_LIGHTER;
    hold[part].frames = frames;
    hold[part].frameTime = (1.0 / 38.0);
    hold[part].width = width * 0.625;

    for btn = 1, 6 do
      hold[part][btn] = {
        counter = 1,
        timer = 0,
      };
    end
  end

  hold.endingQueued = {
    false,
    false,
    false,
    false,
    false,
    false,
  };

  hold.drawHold = function(self, deltaTime, btn, inner, outer)
    gfx.Save();

    _:hitTransform(btn);

    inner[btn].timer = inner[btn].timer + deltaTime;

    if (inner[btn].timer > inner.frameTime) then
      inner[btn].counter = inner[btn].counter + 1;
      inner[btn].timer = 0;
    end

    if (inner[btn].timer < inner.frameTime) then
      drawRectangle({
        x = 0,
        y = 0,
        w = inner.width,
        h = inner.width,
        alpha = inner.alpha,
        blendOp = inner.blendOp,
        centered = true,
        image = inner.frames[inner[btn].counter],
      });
    end

    if (inner[btn].counter == inner.frameCount) then
      inner[btn].counter = 10;
    end

    outer[btn].timer = outer[btn].timer + deltaTime;

    if (outer[btn].timer > outer.frameTime) then
      outer[btn].counter = outer[btn].counter + 1;
      outer[btn].timer = 0;
    end

    if (outer[btn].timer < outer.frameTime) then
      drawRectangle({
        x = 0,
        y = 0,
        w = outer.width,
        h = outer.width,
        alpha = outer.alpha,
        blendOp = outer.blendOp,
        centered = true,
        image = outer.frames[outer[btn].counter],
      });
    end

    if (outer[btn].counter == outer.frameCount) then
      outer[btn].counter = 10;
    end

    gfx.Restore();
  end

  hold.drawHoldEnd = function(self, deltaTime, btn, holdEnding)
    gfx.Save();
    
    _:hitTransform(btn);

    holdEnding[btn].timer = holdEnding[btn].timer + deltaTime;

    if (holdEnding[btn].timer > holdEnding.frameTime) then
      holdEnding[btn].counter = holdEnding[btn].counter + 1;
      holdEnding[btn].timer = 0;
    end

    if (holdEnding[btn].timer < holdEnding.frameTime) then
      drawRectangle({
        x = 0,
        y = 0,
        w = holdEnding.width,
        h = holdEnding.width,
        alpha = holdEnding.alpha,
        blendOp = holdEnding.blendOp,
        centered = true,
        image = holdEnding.frames[holdEnding[btn].counter],
      });
    end

    if (holdEnding[btn].counter == holdEnding.frameCount) then
      holdEnding[btn].counter = 1;
      self.endingQueued[btn] = false;
    end

    gfx.Restore();
  end

  return hold;
end

_.initializeHit = function(self)
  local hit = {
    frameCount = 17,
  };

  for rating = 1, 2 do
    local type = ((rating == 1) and 'near') or 'critical';
    local frames = loadFrames(
      string.format('gameplay/hit_animation/%s', type),
      hit.frameCount
    );
    local width = gfx.ImageSize(frames[1]);
  
    hit[rating] = {
      alpha = ((type == 'near') and 1) or 1.2,
      blendOp = gfx.BLEND_OP_SOURCE_OVER,
      frames = frames,
      frameTime = ((type == 'near') and (1.0 / 74.0)) or (1.0 / 58.0),
      width = width * (((type == 'near') and 0.975) or 0.65),
    };
  
    for btn = 1, 6 do
      hit[rating][btn] = {};
  
      for cache = 1, 6 do
        hit[rating][btn][cache] = {
          counter = 1,
          queued = false,
          timer = 0,
        };
      end
    end
  end

  hit.drawHit = function(self, deltaTime, btn, hitType, cached);
    gfx.Save();

    _:hitTransform(btn);

    cached.timer = cached.timer + deltaTime;

    if (cached.timer > hitType.frameTime) then
      cached.counter = cached.counter + 1;
      cached.timer = 0;
    end

    if (cached.timer < hitType.frameTime) then
      drawRectangle({
        x = 0,
        y = 0,
        w = hitType.width,
        h = hitType.width,
        alpha = hitType.alpha,
        blendOp = hitType.blendOp,
        centered = true,
        image = hitType.frames[cached.counter],
      });
    end

    if (cached.counter == self.frameCount) then
      cached.counter = 1;
      cached.queued = false;
      cached.timer = 0;
    end

    gfx.Restore();
  end

  return hit;
end

_.initializeAll = function(self)
  self.hitTransform = function(self, btn)
    local n = self.laneMapper[btn] + 0.5;
    local x = gameplay.critLine.line.x1 + (gameplay.critLine.line.x2 - gameplay.critLine.line.x1) * (n / 6);
    local y = gameplay.critLine.line.y1 + (gameplay.critLine.line.y2 - gameplay.critLine.line.y1) * (n / 6);
    
    gfx.Translate(x, y);
    gfx.Rotate(-gameplay.critLine.rotation);
    gfx.Scale(self.scale, self.scale);
  end

  self.hit = self:initializeHit();

  self.hold = self:initializeHold();
end

_.queueHit = function(self, btn, rating)
  if ((btn == game.BUTTON_STA) or (rating == 0) or (rating == 3)) then return end;

  for cache = 1, 6 do
    if (not self.hit[rating][btn + 1][cache].queued) then
      self.hit[rating][btn + 1][cache].queued = true;
      break;
    end
  end
end

_.render = function(self, deltaTime, scale)
  if (self.scale ~= scale) then
    self.scale = scale;
  end

  for rating = 1, 2 do
    for btn = 1, 6 do
      for cache = 1, 6 do
        if (self.hit[rating][btn][cache].queued) then
          self.hit:drawHit(
            deltaTime,
            btn,
            self.hit[rating],
            self.hit[rating][btn][cache]
          );
        end
      end
    end
  end

  for btn = 1, 6 do
    if (gameplay.noteHeld[btn]) then
      self.hold:drawHold(
        deltaTime,
        btn,
        self.hold.inner,
        self.hold.outer
      );
      self.hold.endingQueued[btn] = true;
    else
      self.hold.inner[btn].counter = 1;
      self.hold.outer[btn].counter = 1;
    end
  end

  for btn = 1, 6 do
    if (not gameplay.noteHeld[btn]) then
      if (self.hold.endingQueued[btn]) then
        self.hold:drawHoldEnd(
          deltaTime,
          btn,
          self.hold.ending
        );
      else
        self.hold.ending[btn].counter = 1;
      end
    end
  end
end

return _;