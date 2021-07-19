local ceil = math.ceil;
local floor = math.floor;

---@class ScoreNumberClass
local ScoreNumber = {
  -- ScoreNumber constructor
  ---@param this ScoreNumberClass
  ---@param p table #
  -- ```
  -- {
  --   digits?: number,
  --   size: number = 100,
  --   val: number = 0,
  -- }
  -- ```
  ---@return ScoreNumber
  new = function(this, p)
    ---@class ScoreNumber : ScoreNumberClass
    local t = {
      alpha = {},
      digits = {},
      isScore = not p.digits,
      labels = {},
      position = {},
      size = p.size or 100,
      val = p.val or 0,
      w = 0,
      h = nil,
    };

    if (t.isScore) then
      for i = 1, 4 do
        t.labels[i] = makeLabel('num', '0', t.size);
        t.labels[i + 4] = makeLabel('num', '0', ceil(t.size * 0.8));

        t.w = t.w + t.labels[i].w + t.labels[i + 4].w;

        if (not t.h) then t.h = t.labels[i].h; end
      end
    else
      for i = 1, p.digits or 4 do
        t.labels[i] = makeLabel('num', '0', t.size);

        t.w = t.w + t.labels[i].w;

        if (not t.h) then t.h = t.labels[i].h; end
      end
    end

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the position and alpha values for the digits
  ---@param this ScoreNumber
  ---@param value number
  setValue = function(this, value)
    for i, label in ipairs(this.labels) do
      local min = 10 ^ (#this.labels - i);

      this.alpha[i] = ((value >= min) and 1) or 0.35;
      this.digits[i] = floor(value / min) % 10;

      if (i == 1) then
        this.position[i] = 0;
      else
        this.position[i] = this.position[i - 1] + label.w;
      end
    end
  end,

  -- Draw the current ScoreNumber
  ---@param this ScoreNumber
  ---@param params table #
  -- ```
  -- {
  --   x: number = 0,
  --   y: number = 0,
  --   align: Alignment,
  --   alpha: number = 255,
  --   color: Color,
  --   offset?: number,
  -- }
  -- ```
  draw = function(this, params)
    this:setValue(params.val or this.val);

    local align = params.align or 'left';
    local alpha = params.alpha or 255;
    local color = params.color or 'norm';
    local x = params.x or 0;
    local y = params.y or 0;

    if (this.isScore) then
      for i = 1, 4 do
        this.labels[i]:draw({
          x = x + this.position[i],
          y = y,
          align = align,
          alpha = alpha * this.alpha[i],
          color = 'white',
          text = this.digits[i],
          update = true,
        });

        this.labels[i + 4]:draw({
          x = x
            + this.position[i + 4]
            + (params.offset or (this.labels[i].w * 0.2)),
          y = y + (this.labels[i].h * 0.17),
          align = align,
          alpha = alpha * this.alpha[i + 4],
          color = color,
          text = this.digits[i + 4],
          update = true,
        });
      end
    else
      for i, label in ipairs(this.labels) do
        label:draw({
          x = x + this.position[i],
          y = y,
          align = align,
          alpha = alpha * this.alpha[i],
          color = color,
          text = this.digits[i],
          update = true,
        });
      end
    end
  end,
};

return ScoreNumber;