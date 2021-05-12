local bg = Image:new('bg.png');

local resX = 0;
local resY = 0;

render = function(dt)
	resX, resY = game.GetResolution();

	bg:draw({ w = resX, h = resY });
end
