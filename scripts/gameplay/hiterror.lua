-- ----------------------------------------------------------------------- --
-- TIMING WINDOWS (ms)
--    +- 0-46 ms is critical
--    +- 46-92 ms is near
--    +- 92+ ms is miss
--
--    ======92======|======46======|======46======|======92======          
--
-- ----------------------------------------------------------------------- --
-- CONFIGURABLE SETTINGS
--
-- SCALE
--    overall size of the hit error bar
--    possible values: anything above 0

-- POSITION
--    y-position of the hit error bar
--    possible values: BOTTOM, LOW, TOP
-- ----------------------------------------------------------------------- --

local SCALE = 1.5;
local POSITION = 'BOTTOM';

-------------------------------------------------------------------------- --

local _ = {};

_.hits = {};

for type = 1, 2 do
  _.hits[type] = {};

  for button = 1, 6 do
    _.hits[type][button] = {};

    for cache = 1, 24 do
      _.hits[type][button][cache] = {
        ['delta'] = 0,
        ['timer'] = 1,
        ['trigger'] = false,
      }
    end
  end
end

local NEAR_WINDOW = 92;
local CRIT_WINDOW = 46;
local BAR_HEIGHT = 5;

_.render = function(self, deltaTime, desw, desh, portrait)
  local yPos = desh - (desh / 36);

  if (POSITION == 'BOTTOM') then
    yPos = desh - (desh / 36);
  elseif (POSITION == 'LOW') then
    yPos = desh - (desh / 4);
  elseif (POSITION == 'TOP') then
    yPos = desh / 6;
  end

  gfx.Save();

  gfx.Translate(desw / 2, yPos);
  gfx.Scale(SCALE, SCALE);

  gfx.BeginPath();
  gfx.FillColor(80, 220, 20, 255);
  gfx.Rect(-NEAR_WINDOW, -BAR_HEIGHT / 2, NEAR_WINDOW * 2, BAR_HEIGHT);
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(50, 180, 220, 255);
  gfx.Rect(-CRIT_WINDOW, -BAR_HEIGHT / 2, CRIT_WINDOW * 2, BAR_HEIGHT);
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(255, 255, 255);
  gfx.Rect(-0.8, -12, 1.6, 24);
  gfx.Fill();

  for type = 1, 2 do
    for button = 1, 6 do
      for cache = 1, 24 do
        if (self['hits'][type][button][cache]['trigger'] == true) then
          self:drawHit(type, button, cache, deltaTime);
        end
      end
    end
  end

  gfx.Restore();
end

_.triggerHit = function(self, button, rating, delta)
  if ((rating == 0) or (rating == 3)) then return end;

  for cache = 1, 24 do
    if (self['hits'][rating][button + 1][cache]['trigger'] == false) then
      self['hits'][rating][button + 1][cache]['delta'] = delta;
      self['hits'][rating][button + 1][cache]['trigger'] = true;
      break;
    end
  end
end

_.drawHit = function(self, type, button, cache, deltaTime);
  local xPos = self['hits'][type][button][cache]['delta'];
  local r = ((type == 1) and 80) or 50;
  local g = ((type == 1) and 220) or 180;
  local b = ((type == 1) and 20) or 220;

  self['hits'][type][button][cache]['timer'] = math.max(
    self['hits'][type][button][cache]['timer'] - (deltaTime / 4),
    0
  );

  local alpha = math.floor(255 * (self['hits'][type][button][cache]['timer'] ^ 2));

  gfx.BeginPath();
  gfx.GlobalCompositeOperation(gfx.BLEND_OP_LIGHTER);
  gfx.FillColor(r, g, b, alpha);
  gfx.Rect(xPos - 0.8, -12, 1.6, 24);
  gfx.Fill();

  if (self['hits'][type][button][cache]['timer'] == 0) then
    self['hits'][type][button][cache]['delta'] = 0;
    self['hits'][type][button][cache]['timer'] = 1;
    self['hits'][type][button][cache]['trigger'] = false;
  end
end

return _;
