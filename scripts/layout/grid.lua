local New = function(isSongSelect)
  local width = 0;

  if (isSongSelect) then
    local image = New.Image({ path = 'common/panel.png' });

    width = image.w;
  else
    local image = New.Image({ path = 'common/panel_wide.png' });

    width = image.w;
  end

  return {
    cache = { scaledW = 0, scaledH = 0 },
    dropdown = {
      [1] = {},
      [2] = {},
      [3] = {},
      padding = 24,
      start = 0,
      y = 0,
    },
    field = {
      [1] = {},
      [2] = {},
      [3] = {},
      height = nil,
      y = 0,
    },
    grid = {},
    panel = { width = width },
    label = { height = nil },
    
    setSizes = function(self, scaledW, scaledH)
      if (not self.field.height) then
        Font.Normal();

        local tempField = New.Label({ text = 'TEMPFIELD', size = 24 });

        self.field.height = tempField.h;
      end

      if (not self.label.height) then
        Font.Medium();

        local tempLabel = New.Label({ text = 'TEMPLABEL', size = 24 });

        self.label.height = tempLabel.h;
      end
    
      if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
        self.panel.width = scaledW / (1920 / self.panel.width);
  
        self.grid.size = (scaledW - ((scaledW / 20) * 3) - self.panel.width);
  
        self.jacketSize = self.grid.size // 3.3;
  
        self.grid.gutter = (self.grid.size - (self.jacketSize * 3)) // 2;
        self.grid.x = (scaledW / 10) + self.panel.width;
            
        self.field[1].x = self.grid.x - 1;
        self.field[2].x = self.field[1].x
          + (self.jacketSize * 1.5) + self.grid.gutter;
        self.field[3].x = self.field[2].x + (self.jacketSize * 0.9);
        self.field[1].maxWidth = (self.jacketSize * 1.65)	- (self.dropdown.padding * 2);
        self.field.y = (scaledH / 20) + self.label.height;
      
        self.dropdown[1].x = self.field[1].x;
        self.dropdown[2].x = self.field[2].x;
        self.dropdown[3].x = self.field[3].x;
        self.dropdown[1].maxWidth = (self.jacketSize * 3)
          + (self.grid.gutter * 2)
          - (self.dropdown.padding * 2);
        self.dropdown.start = self.dropdown.padding - 7;
        self.dropdown.y = self.field.y + (self.field.height * 1.5);
        
        self.cache.scaledW = scaledW;
        self.cache.scaledH = scaledH;
      end
    end,
  };
end

return { New = New };