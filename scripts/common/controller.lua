local getDelta = function(delta)
  if (math.abs(delta) > (1.5 * math.pi)) then
    return delta + 2 * (math.pi * getSign(delta) * -1);
  end

  return delta;
end

local getSign = function(val)
  return ((val > 0) and 1) or ((val < 0) and -1) or 0;
end

local roundToZero = function(val)
	if (val < 0) then
		return math.ceil(val);
	elseif (val > 0) then 
		return math.floor(val);
	else 
		return 0;
	end
end

return {
  knobProgress = 0,
  previousKnobs = nil,

  handleInput = function(self, params)
    if (not self.previousKnobs) then
      self.previousKnobs = { game.GetKnob(0), game.GetKnob(1) };

      return params.current;
    else
      local newKnobs = { game.GetKnob(0), game.GetKnob(1) };
      local next = params.current;

      self.knobProgress = self.knobProgress
        - (getDelta(self.previousKnobs[1] - newKnobs[1]) * 1.2);
      self.knobProgress = self.knobProgress
        - (getDelta(self.previousKnobs[2] - newKnobs[2]) * 1.2);

      self.previousKnobs = newKnobs;

      if (math.abs(self.knobProgress) > 1) then
        next = (((next - 1) + roundToZero(self.knobProgress)) % params.total)
          + 1;

        self.knobProgress = self.knobProgress - roundToZero(self.knobProgress);
      end

      return next;
    end
  end,
};