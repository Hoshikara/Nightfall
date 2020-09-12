local _ = {};

_.initializeLaser = function(self)
  local laser = {
    [1] = {
      ['end'] = {
        ['pos'] = 0,
        ['queued'] = false
      }
    },
    [2] = {
      ['end'] = {
        ['pos'] = 0,
        ['queued'] = false
      }
    },
    ['frameCount'] = 13,
    ['frameTime'] = (1.0 / 52.0)
  };

  for side = 1, 2 do
    local whichSide = ((side == 1) and 'left') or 'right';

    local dome = gfx.LoadSkinAnimation(
      string.format('gameplay/hit_animation/laser_%s/dome', whichSide),
      (1.0 / 30.0)
    );
    local frame = gfx.CreateSkinImage('gameplay/hit_animation/laser_left/dome/0001.png', 0);
    local tail = gfx.CreateSkinImage(
      string.format('gameplay/laser_cursor/tail_%s.png', whichSide),
      0
    );
    local width = gfx.ImageSize(frame);

    laser[side]['active'] = {
      ['dome'] = dome,
      ['tail'] = tail,
      ['width'] = width * 0.625,
    };

    for cache = 1, 6 do
      laser[side]['end'][cache] = {
        ['counter'] = 1,
        ['queued'] = false,
        ['timer'] = 0
      };
    end

    for part = 1, 2 do
      local whichPart = ((part == 1) and 'inner') or 'outer';

      local frames = loadFrames(
        string.format('gameplay/hit_animation/laser_%s/%s', whichSide, whichPart),
        laser['frameCount']
      );
      local width = gfx.ImageSize(frames[1]);

      laser[side]['end'][whichPart] = {
        ['alpha'] = (((part == 1) and 2) or 1),
        ['blendOp'] = (((part == 1) and gfx.BLEND_OP_SOURCE_OVER) or gfx.BLEND_OP_LIGHTER),
        ['frames'] = frames,
        ['width'] = width * (((part == 1) and 0.75) or 0.625)
      };
    end
  end

  laser.drawAnimation = function(self, deltaTime, lsr, pos, scale, skew)
    local w = lsr['width'] * scale;

    gfx.Save();

    gfx.BeginPath();
    gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER);

    gfx.ImageRect(pos - (w / 2), -(w / 2), w, w, lsr['dome'], 1.5, 0);
    gfx.TickAnimation(lsr['dome'], deltaTime);

    gfx.SkewX(skew);
    gfx.ImageRect(pos - (w / 2), -(w / 2), w, w, lsr['tail'], 1, 0);

    gfx.Restore();
  end

  laser.drawEnd = function(self, deltaTime, lsr, cached, inner, outer, scale)
    local pos = self[lsr]['end']['pos'];

    gfx.Save();

    cached['timer'] = cached['timer'] + deltaTime;

    if (cached['timer'] > self['frameTime']) then
      cached['counter'] = cached['counter'] + 1;
      cached['timer'] = 0;
    end

    gfx.BeginPath();

    if (cached['timer'] < self['frameTime']) then
      gfx.GlobalCompositeOperation(inner['blendOp']);
      gfx.ImageRect(
        pos - ((inner['width'] * scale) / 2),
        -((inner['width'] * scale * 0.925) / 2),
        inner['width'] * scale,
        inner['width'] * scale * 0.925,
        inner['frames'][cached['counter']],
        inner['alpha'],
        0
      );

      gfx.GlobalCompositeOperation(outer['blendOp']);
      gfx.ImageRect(
        pos - ((outer['width'] * scale) / 2),
        -((outer['width'] * scale * 0.925) / 2),
        outer['width'] * scale,
        outer['width'] * scale * 0.925,
        outer['frames'][cached['counter']],
        outer['alpha'],
        0
      );
    end

    if (cached['counter'] == self['frameCount']) then
      cached['counter'] = 1;
      cached['queued'] = false;
      cached['timer'] = 0;
    end

    gfx.Restore();
  end

  return laser;
end

_.initializeAll = function(self)
  self['laser'] = self:initializeLaser();
end

_.queueEnd = function(self, lsr)
  for cache = 1, 6 do
    if (not self['laser'][lsr]['end'][cache]['queued']) then
      self['laser'][lsr]['end'][cache]['queued'] = true;
      break;
    end
  end
end

_.render = function(self, deltaTime, lsr, pos, scale, skew)
  for laser = 1, 2 do
    if ((lsr == laser) and (not gameplay.laserActive[laser])) then
      for cache = 1, 6 do
        if (self['laser'][lsr]['end'][cache]['queued']) then
          self['laser']:drawEnd(
            deltaTime,
            lsr,
            self['laser'][lsr]['end'][cache],
            self['laser'][lsr]['end']['inner'],
            self['laser'][lsr]['end']['outer'],
            scale
          );
          self['laser'][lsr]['end']['queued'] = false;
        end
      end
    end
  end

  if ((lsr == 1) and gameplay.laserActive[lsr]) then
    self['laser']:drawAnimation(deltaTime, self['laser'][lsr]['active'], pos, scale, skew);
    self['laser'][lsr]['end']['pos'] = pos;

    if (not self['laser'][lsr]['end']['queued']) then
      self['laser'][lsr]['end']['queued'] = true;
      self:queueEnd(lsr);
    end
  end

  if ((lsr == 2) and gameplay.laserActive[lsr]) then
    self['laser']:drawAnimation(deltaTime, self['laser'][lsr]['active'], pos, scale, skew);
    self['laser'][lsr]['end']['pos'] = pos;

    if (not self['laser'][lsr]['end']['queued']) then
      self['laser'][lsr]['end']['queued'] = true;
      self:queueEnd(lsr);
    end
  end
end

return _;