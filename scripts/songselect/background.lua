local background = Background:new();

local resX = 0;
local resY = 0;

render = function(dt)
	resX, resY = game.GetResolution();

	background.window.isPortrait = resY > resX;

	background:render({ w = resX, h = resY });
end
