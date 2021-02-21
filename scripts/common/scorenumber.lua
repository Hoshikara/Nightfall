local New = function(params)
  local labels = {};

  loadFont('number');

  if (params.isScore) then
    for i = 1, 4 do
      labels[i] = New.Label({ text = '0', size = params.sizes[1] });
      labels[i + 4] = New.Label({ text = '0', size = params.sizes[2] });
    end
  else
    for i = 1, params.digits do
      labels[i] = New.Label({ text = '0', size = params.sizes[1] });
    end
  end

  return {
    alpha = {},
    digits = {},
    isScore = params.isScore,
    labels = labels,
    position = {},

    setInfo = function(self, params)
      for i = 1, #self.labels do
        local breakpoint = 10 ^ (#self.labels - i);
  
        self.alpha[i] = ((params.value >= breakpoint) and 1) or 0.2;
        self.digits[i] = math.floor(params.value / breakpoint) % 10;

        if (i == 1) then
          self.position[i] = 0;
        else
          self.position[i] = self.position[i - 1] + self.labels[i].w;
        end
      end
    end,

    draw = function(self, params)
      local x = params.x or 0;
      local alpha = params.alpha or 255;
      local color = params.color or 'normal';

      loadFont('number');

      if (self.isScore) then
        local offset = params.offset or 0;
        local y1 = params.y1 or 0;
        local y2 = params.y2 or 0;
  
        for i = 1, 4 do
          self.labels[i]:update({ new = self.digits[i] });
          self.labels[i + 4]:update({ new = self.digits[i + 4] });

          self.labels[i]:draw({
            x = x + self.position[i],
            y = y1,
            alpha = alpha * self.alpha[i],
            color = 'white',
          });

          self.labels[i + 4]:draw({
            x = x + offset + self.position[i + 4],
            y = y2,
            alpha = alpha * self.alpha[i + 4],
            color = color,
          });
        end
      else
        local y = params.y or 0;

        for i = 1, #self.labels do
          self.labels[i]:update({ new = self.digits[i] });

          self.labels[i]:draw({
            x = x + self.position[i],
            y = y,
            alpha = alpha * self.alpha[i],
            color = color,
          });
        end
      end
    end,
  };
end

return { New = New };