local getSign = function(val)
  return ((val > 0) and 1) or ((val < 0) and -1) or 0;
end

local getDelta = function(delta)
  if (math.abs(delta) > (1.5 * math.pi)) then
    return delta + 2 * (math.pi * getSign(delta) * -1);
  end

  return delta;
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

---@class KnobsClass
local Knobs = {
  -- Knobs constructor
  ---@param this KnobsClass
  ---@param state table
  ---@return Knobs
  new = function(this, state)
    ---@class Knobs : KnobsClass
    local t = {
      knobs = nil,
      progress = 0,
      state = state,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Handle knob input
  ---@param this Knobs
  ---@param count integer # Item count
  ---@param curr integer # Current item
  handleChange = function(this, count, curr)
    if (not this.knobs) then
      this.knobs = { game.GetKnob(0), game.GetKnob(1) };
    else
      local knobs = { game.GetKnob(0), game.GetKnob(1) };
      local next = this.state[curr];

      this.progress = this.progress - (getDelta(this.knobs[1] - knobs[1]) * 1.2);
      this.progress = this.progress - (getDelta(this.knobs[2] - knobs[2]) * 1.2);

      this.knobs = knobs;

      if (math.abs(this.progress) > 1) then
        next = (next - 1) + roundToZero(this.progress);
        next = (next % this.state[count]) + 1;

        this.progress = this.progress - roundToZero(this.progress);
      end

      this.state[curr] = next;
    end
  end,
};

return Knobs;