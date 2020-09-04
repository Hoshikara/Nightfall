local transitionTimer = 0
local resx, resy = game.GetResolution()
local outTimer = 1


function render(deltaTime)
    render_bars(transitionTimer)
    transitionTimer = transitionTimer + deltaTime * 2
    transitionTimer = math.min(transitionTimer,1)
    return transitionTimer >= 1
end

function render_out(deltaTime)
    outTimer = outTimer + deltaTime * 2
    outTimer = math.min(outTimer, 2)
    render_bars(outTimer)
    return outTimer >= 2;
end

function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

function render_bars(progress)
    for i=0,resx/50 do
        local dir = sign((i % 2) - 0.5)
        local yoff = dir * resy * (1 - progress)
        gfx.Save()
        gfx.Translate(0,yoff)
        gfx.BeginPath()
        gfx.Rect(60 * i, yoff, 60, resy)
        if ((i % 2) == 0) then
            gfx.FillColor(16, 32, 48, 255);
        else
            gfx.FillColor(24, 48, 72, 255);
        end
        gfx.Fill()
        gfx.Restore()
    end
end

function reset()
    transitionTimer = 0
    resx, resy = game.GetResolution()
    outTimer = 1
end