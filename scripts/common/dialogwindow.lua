local layout = require('layout/dialog');

local New = function(strings)
  local labels = {};

  Font.Normal();

  labels.heading = Label.New(strings.heading, 48);
  
  Font.Medium();

  labels.confirm = Label.New('CONFIRM', 18);
  labels.enter = Label.New('[ENTER]', 18);
  labels.inputLabel = Label.New(strings.inputLabel, 18);
  
  Font.JP();

  labels.inputText = Label.New('', 28);

  return {
    cursor = {
      alpha = 0,
      offset = 0,
      timer = 0,
    },
    labels = labels,
    timer = 0,

    drawInput = function(self, deltaTime)
      self.cursor.timer = self.cursor.timer + deltaTime;
      self.cursor.alpha = self.timer
        * (math.abs(0.8 * math.cos(self.cursor.timer * 5)) + 0.2);
  
      Font.JP();
      self.labels.inputText:update({ new = string.upper(textInput.text) });
  
      self.cursor.offset = math.min(
        self.labels.inputText.w + 2, layout.w.middle - 20
      );
  
      local x = layout.x.middleLeft;
      local y = layout.y.center
        + (layout.h.outer / 10)
        + (self.labels.inputLabel.h * 2);
      local labelY = layout.y.center + (layout.h.outer / 10);
  
      gfx.BeginPath();
      gfx.StrokeWidth(1);
      gfx.StrokeColor(60, 110, 160, math.floor(255 * self.timer));
      Fill.Dark(255 * self.timer);
      gfx.Rect(x, y, layout.w.middle, layout.h.outer / 6);
      gfx.Fill();
      gfx.Stroke();
  
      gfx.BeginPath();
      Fill.White(255 * self.cursor.alpha);
      gfx.Rect(
        x + 8 + self.cursor.offset,
        y + 10,
        2,
        (layout.h.outer / 6) - 20
      );
      gfx.Fill();
  
      gfx.Save();
  
      gfx.BeginPath();
      FontAlign.Left();
  
      self.labels.inputLabel:draw({
        x = layout.x.middleLeft - 2,
        y = labelY,
        a = 255 * self.timer,
        color = 'Normal',
      });
  
      labelY = labelY + (self.labels.inputLabel.h * 2);
  
      self.labels.inputText:draw({
        x = x + 8,
        y = labelY + 7,
        a = 255 * self.timer,
        color = 'White',
        maxWidth = layout.w.middle - 22,
      });
  
      labelY = labelY + (layout.h.outer / 6);
  
      gfx.BeginPath();
      FontAlign.Right();
  
      self.labels.confirm:draw({
        x = layout.x.middleRight + 2,
        y = labelY + self.labels.confirm.h + 1,
        a = 255 * self.timer,
        color = 'White',
      });
  
      self.labels.enter:draw({
        x = layout.x.middleRight - self.labels.confirm.w - 8,
        y = labelY + self.labels.confirm.h,
        a = 255 * self.timer,
        color = 'Normal',
      });
  
      gfx.Restore();
    end,
  
    render = function(self, deltaTime, scaledW, scaledH)
      if (self.timer == 0) then return end

      layout:setSizes(scaledW, scaledH);
  
      gfx.Save();
  
      layout.images.dialogBox:draw({
        x = scaledW / 2,
        y = scaledH / 2,
        a = self.timer,
        centered = true,
      });
  
      gfx.BeginPath();
      FontAlign.Left();
      self.labels.heading:draw({
        x = layout.x.outerLeft,
        y = layout.y.top - (self.labels.heading.h * 0.25),
        a = 255 * self.timer,
        color = 'White',
      });
  
      self:drawInput(deltaTime);
  
      gfx.Restore();
    end,
  };
end

return { New = New };