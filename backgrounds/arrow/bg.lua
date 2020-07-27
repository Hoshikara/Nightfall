background.LoadTexture("mainTex", "bg.png")
background.LoadTexture("mainTexClear", "bg_clear.png")

function render_bg(deltaTime)
  background.DrawShader()
end
