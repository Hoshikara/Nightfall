background.LoadTexture("mainTex", "bg.png")
background.SetSpeedMult(0.1)

function render_bg(deltaTime)
  background.DrawShader()
end
