local Cursor = require('components/common/cursor');
local List = require('components/common/list');
local Scrollbar = require('components/common/scrollbar');

local Order = {
  'name',
  'capacity',
  'password',
  'status',
};

---@class RoomsClass
local Rooms = {
  -- Rooms constructor
  ---@param this Rooms
  ---@param mouse Mouse
  ---@param state Multiplayer
  ---@return Rooms
  new = function(this, window, mouse, state)
    ---@class Rooms : RoomsClass
    local t = {
      alpha = 0,
      alphaTimer = 0,
      cache = { w = 0, h = 0 },
      cursor = Cursor:new({
        size = 16,
        stroke = 1.5,
        type = 'vertical',
      }),
      images = {
				btn = Image:new('buttons/normal.png'),
        btnH = Image:new('buttons/normal_hover.png'),
			},
      labels = {
        capacity = makeLabel('med', 'CAPACITY'),
        create = makeLabel('med', 'CREATE ROOM'),
        heading = makeLabel('norm', 'MULTIPLAYER ROOMS', 60),
        name = makeLabel('med', 'NAME'),
        nav = makeLabel(
					'med',
					{
            { color = 'norm', text = '[KNOB-L]  /  [KNOB-R]' },
						{ color = 'white', text = 'SELECT ROOM' },
					},
					20
				),
        password = makeLabel('med', 'PASSWORD'),
        start = makeLabel(
					'med',
					{
            { color = 'norm', text = '[START]' },
						{ color = 'white', text = 'ENTER ROOM' },
					},
					20
				),
        status = makeLabel('med', 'STATUS'),
      },
      list = List:new(),
      margin = 0,
      max = 5,
      mouse = mouse,
      padding = 0,
      roomCount = 0,
      rooms = {},
      scrollbar = Scrollbar:new(),
      state = state,
      timer = 0,
      window = window,
      x = { list = 0, text = {} },
      y = 0,
      w = 0,
      h = { item = 0, list = 0 },
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  -- Sets the sizes for the current component
  ---@param this Rooms
  setSizes = function(this)
    if ((this.cache.w ~= this.window.w) or (this.cache.h ~= this.window.h)) then
      if (this.window.isPortrait) then
        this.max = 10;

        this.y = this.window.h / 10;

        this.w = this.window.w - (this.window.padding.x * 2);

        this.h.list = this.window.h - (this.window.h / 4);
        this.h.item = this.h.list // 13;

        this.padding = this.h.item // 4;

        local spacing = (this.w - (this.padding * 2)) / 8;

        this.x.text[1] = 0;
        this.x.text[2] = spacing * 3.75;
        this.x.text[3] = spacing * 5.25;
        this.x.text[4] = spacing * 6.75;
      else
        this.max = 5;

        this.y = this.window.h / 6;

        this.w = this.window.w / 1.75;

        this.h.list = this.window.h - (this.window.h / 3);
        this.h.item = this.h.list // 6.5;

        this.padding = this.h.item // 4;

        local spacing = (this.w - (this.padding * 2)) / 8;

        this.x.text[1] = 0;
        this.x.text[2] = spacing * 4;
        this.x.text[3] = spacing * 5.5;
        this.x.text[4] = spacing * 7;
      end

      this.x.list = (this.window.w / 2) - (this.w / 2);

      this.margin = (this.h.list - (this.h.item * this.max)) / (this.max - 1);

      this.cursor:setSizes({
        x = this.x.list,
        y = this.y,
        w = this.w,
        h = this.h.item,
        margin = this.margin,
      });

      this.list:setSizes({ max = this.max, shift = this.h.list + this.margin });

      this.scrollbar:setSizes({
        x = this.window.w - (this.window.w / 40) - 4,
        y = this.y,
        h = this.h.list,
      });

      this.cache.w = this.window.w;
      this.cache.h = this.window.h;
    end
  end,

  -- Parse and format room data
  ---@param this Rooms
  makeRooms = function(this)
    if (this.roomCount ~= this.state.roomCount) then
      this.rooms = {};

      for i, room in ipairs(this.state.roomList) do
        this.rooms[i] = {
          capacity = makeLabel(
            'num',
            ('%02d  /  %02d'):format(room.current, room.max),
            24
          ),
          name = makeLabel('norm', room.name),
          password = makeLabel('norm', (room.password and 'YES') or 'NO'),
          status = makeLabel('norm', (room.ingame and 'IN GAME') or 'IN LOBBY'),
        };
      end

      this.roomCount = this.state.roomCount;
    end
  end,

  -- Draw the list of rooms
  ---@param this Rooms
  drawList = function(this)
    local y = 0;

    gfx.Save();

    gfx.Translate(this.x.list, this.y + this.list.offset);

    for i, room in ipairs(this.rooms) do
      y = y + this:drawRoom(y, room, this.list:onPage(i));
    end

    gfx.Restore();
  end,

  -- Draw an individual room
  ---@param this Rooms
  ---@param y number
  ---@param room table
  ---@param isVis boolean
  drawRoom = function(this, y, room, isVis)
    local x = this.padding;

    if (isVis) then
      drawRect({
        x = 0,
        y = y,
        w = this.w,
        h = this.h.item,
        alpha = 180,
        color = 'dark',
      });

      y = y + this.padding;

      ---@param name string
      for i, name in ipairs(Order) do
        this.labels[name]:draw({ x = x + this.x.text[i], y = y });

        room[name]:draw({
          x = x + this.x.text[i],
          y = y + (this.labels[name].h * 1.35),
          color = 'white',
        });
      end
    end
    
    return this.h.item + this.margin;
  end,

  -- Draw the room creation button
  ---@param this Rooms
  ---@param allowClick boolean
  drawBtn = function(this, allowClick)
    local x = (this.window.w / 2) - (this.images.btn.w / 2);
    local y = this.window.h - (this.window.h / 20) - this.images.btn.h;

    if (this.window.isPortrait) then y = y - 40; end

    local isClickable = allowClick and this.mouse:clipped(
      x,
      y,
      this.images.btn.w,
      this.images.btn.h
    );

    if (isClickable) then
      this.state.btnEvent = this.state.makeRoom;

      this.images.btnH:draw({ x = x, y = y });
    else
      this.images.btn:draw({
        x = x,
        y = y,
        alpha = 0.45,
      });
    end

    this.labels.create:draw({
      x = x + (this.images.btn.w / 8),
      y = y + (this.images.btn.h / 2) - 11,
      alpha = (isClickable and 255) or 50,
      color = 'white',
    });
  end,

  -- Handle navigation to and away the component
  ---@param this Rooms
  handleChange = function(this, dt, isSelecting)
    if (isSelecting) then
      if (this.alphaTimer > 0) then
        this.alphaTimer = to0(this.alphaTimer, dt, 0.167);
      end
    else
      this.alphaTimer = to1(this.alphaTimer, dt, 0.125);
    end

    this.alpha = 255 - (180 * this.alphaTimer);
  end,

  -- Renders the current component
  ---@param this Rooms
  ---@param dt deltaTime
  ---@param isSelecting boolean # user is selecting a room
  render = function(this, dt, isSelecting)
    this:setSizes();
    
    this:makeRooms();

    this:handleChange(dt, isSelecting);

    gfx.Save();

    this.labels.heading:draw({
      x = this.window.padding.x,
      y = this.window.padding.y,
      color = 'white',
    });

    if (this.roomCount > 0) then
      this.list:handleChange(dt, { watch = this.state.currRoom });

      this:drawList();

      if (isSelecting) then
        this.cursor:render(dt, { curr = this.state.currRoom, total = this.max });

        if (this.roomCount > this.max) then
          this.scrollbar:render(dt, {
            curr = this.state.currRoom,
            total = this.roomCount,
          });
        end
      end

      this.labels.nav:draw({
        x = this.window.padding.x + 4,
        y = this.window.h - this.window.padding.y - (this.labels.nav.h * 3),
      });

      this.labels.start:draw({
        x = this.window.padding.x + 4,
        y = this.window.h - this.window.padding.y - (this.labels.nav.h * 1.5),
      });
    end

    if (not this.state.loading) then this:drawBtn(isSelecting); end

    drawRect({
      w = this.window.w,
      h = this.window.h,
      alpha = 200 * this.alphaTimer,
      color = 'black',
      fast = true,
    });

    gfx.Restore();
  end,
};

return Rooms;