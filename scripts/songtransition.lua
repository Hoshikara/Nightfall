local transitionTimer = 0
local resx, resy = game.GetResolution()
local outTimer = 1
local noJacket = gfx.CreateSkinImage("song_select/loading.png", 0)

function render(deltaTime)
    render_screen(transitionTimer)
    transitionTimer = transitionTimer + deltaTime * 2
    transitionTimer = math.min(transitionTimer,1)
    return transitionTimer >= 1
end

function render_out(deltaTime)
    outTimer = outTimer + deltaTime * 2
    outTimer = math.min(outTimer, 2)
    render_screen(outTimer)
    return outTimer >= 2;
end

function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function render_screen(progress)
    for i=0,resx/50 do
        local dir = sign((i % 2) - 0.5)
        local yoff = dir * resy * (1 - progress)
        gfx.Save()
        gfx.Translate(0,yoff)
        gfx.BeginPath()
        gfx.Rect(60 * i, yoff, 60, resy)
        gfx.FillColor(0,64, 150 + 25 * dir)
        gfx.Fill()
        gfx.Restore()
    end
    local y = (resy/2 + 100) * (math.sin(0.5 * progress * math.pi)^7) - 200
    gfx.Save()
    gfx.BeginPath()
    gfx.Translate(resx/2, y)
    local jacket = song.jacket == 0 and noJacket or song.jacket
    gfx.ImageRect(-150,-150,300,300,jacket,1,0)
    gfx.Restore()
    gfx.Translate(resx/2, resy - y - 50)
    gfx.FillColor(255,255,255)
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_TOP)
    gfx.FontSize(80)
    gfx.Text(song.title,0,0)
    gfx.FontSize(55)
    gfx.Text(song.artist,0,80)
end

function reset()
    transitionTimer = 0
    resx, resy = game.GetResolution()
    outTimer = 1
end