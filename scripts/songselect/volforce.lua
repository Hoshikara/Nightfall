local badgeRates = {
	0.5,  -- Played
	1.0,  -- Cleared
	1.02, -- Hard clear
	1.05, -- UC
	1.1   -- PUC
};

local gradeRates = {
	{['min'] = 9900000, ['rate'] = 1.05}, -- S
	{['min'] = 9800000, ['rate'] = 1.02}, -- AAA+
	{['min'] = 9700000, ['rate'] = 1},    -- AAA
	{['min'] = 9500000, ['rate'] = 0.97}, -- AA+
	{['min'] = 9300000, ['rate'] = 0.94}, -- AA
	{['min'] = 9000000, ['rate'] = 0.91}, -- A+
	{['min'] = 8700000, ['rate'] = 0.88}, -- A
	{['min'] = 7500000, ['rate'] = 0.85}, -- B
	{['min'] = 6500000, ['rate'] = 0.82}, -- C
	{['min'] =       0, ['rate'] = 0.8}   -- D
};

local calculateForce = function(score, topBadge, level)
	local badgeRate = badgeRates[topBadge];

	if (not (score and level and badgeRate)) then
		return 0;
	end

  for i, v in ipairs(gradeRates) do
    if (score >= v.min) then
      gradeRate = v.rate;
      break;
    end
  end

	return (math.floor((level * 2) * (score / 10000000) * gradeRate * badgeRate) / 100);
end

return calculateForce;