local max = math.max;

---Normalizes the given text
---@param text string
---@param font string
---@return string
local normalize = function(text, font)
  if (type(text) ~= 'string') then text = tostring(text); end

  if (font ~= 'num') then text = text:upper(); end

  return text;
end

---@class LabelClass
---@field label table
local Label =  {
  -- Label constructor
  ---@param this LabelClass
  ---@param p table #
  -- ```
  -- {
  --   color: string = 'norm',
  --   font: string = 'jp',
  --   size: number = 50,
  --   text: string = 'LABEL TEXT',
  -- }
  -- ```
  ---@return Label
  new = function(this, p)
    ---@class Label : LabelClass
    local t = {
      color = p.color or 'norm',
      font = p.font or 'jp',
      size = p.size or 50,
      text = p.text or 'LABEL TEXT',
      w = 0,
      h = 0,
    };
    
    if (type(t.text) == 'table') then
      t.label = {};

      for i, curr in ipairs(t.text) do
        t.label[i] = this:new({
          color = curr.color,
          font = t.font,
          size = t.size,
          text = curr.text,
        });

        t.w = t.w + t.label[i].w;
        t.h = t.label[i].h;
      end

      loadFont(t.font);

      t.space = gfx.LabelSize(gfx.CreateLabel(' ', t.size, 0));
    else
      loadFont(t.font);

      t.text = normalize(t.text, t.font);
      t.label = gfx.CreateLabel(t.text, t.size, 0);
      t.w, t.h = gfx.LabelSize(t.label);
    end

    setmetatable(t, this);
    this.__index = this;
  
    return t;
  end,

  -- Draws the current label
  ---@param this Label
  ---@param params table #
  -- ```
  -- {
  --   x: number = 0,
  --   y: number = 0,
  --   align: string = 'left',
  --   alpha: number = 255,
  --   color: string|{ r, g, b } = 'norm',
  --   maxWidth: number = -1,
  --   text?: string,
  --   update?: boolean,
  -- }
  -- ```
  draw = function(this, params)
    local x = params.x or 0;
    local y = params.y or 0;
    local alpha = params.alpha or 255;
    local maxWidth = params.maxWidth or -1;

    if (params.update) then
      this:update({ size = params.size, text = params.text });
    end
  
    gfx.BeginPath();

    alignText(params.align);

    if (type(this.label) == 'table') then
      local sign = 1;

      if (params.align and (params.align == 'right')) then sign = -1; end

      for _, label in ipairs(this.label) do
        label:draw(params);

        params.x = (params.x or 0)
          + ((label.w + (this.space * (params.spaces or 1))) * sign);
      end
    else
      setFill('dark', alpha * 0.5);
      gfx.DrawLabel(this.label, x + 1, y + 1, maxWidth);

      setFill(params.color or this.color, alpha);
      gfx.DrawLabel(this.label, x, y, maxWidth);
    end
  end,

  -- Draws a scrolling version of the current label, bound to the specified width
  ---@param this Label
  ---@param params table #
  -- ```
  -- {
  --   x: number = 0,
  --   y: number = 0,
  --   align: string = 'left',
  --   alpha: number = 255,
  --   color: string = 'norm',
  --   scale: number = 1,
  --   timer: number = 0,
  --   width: number = 0,
  -- }
  -- ```
  drawScrolling = function(this, params)
    local x = params.x or 0;
    local y = params.y or 0;
    local alpha = params.alpha or 255;
    local scale = params.scale or 1;
    local timer = params.timer or 0;
    local width = params.width or 0;

    timer = timer * 2;

    local labelX = this.w + 80;
    local duration = (labelX / 80) * 0.75;
    local phase = max((timer % (duration + 1.5)) - 1.5, 0) / duration;

    gfx.Save();

    gfx.BeginPath();

    gfx.Scissor((x + 2) * scale, y * scale, width, this.h * 1.25);

    alignText(params.align);

    setFill('dark', alpha * 0.5);
    gfx.DrawLabel(this.label, x + 1 - (phase * labelX), y + 1, -1);
    gfx.DrawLabel(this.label, x + 1 - (phase * labelX) + labelX, y + 1, -1);
  
    setFill(params.color or this.color, alpha);
    gfx.DrawLabel(this.label, x - (phase * labelX), y, -1);
    gfx.DrawLabel(this.label, x - (phase * labelX) + labelX, y, -1);
  
    gfx.ResetScissor();
  
    gfx.Restore();
  end,

  -- Updates the text/size/font of the current label
  ---@param this Label
  ---@param params table #
  -- ```
  -- {
  --   font?: string,
  --   size?: number,
  --   text?: string
  -- }
  -- ```
  update = function(this, params)
    loadFont(params.font or this.font);

    gfx.UpdateLabel(
      this.label,
      params.text or this.text,
      params.size or this.size
    );

    this.w, this.h = gfx.LabelSize(this.label);
  end,
};

return Label;