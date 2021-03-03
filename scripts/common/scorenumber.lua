local New = function(params)
  local labels = {};
  local w = 0;

  if (params.isScore) then
    for i = 1, 4 do
      labels[i] = New.Label({
        font = 'number',
        text = '0',
        size = params.sizes[1],
      });
      labels[i + 4] = New.Label({
        font = 'number',
        text = '0',
        size = params.sizes[2],
      });
    end
  else
    for i = 1, params.digits do
      labels[i] = New.Label({
        font = 'number',
        text = '0',
        size = params.sizes[1],
      });

      w = w + labels[i].w;
    end
  end

  return {
    alpha = {},
    digits = {},
    isScore = params.isScore,
    labels = labels,
    position = {},
    w = w * 0.75,

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
      local align = params.align or 'left';
      local alpha = params.alpha or 255;
      local color = params.color or 'normal';
      
      if (self.isScore) then
        local offset = params.offset or 0;
        local y1 = params.y1 or 0;
        local y2 = params.y2 or 0;
  
        for i = 1, 4 do
          self.labels[i]:update({ new = self.digits[i] });
          self.labels[i + 4]:update({ new = self.digits[i + 4] });

          drawLabel({
            x = x + self.position[i],
            y = y1,
            align = align,
            alpha = alpha * self.alpha[i],
            color = 'white',
            label = self.labels[i],
          });

          drawLabel({
            x = x + offset + self.position[i + 4],
            y = y2,
            align = align,
            alpha = alpha * self.alpha[i + 4],
            color = color,
            label = self.labels[i + 4],
          });
        end
      else
        local y = params.y or 0;

        for i = 1, #self.labels do
          self.labels[i]:update({ new = self.digits[i] });

          drawLabel({
            x = x + self.position[i],
            y = y,
            align = align,
            alpha = alpha * self.alpha[i],
            color = color,
            label = self.labels[i],
          });
        end
      end
    end,
  };
end

return { New = New };