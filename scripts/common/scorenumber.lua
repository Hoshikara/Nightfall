local New = function(params)
  local labels = {};

  Font.Number();

  if (params.isScore) then
    for i = 1, 4 do
      labels[i] = Label.New('0', params.sizes[1]);
      labels[i + 4] = Label.New('0', params.sizes[2]);
    end
  else
    for i = 1, params.digits do
      labels[i] = Label.New('0', params.sizes[1]);
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
      local alpha = params.a or 255;

      Font.Number();

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
            a = alpha * self.alpha[i],
            color = 'White',
          });

          self.labels[i + 4]:draw({
            x = x + offset + self.position[i + 4],
            y = y2,
            a = alpha * self.alpha[i + 4],
            color = 'Normal',
          });
        end
      else
        local y = params.y or 0;
        local color = params.color or 'Normal';

        for i = 1, #self.labels do
          self.labels[i]:update({ new = self.digits[i] });

          self.labels[i]:draw({
            x = x + self.position[i],
            y = y,
            a = alpha * self.alpha[i],
            color = color,
          });
        end
      end
    end,
  };
end

return { New = New };