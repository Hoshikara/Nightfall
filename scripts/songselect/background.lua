local bg = Image:new('bg.png');
local bgPortrait = Image:new('bg_p.png');

local resX = 0;
local resY = 0;

render = function(dt)
	resX, resY = game.GetResolution();

	if (resY > resX) then
		bgPortrait:draw({ w = resX, h = resY });
	else
		bg:draw({ w = resX, h = resY });
	end
end
