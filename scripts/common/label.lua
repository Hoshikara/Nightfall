return function(params)
  loadFont(params.font);

  local label = gfx.CreateLabel(
    params.text or 'NO TEXT PROVIDED FOR LABEL',
    params.size or 42,
    0
  );
  local w, h = gfx.LabelSize(label);

  return {
    font = params.font or 'jp',
    label = label,
    size = params.size or 42,
    text = params.text or 'NO TEXT PROVIDED FOR LABEL',
    w = w,
    h = h,

    update = function(self, params)
      loadFont(self.font or params.font);

      gfx.UpdateLabel(
        self.label,
        params.new or '',
        params.size or self.size,
        0
      );

      self.w, self.h = gfx.LabelSize(self.label);
    end,
  };
end