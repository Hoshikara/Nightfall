---@class ListClass
local List = {
  -- List constructor
  ---@param this ListClass
  ---@return List
  new = function(this)
    ---@class List : ListClass
    local t = {
      currPage = 0,
      max = 0,
      offset = 0,
      prev = 0,
      shift = 0,
      timer = 0,
      watching = nil,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this List
  ---@param params table #
  -- ```
  -- {
  --   max: number = 0, // number of items on a page
  --   shift: number = 0, // width or height of a page, in pixels
  -- }
  -- ```
  setSizes = function(this, params)
    this.max = params.max or 0;
    this.shift = params.shift or 0;
  end,

  -- Get the page of the list that the given item is on
  ---@param this List
  ---@param i number # current item index
  ---@return number
  getPage = function(this, i) return math.floor((i - 1) / this.max) + 1; end,

  -- Determine if the given item is on the current page
  ---@param this List
  ---@param i number # current item index
  onPage = function(this, i)
    return (i > ((this.currPage - 1) * this.max))
      and (i <= (this.currPage * this.max));
  end,

  -- Sets the offset for the current list
  ---@param this List
  ---@param dt deltaTime
  ---@param params table #
  -- ```
  -- {
  --   watch: integer,
  --   duration?: number,
  -- }
  -- ```
  handleChange = function(this, dt, params)
    local duration = params.duration or 0.25;

    if (this.watching ~= params.watch) then
      local currPage = this:getPage(params.watch);

      if (this.currPage ~= currPage) then
        this.timer = 0;

        this.currPage = currPage;
      end

      this.watching = params.watch;
    end

    if (this.timer < 1) then
      this.timer = to1(this.timer, dt, duration);

      local shift = (this.shift * (this.currPage - 1)) * -1;

      this.offset = this.prev + (shift - this.prev) * smoothstep(this.timer);
      this.prev = this.offset;
    end
  end,
};

return List;