local Sizes = {
  ['LOW'] = 200,
  ['NORMAL'] = 400,
  ['HIGH'] = 1000,
  ['ORIGINAL'] = 0,
};

local fallback = gfx.CreateSkinImage('common/loading.png', 0);
local size = Sizes[getSetting('jacketQuality', 'NORMAL')] or Sizes['NORMAL'];

-- Loads the jackets for the given diffs or charts
---@param t table
local load = function(t)
  for _, curr in ipairs(t) do
    if ((not curr.jacket) or (curr.jacket == fallback)) then
      curr.jacket = gfx.LoadImageJob(
        curr.jacketPath,
        fallback,
        size,
        size
      );
    end
  end
end

return { load = load };