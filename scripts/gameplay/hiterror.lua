local _ = {};

local OFF = 'OFF';
local BOTTOM = 'BOTTOM';
local MIDDLE = 'MIDDLE';
local TOP = 'TOP';

_.initializeHit = function(self)
  local hit = {};

  for rating = 1, 2 do
    hit[rating] = {};

    for btn = 1, 6 do
      hit[rating][btn] = {};

      for cache = 1, 24 do
        hit[rating][btn][cache] = {
          ['delta'] = 0,
          ['queued'] = false,
          ['timer'] = 1
        };
      end
    end
  end

  hit.drawHit = function(self, deltaTime, cached, rating, scale);
    local x = cached['delta'] * scale;
    local r = ((rating == 1) and 80) or 50;
    local g = ((rating == 1) and 220) or 180;
    local b = ((rating == 1) and 20) or 220;
  
    cached['timer'] = math.max(cached['timer'] - (deltaTime / 4), 0);
  
    local alpha = math.floor(255 * (cached['timer'] ^ 2));
  
    gfx.BeginPath();
    gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER);
    gfx.FillColor(r, g, b, alpha);
    gfx.Rect(x - 0.8, -12, 1.6, 24);
    gfx.Rect(x - 0.8, -12, 1.6, 24);
    gfx.Fill();
  
    if (cached['timer'] == 0) then
      cached['delta'] = 0;
      cached['queued'] = false;
      cached['timer'] = 1;
    end
  end

  return hit;
end

_.initializeInfo = function(self)
  return {
    ['critWindow'] = nil,
    ['desw'] = nil,
    ['height'] = 5,
    ['lengthScale'] = 1,
    ['nearWindow'] = nil,
    ['position'] = string.upper(game.GetSkinSetting('hitErrorPosition')),
    ['scale'] = game.GetSkinSetting('hitErrorScale')
  };
end

_.initializeAll = function(self)
  self['hit'] = self:initializeHit();

  self['info'] = self:initializeInfo();
end

_.queueHit = function(self, btn, rating, delta)
  if ((btn == game.BUTTON_STA) or (rating == 0) or (rating == 3)) then return end;

  for cache = 1, 24 do
    if (not self['hit'][rating][btn + 1][cache]['queued']) then
      self['hit'][rating][btn + 1][cache]['delta'] = delta;
      self['hit'][rating][btn + 1][cache]['queued'] = true;
      break;
    end
  end
end

_.render = function(self, deltaTime, desw, desh)
  if (self['info']['critWindow'] == nil) then
    self['info']['critWindow'] = gameplay.hitWindow.perfect;
    self['info']['nearWindow'] = gameplay.hitWindow.good;
  end

  if (self['info']['desw'] ~= desw) then
    if ((desw / 18) > self['info']['nearWindow']) then
      self['info']['lengthScale'] = (desw / 8) / self['info']['nearWindow'];
    end

    self['info']['desw'] = desw;
    self['info']['critWindow'] = self['info']['critWindow'] * self['info']['lengthScale'];
    self['info']['nearWindow'] = self['info']['nearWindow'] * self['info']['lengthScale'];
  end

  local y = desh - 18;

  if (self['info']['position'] == BOTTOM) then
    y = desh - 18;
  elseif (self['info']['position'] == MIDDLE) then
    y = desh - (desh / 4);
  elseif (self['info']['position'] == TOP) then
    y = 40;
  end

  gfx.Save();

  gfx.Translate(self['info']['desw'] / 2, y);
  gfx.Scale(self['info']['scale'], self['info']['scale']);

  gfx.BeginPath();
  gfx.FillColor(80, 220, 20, 255);
  gfx.Rect(
    -self['info']['nearWindow'],
    -(self['info']['height'] / 2),
    self['info']['nearWindow'] * 2,
    self['info']['height']
  );
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(50, 180, 220, 255);
  gfx.Rect(
    -self['info']['critWindow'],
    -(self['info']['height'] / 2),
    self['info']['critWindow'] * 2,
    self['info']['height']
  );
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(unpack(colors['white']));
  gfx.Rect(-0.8, -12, 1.6, 24);
  gfx.Fill();

  for rating = 1, 2 do
    for btn = 1, 6 do
      for cache = 1, 24 do
        if (self['hit'][rating][btn][cache]['queued']) then
          self['hit']:drawHit(
            deltaTime,
            self['hit'][rating][btn][cache],
            rating, 
            self['info']['lengthScale']
          );
        end
      end
    end
  end

  gfx.Restore();
end

return _;
