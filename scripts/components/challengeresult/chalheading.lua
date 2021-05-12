local Constants = require('constants/challengeresult');

-- Info drawing order
local Order = {
  'result',
  'completion',
  'date',
  'player',
};

---@class ChalHeadingClass
local ChalHeading = {
  -- ChalHeading constructor
  ---@param this ChalHeadingClass
  ---@param window Window
  ---@param state ChallengeResult
  ---@return ChalHeading
  new = function(this, window, state)
    ---@class ChalHeading : ChalHeadingClass
    ---@field labels table<string, Label>
    ---@field state ChallengeResult
    ---@field window Window
    local t = {
      cache = { w = 0, h = 0 },
      padding = { x = 0, y = 0 },
      labels = {},
      state = state,
      timer = 0,
      window = window,
      x = 0,
      y = 0,
      w = 0,
      h = 0,
    };

    for name, str in pairs(Constants.heading) do
      t.labels[name] = makeLabel('med', str);
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this ChalHeading
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      this.x = this.window.padding.x;
      this.y = this.window.padding.y;

      this.w = (this.window.w - (this.window.padding.x * 2)) * (3 / 4);
      this.h = this.window.h / 2.625;

      this.padding.x = this.w / 30;
      this.padding.y = this.h / 12;

      this.maxWidth = this.w - (this.padding.x * 2);

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Draw the challenge heading
  ---@param this ChalHeading
  ---@param dt deltaTime
  drawHeading = function(this, dt)
    local chal = this.state.chal;
    local x = this.x + this.padding.x;
    local y = this.y + this.padding.y;

    this.labels.challenge:draw({ x = x, y = y });

    y = y + (this.labels.challenge.h * 1.25);

    if (chal.title.w > this.maxWidth) then
      this.timer = this.timer + dt;

      chal.title:drawScrolling({
        x = x,
        y = y,
        color = 'white',
        scale = this.window:getScale(),
        timer = this.timer,
        width = this.maxWidth,
      });
    else
      chal.title:draw({
        x = x,
        y = y,
        color = 'white',
      });
    end

    y = y + (chal.title.h * 0.85) + this.padding.y;

    for i, name in ipairs(Order) do
			local xTemp = x + (this.padding.x * ((i - 1) * 5));

			this.labels[name]:draw({ x = xTemp, y = y });

			chal[name]:draw({
				x = xTemp,
				y = y + (this.labels[name].h * 1.35),
				color = 'white',
			});
		end

    y = y + (this.labels.result.h * 1.35) + (chal.result.h * 2.25);

    this.labels.requirements:draw({ x = x, y = y });

    y = y + (this.labels.requirements.h * 1.35) + 2;

    local yTemp = y;

    for i, req in ipairs(chal.reqs) do
      if (i == 5) then
        x = x + (this.w / 2);
        y = yTemp;
      end

      req:draw({
        x = x + 1,
        y = y,
        color = 'white',
      });

      y = y + (req.h * 1.625);
    end
  end,

  -- Renders the current component
  ---@param this ChalHeading
  ---@param dt deltaTime
  render = function(this, dt)
    this:setSizes();

    gfx.Save();

    drawRect({
      x = this.x,
      y = this.y,
      w = this.w,
      h = this.h,
      alpha = 120,
      color = 'dark',
    });

    this:drawHeading(dt);

    gfx.Restore();
  end,
};

return ChalHeading;