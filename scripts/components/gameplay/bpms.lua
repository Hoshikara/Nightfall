local JSONTable = require('common/jsontable');

---@class BPMSClass
local BPMS = {
  -- BPMS constructor
  ---@param this BPMSClass
  ---@param state Gameplay
  ---@return BPMS
  new = function(this, state)
    ---@class BPMS : BPMSClass
    local t = {
      bpm = nil,
      bpms = JSONTable:new('bpms'),
      data = {},
      idx = 1,
      key = getSetting('_diffKey', ''),
      saved = false,
      time = 0,
    };

    if (t.bpms:get(false, t.key)) then state.bpms = t.bpms:get(false, t.key); end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Get BPM data
  ---@param this BPMS
  ---@param dt deltaTime
  get = function(this, dt)
    if (this.saved) then return; end

    -- Reset if chart restarted with F5
    if (gameplay.progress == 0) then
      this.bpm = nil;
      this.data = {};
      this.idx = 1;
      this.time = 0;
    end

    if (not this.bpm) then this.bpm = gameplay.bpm; end

    if (gameplay.progress > 0) then this.time = this.time + dt; end

    if (this.bpm ~= gameplay.bpm) then
      this.data[this.idx] = {
        time = (math.floor(this.time * 10) / 10) - 2.5,
        bpm = gameplay.bpm,
      };

      this.idx = this.idx + 1;
      this.bpm = gameplay.bpm;
    end
  end,

  -- Save BPM data
  ---@param this BPMS
  save = function(this)
    if (this.key ~= '') then
      if (not this.saved) then
        this.bpms:set(this.key, this.data);

        this.saved = true;
      end
    end
  end,
};

return BPMS;