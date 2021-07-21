game.LoadSkinSample('click-01');
game.LoadSkinSample('click-02');
game.LoadSkinSample('menu_click');

return {
  new = function(this)
    local t = {
      interval = 0,
      remaining = 0,
      sample = nil,
      time = 0,
    };

    setmetatable(t, this);
    this.__index = this;

    return t;
  end,

  trigger = function(this, num, times, interval)
    if (times) then
      this.sample = ((num == 1) and 'click-01') or 'click-02';
      this.interval = interval;
      this.remaining = times - 1;
      this.time = 0;

      game.PlaySample(this.sample);
    else
      game.PlaySample(((num == 1) and 'click-01') or 'click-02');
    end
  end,

  play = function(this, dt)
    if (not this.sample) then return; end

    this.time = this.time + dt;

    if (this.time > this.interval) then
      this.time = this.time - this.interval;

      game.PlaySample(this.sample);

      this.remaining = this.remaining - 1;

      if (this.remaining <= 0) then this.sample = nil; end
    end
  end,
};