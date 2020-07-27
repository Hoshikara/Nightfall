background.LoadTexture("mainTex", "bg1.png")
background.LoadTexture("backTex", "bg2.png")

function render_bg(deltaTime)
  background.DrawShader()
end
