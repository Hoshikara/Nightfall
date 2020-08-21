local _ = {
  lastKnobs = nil,
  knobProgress = 0
};


_.handleInput = function(self, activeButton, showUpdatePrompt)
	if (self['lastKnobs'] == nil) then
    self['lastKnobs'] = { game.GetKnob(0), game.GetKnob(1) };
    
    return activeButton;
	else
    local newKnobs = { game.GetKnob(0), game.GetKnob(1) };
    local nextButton = activeButton;
	
		self['knobProgress'] = self['knobProgress'] - deltaKnob(self['lastKnobs'][1] - newKnobs[1]) * 1.2;
		self['knobProgress'] = self['knobProgress'] - deltaKnob(self['lastKnobs'][2] - newKnobs[2]) * 1.2;
		
		self['lastKnobs'] = newKnobs;
		
		if (math.abs(self['knobProgress']) > 1) then
			if (showUpdatePrompt) then
				nextButton = (((nextButton - 1) + roundToZero(self['knobProgress'])) % 3) + 1;
			else 
				nextButton = (((nextButton - 1) + roundToZero(self['knobProgress'])) % 5) + 1;
			end

			self['knobProgress'] = self['knobProgress'] - roundToZero(self['knobProgress']);
    end
    
    return nextButton;
	end
end

deltaKnob = function(delta)
	if (math.abs(delta) > (1.5 * math.pi)) then 
		return delta + 2 * (math.pi * getSign(delta) * -1);
	end

	return delta;
end

getSign = function(val)
  return ((val > 0) and 1) or ((val < 0) and -1) or 0;
end

roundToZero = function(val)
	if (val < 0) then
		return math.ceil(val);
	elseif (val > 0) then 
		return math.floor(val);
	else 
		return 0;
	end
end

return _;