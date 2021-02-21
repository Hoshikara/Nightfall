local layout = require('layout/dialog');

local New = function(strings)
  local labels = {};

  loadFont('normal');

  labels.heading = New.Label({ text = strings.heading, size = 48 });
  
  loadFont('medium');

  labels.confirm = New.Label({ text = 'CONFIRM', size = 18 });
  labels.enter = New.Label({ text = '[ENTER]', size = 18 });
  labels.inputLabel = New.Label({ text = strings.inputLabel, size = 18 });
  
  loadFont('jp');

  labels.inputText = New.Label({ text = '', size = 28 });

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
  
      loadFont('jp');
      self.labels.inputText:update({ new = string.upper(textInput.text) });
  
      self.cursor.offset = math.min(
        self.labels.inputText.w + 2, layout.w.middle - 20
      );
  
      local x = layout.x.middleLeft;
      local y = layout.y.center
        + (layout.h.outer / 10)
        + (self.labels.inputLabel.h * 2);
      local labelY = layout.y.center + (layout.h.outer / 10);

      drawRectangle({
        x = x,
        y = y,
        w = layout.w.middle,
        h = layout.h.outer / 6,
        alpha = 255 * self.timer,
        color = 'dark',
        stroke = {
          alpha = 255 * self.timer,
          color = 'normal',
          size = 1,
        },
      });
  
      drawRectangle({
        x = x + 8 + self.cursor.offset,
        y = y + 10,
        w = 2,
        h = (layout.h.outer / 6) - 20,
        alpha = 255 * self.cursor.alpha,
        color = 'white',
      });

  
      gfx.Save();
  
      gfx.BeginPath();
      alignText('left');
  
      self.labels.inputLabel:draw({
        x = layout.x.middleLeft - 2,
        y = labelY,
        alpha = 255 * self.timer,
        color = 'normal',
      });
  
      labelY = labelY + (self.labels.inputLabel.h * 2);
  
      self.labels.inputText:draw({
        x = x + 8,
        y = labelY + 7,
        alpha = 255 * self.timer,
        color = 'white',
        maxWidth = layout.w.middle - 22,
      });
  
      labelY = labelY + (layout.h.outer / 6);
  
      gfx.BeginPath();
      alignText('right');
  
      self.labels.confirm:draw({
        x = layout.x.middleRight + 2,
        y = labelY + self.labels.confirm.h + 1,
        alpha = 255 * self.timer,
        color = 'white',
      });
  
      self.labels.enter:draw({
        x = layout.x.middleRight - self.labels.confirm.w - 8,
        y = labelY + self.labels.confirm.h,
        alpha = 255 * self.timer,
        color = 'normal',
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
        alpha = self.timer,
        centered = true,
      });
  
      gfx.BeginPath();
      alignText('left');
      self.labels.heading:draw({
        x = layout.x.outerLeft,
        y = layout.y.top - (self.labels.heading.h * 0.25),
        alpha = 255 * self.timer,
        color = 'white',
      });
  
      self:drawInput(deltaTime);
  
      gfx.Restore();
    end,
  };
end

return { New = New };