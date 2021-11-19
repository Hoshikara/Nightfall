--Horizontal alignment
TEXT_ALIGN_LEFT 	= 1
TEXT_ALIGN_CENTER 	= 2
TEXT_ALIGN_RIGHT 	= 4
--Vertical alignment
TEXT_ALIGN_TOP 		= 8
TEXT_ALIGN_MIDDLE	= 16
TEXT_ALIGN_BOTTOM	= 32
TEXT_ALIGN_BASELINE	= 64

local jacket = nil;
local selectedIndex = 1
local selectedDiff = 1
local songCache = {}
local ioffset = 0
local doffset = 0
local soffset = 0
local diffColors = {{0,0,255}, {0,255,0}, {255,0,0}, {255, 0, 255}}
local timer = 0
local scrollmul = 0
local scrollmulOffset = 0 -- bc we have min/max the game doesn't know we have to account for extra
local effector = 0
local searchText = gfx.CreateLabel("",5,0)
local searchIndex = 1
local jacketFallback = gfx.CreateSkinImage("song_select/loading.png", 0)
local showGuide = game.GetSkinSetting("show_guide")
local legendTable = {
  {["labelSingleLine"] =  gfx.CreateLabel("SCROLL INFO",16, 0), ["labelMultiLine"] =  gfx.CreateLabel("SCROLL\nINFO",16, 0), ["image"] = gfx.CreateSkinImage("legend/knob-left.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("CHALL SELECT",16, 0),      ["labelMultiLine"] =  gfx.CreateLabel("CHALLENGE\nSELECT",16, 0),      ["image"] = gfx.CreateSkinImage("legend/knob-right.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("FILTER CHALLS",16, 0),      ["labelMultiLine"] =  gfx.CreateLabel("FILTER\nCHALLENGES",16, 0),      ["image"] = gfx.CreateSkinImage("legend/FX-L.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("SORT CHALLS",16, 0),        ["labelMultiLine"] =  gfx.CreateLabel("SORT\nCHALLENGES",16, 0),        ["image"] = gfx.CreateSkinImage("legend/FX-R.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("GAME SETTINGS",16, 0),        ["labelMultiLine"] =  gfx.CreateLabel("GAME\nSETTINGS",16, 0),        ["image"] = gfx.CreateSkinImage("legend/FX-LR.png", 0)},
  {["labelSingleLine"] =  gfx.CreateLabel("PLAY",16, 0),              ["labelMultiLine"] =  gfx.CreateLabel("PLAY",16, 0),               ["image"] = gfx.CreateSkinImage("legend/start.png", 0)}
}
local grades = {
  {["max"] = 6999999, ["image"] = gfx.CreateSkinImage("score/D.png", 0)},
  {["max"] = 7999999, ["image"] = gfx.CreateSkinImage("score/C.png", 0)},
  {["max"] = 8699999, ["image"] = gfx.CreateSkinImage("score/B.png", 0)},
  {["max"] = 8999999, ["image"] = gfx.CreateSkinImage("score/A.png", 0)},
  {["max"] = 9299999, ["image"] = gfx.CreateSkinImage("score/A+.png", 0)},
  {["max"] = 9499999, ["image"] = gfx.CreateSkinImage("score/AA.png", 0)},
  {["max"] = 9699999, ["image"] = gfx.CreateSkinImage("score/AA+.png", 0)},
  {["max"] = 9799999, ["image"] = gfx.CreateSkinImage("score/AAA.png", 0)},
  {["max"] = 9899999, ["image"] = gfx.CreateSkinImage("score/AAA+.png", 0)},
  {["max"] = 99999999, ["image"] = gfx.CreateSkinImage("score/S.png", 0)}
}

local badges = {
    gfx.CreateSkinImage("badges/played.png", 0),
    gfx.CreateSkinImage("badges/clear.png", 0),
    gfx.CreateSkinImage("badges/hard-clear.png", 0),
    gfx.CreateSkinImage("badges/full-combo.png", 0),
    gfx.CreateSkinImage("badges/perfect.png", 0)
}

gfx.LoadSkinFont("SmartFontUI.otf");

local wheelSize = 12

get_page_size = function()
    return math.floor(wheelSize/2)
end

-- Responsive UI variables
-- Aspect Ratios
local aspectFloat = 1.850
local aspectRatio = "widescreen"
local landscapeWidescreenRatio = 1.850
local landscapeStandardRatio = 1.500
local portraitWidescreenRatio = 0.5

-- Responsive sizes
local fifthX = 0
local fourthX= 0
local thirdX = 0
local halfX  = 0
local fullX  = 0

local fifthY = 0
local fourthY= 0
local thirdY = 0
local halfY  = 0
local fullY  = 0


adjustScreen = function(x,y)
  local a = x/y;
  if x >= y and a <= landscapeStandardRatio then
    aspectRatio = "landscapeStandard"
    aspectFloat = 1.1
  elseif x >= y and landscapeStandardRatio <= a and a <= landscapeWidescreenRatio then
    aspectRatio = "landscapeWidescreen"
    aspectFloat = 1.2
  elseif x <= y and portraitWidescreenRatio <= a and a < landscapeStandardRatio then
    aspectRatio = "PortraitWidescreen"
    aspectFloat = 0.5
  else
    aspectRatio = "landscapeWidescreen"
    aspectFloat = 1.0
  end
  fifthX = x/5
  fourthX= x/4
  thirdX = x/3
  halfX  = x/2
  fullX  = x

  fifthY = y/5
  fourthY= y/4
  thirdY = y/3
  halfY  = y/2
  fullY  = y
end


check_or_create_cache = function(song, full)
    if not songCache[song.id] then songCache[song.id] = {} end

    if not songCache[song.id]["title"] then
        songCache[song.id]["title"] = gfx.CreateLabel(song.title, 40, 0)
    end

    if not songCache[song.id]["chart_names"] then
        local names = "Charts:"
        for _, chart in ipairs(song.charts) do
          names = names .. " [" .. chart.title .. "]"
        end
        if song.missing_chart then
          names = names .. " *COULD NOT FIND ALL CHARTS!*"
        end
        songCache[song.id]["chart_names"] = gfx.CreateLabel(names, 20, 0)
    end
    if song.topBadge ~= 0 and (
        not songCache[song.id]["percent"] or
        not songCache[song.id]["percent_value"] or
        songCache[song.id]["percent_value"] ~= song.bestScore) then
      songCache[song.id]["percent"] = gfx.CreateLabel(string.format("%u%% Complete", math.max(0,(song.bestScore - 8000000)//10000)), 35, 0)
      songCache[song.id]["percent_value"] = song.bestScore
    end
    if full then
      if not songCache[song.id]["jackets"] then
        local jackets = {}
        for i, chart in ipairs(song.charts) do
          jackets[i] = gfx.LoadImageJob(chart.jacketPath, jacketFallback, 200,200)
        end
        songCache[song.id]["jackets"] = jackets
      end
      if not songCache[song.id]["desc"] then
        local desc = "Charts:\n"
        for _, chart in ipairs(song.charts) do
          desc = desc .. "  " .. chart.title .. "\n"
        end
        if song.missing_chart then
          desc = desc .. "  *COULD NOT FIND ALL CHARTS!*\n"
        end
        desc = desc .. "\nGoal:\n" .. song.requirement_text
        songCache[song.id]["desc"] = gfx.CreateLabel(desc, 20, 0)
      end
    end
end

draw_scores = function(difficulty, x, y, w, h)
  -- draw the top score for this difficulty
	local xOffset = 5
  local height = h/3 - 10
  local ySpacing = h/3
	local yOffset = h/3
  gfx.FontSize(30);
  gfx.TextAlign(gfx.TEXT_ALIGN_BOTTOM + gfx.TEXT_ALIGN_CENTER);
  gfx.FastText("HIGH SCORE", x +(w/2), y+(h/2))
  gfx.BeginPath()
  gfx.Rect(x+xOffset,y+h/2,w-(xOffset*2),h/2)
  gfx.FillColor(30,30,30,10)
  gfx.StrokeColor(0,128,255)
  gfx.StrokeWidth(1)
  gfx.Fill()
  gfx.Stroke()
	if difficulty.scores[1] ~= nil then
		local highScore = difficulty.scores[1]
    scoreLabel = gfx.CreateLabel(string.format("%08d",highScore.score), 40, 0)
    for i,v in ipairs(grades) do
      if v.max > highScore.score then
        gfx.BeginPath()
        iw,ih = gfx.ImageSize(v.image)
        iar = iw / ih;
        gfx.ImageRect(x+xOffset,y+h/2 +5, iar * (h/2-10),h/2-10, v.image, 1, 0)
        break
      end
    end
    if difficulty.topBadge ~= 0 then
        gfx.BeginPath()
        gfx.ImageRect(x+xOffset+w-h/2, y+h/2 +5, (h/2-10), h/2-10, badges[difficulty.topBadge], 1, 0)
    end
    gfx.FillColor(255,255,255)
		gfx.FontSize(40);
    gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_CENTER);
		gfx.DrawLabel(scoreLabel, x+(w/2),y+(h/4)*3,w)
	end
end

draw_song = function(song, x, y, w, h, selected)
    check_or_create_cache(song)
    gfx.BeginPath()
    gfx.RoundedRectVarying(x,y, w, h,0,0,0,40)
    gfx.FillColor(30,30,30)
    gfx.StrokeColor(0,128,255)
    gfx.StrokeWidth(1)
    if selected then
        gfx.StrokeColor(255,128,0)
        gfx.StrokeWidth(2)
    end
    gfx.Fill()
    gfx.Stroke()
    gfx.FillColor(255,255,255)
    gfx.TextAlign(gfx.TEXT_ALIGN_TOP + gfx.TEXT_ALIGN_LEFT)
    gfx.DrawLabel(songCache[song.id]["title"], x+10, y + 5, w-10)
    if (song.missing_chart) then
      gfx.FillColor(255,20,20)
    end
    gfx.DrawLabel(songCache[song.id]["chart_names"], x+20, y + 50, w-10)

    --gfx.DrawLabel(songCache[song.id]["artist"], x+20, y + 50, w-10)
    gfx.ForceRender()

end

draw_diff_icon = function(diff, x, y, w, h, selected)
    local shrinkX = w/4
    local shrinkY = h/4
    if selected then
      gfx.FontSize(h/2)
      shrinkX = w/6
      shrinkY = h/6
    else
      gfx.FontSize(math.floor(h / 3))
    end
    gfx.BeginPath()
    gfx.RoundedRectVarying(x+shrinkX,y+shrinkY,w-shrinkX*2,h-shrinkY*2,0,0,0,0)
    gfx.FillColor(15,15,15)
    gfx.StrokeColor(table.unpack(diffColors[diff.difficulty + 1]))
    gfx.StrokeWidth(2)
    gfx.Fill()
    gfx.Stroke()
    gfx.FillColor(255,255,255)
    gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_CENTER)
    gfx.FastText(tostring(diff.level), x+(w/2),y+(h/2))
end

draw_cursor = function(x,y,rotation,width)
	gfx.Save()
    gfx.BeginPath();
    gfx.Translate(x,y)
    gfx.Rotate(rotation)
    gfx.StrokeColor(255,128,0)
    gfx.StrokeWidth(4)
    gfx.Rect(-width/2, -width/2, width, width)
    gfx.Stroke()
    gfx.Restore()
end

draw_diffs = function(diffs, x, y, w, h)
    local diffWidth = w/2.5
    local diffHeight = w/2.5
    local diffCount = #diffs
    gfx.Scissor(x,y,w,h)
    for i = math.max(selectedDiff - 2, 1), math.max(selectedDiff - 1,1) do
      local diff = diffs[i]
      local xpos = x + ((w/2 - diffWidth/2) + (selectedDiff - i + doffset)*(-0.8*diffWidth))
      if  i ~= selectedDiff then
        draw_diff_icon(diff, xpos, y, diffWidth, diffHeight, false)
      end
    end

    --after selected
  for i = math.min(selectedDiff + 2, diffCount), selectedDiff + 1,-1 do
      local diff = diffs[i]
      local xpos = x + ((w/2 - diffWidth/2) + (selectedDiff - i + doffset)*(-0.8*diffWidth))
      if  i ~= selectedDiff then
        draw_diff_icon(diff, xpos, y, diffWidth, diffHeight, false)
      end
    end
    local diff = diffs[selectedDiff]
    local xpos = x + ((w/2 - diffWidth/2) + (doffset)*(-0.8*diffWidth))
  draw_diff_icon(diff, xpos, y, diffWidth, diffHeight, true)
  gfx.BeginPath()
  gfx.FillColor(0,128,255)
  gfx.Rect(x,y+10,2,diffHeight-h/6)
  gfx.Fill()
  gfx.BeginPath()
  gfx.Rect(x+w-2,y+10,2,diffHeight-h/6)
  gfx.Fill()
  gfx.ResetScissor()
  draw_cursor(x + w/2, y +diffHeight/2, timer * math.pi, diffHeight / 1.5)
end

draw_selected = function(song, x, y, w, h)
    check_or_create_cache(song, true)
    -- set up padding and margins
    local xPadding = math.floor(w/16)
    local yPadding =  math.floor(h/32)
    local xMargin = math.floor(w/16)
    local yMargin =  math.floor(h/32)
    local width = (w-(xMargin*2))
    local height = (h-(yMargin*2))
    local xpos = x+xMargin
    local ypos = y+yMargin
    if aspectRatio == "PortraitWidescreen" then
      xPadding = math.floor(w/64)
      yPadding =  math.floor(h/32)
      xMargin = math.floor(w/64)
      yMargin =  math.floor(h/32)
      width = (w-(xMargin*2))
      height = (h-(yMargin*2))
      xpos = x+xMargin
      ypos = y+yMargin
    end
    --Border
    --local diff = song.difficulties[selectedDiff]
    gfx.BeginPath()
    gfx.RoundedRectVarying(xpos,ypos,width,height,yPadding,yPadding,yPadding,yPadding)
    gfx.FillColor(30,30,30)
    gfx.StrokeColor(0,128,255)
    gfx.StrokeWidth(1)
    gfx.Fill()
    gfx.Stroke()
    -- jacket should take up 1/3 of height, always be square, and be centered
    local imageSize = math.floor(height/2)
    local imageXPos = ((width/2) - (imageSize/2)) + x+xMargin
    if aspectRatio == "PortraitWidescreen" then
      --Unless its portrait widesreen..
      imageSize = math.floor((height/2)*2)-10
      imageXPos = x+xMargin+xPadding
    end

    local square_size = math.ceil(math.sqrt(#song.charts))
    local origImageSize = imageSize
    imageSize = math.floor(imageSize / square_size)
    local bottom_off = math.ceil((square_size*square_size - #song.charts) * imageSize/2)



    local img_row = 0;
    local img_col = 0;
    for i, chart in ipairs(song.charts) do
        if songCache[song.id]["jackets"][i] == jacketFallback then
          songCache[song.id]["jackets"][i] = gfx.LoadImageJob(chart.jacketPath, jacketFallback, 200,200)
        end
        gfx.BeginPath()
        local xoff = img_col * imageSize
        if math.ceil(i / square_size) == square_size then
            xoff = xoff + bottom_off
        end
        gfx.ImageRect(xoff + imageXPos, img_row * imageSize + y+yMargin+yPadding, imageSize, imageSize, songCache[song.id]["jackets"][i], 1, 0)
        img_col = img_col + 1
        if img_col >= square_size then
          img_row = img_row + 1
          img_col = 0
        end
    end

    local num_img_rows = img_row + 1
    if img_col == 0 then
      num_img_rows = img_row
    end

    --if songCache[song.id][selectedDiff] then
    --    gfx.BeginPath()
    --    gfx.ImageRect(imageXPos, y+yMargin+yPadding, imageSize, imageSize, songCache[song.id][selectedDiff], 1, 0)
    --end
    --gfx.ImageRect(imageXPos, y+yMargin+yPadding, imageSize, imageSize, jacketFallback, 1, 0)

    -- difficulty should take up 1/6 of height, full width, and be centered
    --if aspectRatio == "PortraitWidescreen" then
      --difficulty wheel should be right below the jacketImage, and the same width as
      --the jacketImage
    --  draw_diffs(song.difficulties,xpos+xPadding,(ypos+yPadding+imageSize),imageSize,math.floor((height/3)*1)-yPadding)
    --else
      -- difficulty should take up 1/6 of height, full width, and be centered
    --  draw_diffs(song.difficulties,(w/2)-(imageSize/2),(ypos+yPadding+imageSize),imageSize,math.floor(height/6))
    --end
    -- effector / bpm should take up 1/3 of height, full width

    local gradeImg = nil
    for i,v in ipairs(grades) do
      if v.max > song.bestScore then
        gfx.BeginPath()
        gradeImg = v.image
        break
      end
    end
    if scrollmul < 0 then
      scrollmulOffset = scrollmulOffset - scrollmul
      scrollmul = 0
    end
    local descw, desch = gfx.LabelSize(songCache[song.id]["desc"])
    local boxh, boxw = 0
    local starty, startx = 0

    if aspectRatio == "PortraitWidescreen" then
      gfx.FontSize(40)
      gfx.TextAlign(gfx.TEXT_ALIGN_TOP + gfx.TEXT_ALIGN_LEFT)
      starty = y+yMargin+yPadding
      startx = xpos+xPadding+origImageSize+10
      gfx.DrawLabel(songCache[song.id]["title"], startx, starty, width-origImageSize-30)
      gfx.FontSize(30)

      -- Scroll box info
      starty = starty + 50
      boxh = height - starty
      boxw = width-startx-200

      --gfx.DrawLabel(songCache[song.id]["artist"], xpos+xPadding+imageSize+3, y+yMargin+yPadding + 45, width-imageSize-20)
      --gfx.DrawLabel(songCache[song.id]["artist"], xpos+xPadding+imageSize+3, y+yMargin+yPadding + 45, width-imageSize-20)
      --gfx.FontSize(20)
      --gfx.DrawLabel(songCache[song.id]["bpm"], xpos+xPadding+imageSize+3, y+yMargin+yPadding + 85, width-imageSize-20)
      --gfx.FastText(string.format("Effector: %s", diff.effector), xpos+xPadding+imageSize+3, y+yMargin+yPadding + 115)
      if song.topBadge ~= 0 then
        gfx.BeginPath()
        gfx.ImageRect(width-40, height-50, 50, 50, badges[song.topBadge], 1, 0)
        local iar = 0
        if gradeImg ~= nil then
          gfx.BeginPath()
          local iw,ih = gfx.ImageSize(gradeImg)
          iar = iw/ih
          gfx.ImageRect(width-40-iar*50, height-50, iar * 50, 50, gradeImg, 1, 0)
        end
        gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_MIDDLE)
        gfx.DrawLabel(songCache[song.id]["percent"], width, height-65, 190)
      end
    else
      starty = (height/10)*6;
      if num_img_rows < square_size then
        starty = starty - imageSize*(square_size - num_img_rows)

      end
      gfx.FontSize(40)
      gfx.TextAlign(gfx.TEXT_ALIGN_TOP + gfx.TEXT_ALIGN_LEFT)
      gfx.DrawLabel(songCache[song.id]["title"], xpos+10, starty, width-20)

      -- Scroll box info
      boxh = height - starty - 45 - 50
      boxw = width-20
      startx = xpos + 10
      starty = starty + 45

      --gfx.DrawLabel(songCache[song.id]["artist"], xpos+10, (height/10)*6 + 45, width-20)
      --gfx.FillColor(255,255,255)
      --gfx.FontSize(20)
      --gfx.DrawLabel(songCache[song.id]["bpm"], xpos+10, (height/10)*6 + 85)
      if song.topBadge ~= 0 then
        gfx.BeginPath()
        gfx.ImageRect(width-25, height-40, 50, 50, badges[song.topBadge], 1, 0)
        local iar = 0
        local iw, ih = 0;
        if gradeImg ~= nil then
          gfx.BeginPath()
          iw,ih = gfx.ImageSize(gradeImg)
          iar = iw/ih
          gfx.ImageRect(xpos + 10, height-40, iar * 50, 50, gradeImg, 1, 0)
        end
        gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE )
        local ledge = iar * 50 + 20
        local redge = 50
        local maxLen = width - ledge - redge
        local center = ledge + (maxLen/2)
        gfx.DrawLabel(songCache[song.id]["percent"], center, height-16, maxLen)
      end
    end

    -- Render desc scrolling box
    do
      gfx.BeginPath()
      gfx.Rect(startx, starty, boxw, boxh)
      gfx.FillColor(50,50,50)
      gfx.Fill()

      local overBottom = desch - 100*scrollmul - boxh
      if overBottom < 0 and scrollmul > 0 then
        local scrollend = (desch - boxh)/100
        if scrollend < 0 then
          scrollend = 0
        end
        scrollmulOffset = scrollmulOffset - (scrollmul - scrollend)
        scrollmul = scrollend
      end

      -- Draw scroll bar
      if desch > boxh then
        gfx.BeginPath()
        local barStart = (100*scrollmul) / desch -- Start percent of visible desc
        local barh = (boxh / desch) * boxh
        gfx.Rect(startx + boxw - 5, starty + (barStart*boxh)//1, 5, barh//1)
        gfx.FillColor(20,20,20)
        gfx.Fill()
      end

      gfx.Scissor(startx, starty, boxw, boxh)

      gfx.BeginPath()
      gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP )
      gfx.DrawLabel(songCache[song.id]["desc"], startx+5, starty - (100*scrollmul)//1, boxw)

      gfx.ResetScissor()
    end
    --if aspectRatio == "PortraitWidescreen" then
    --  draw_scores(diff, xpos+xPadding+imageSize+3,  (height/3)*2, width-imageSize-20, (height/3)-yPadding)
    --else
    --  draw_scores(diff, xpos, (height/6)*5, width, (height/6))
    --end
    gfx.ForceRender()
end

draw_songwheel = function(x,y,w,h)
  local offsetX = fifthX/2
  local width = math.floor((w/5)*4)
  if aspectRatio == "landscapeWidescreen" then
    wheelSize = 12
    offsetX = 80
  elseif aspectRatio == "landscapeStandard" then
    wheelSize = 10
    offsetX = 40
  elseif aspectRatio == "PortraitWidescreen" then
    wheelSize = 20
    offsetX = 20
    width = w
  end
  local height = math.floor((h/wheelSize)*1.5)

  for i = math.max(selectedIndex - wheelSize/2, 1), math.max(selectedIndex - 1,0) do
      local song = chalwheel.challenges[i]
      local xpos = x + offsetX + ((selectedIndex - i + ioffset) ^ 2) * 3
      local offsetY = (selectedIndex - i + ioffset) * ( height - (wheelSize/2*((selectedIndex-i + ioffset)*aspectFloat)))
      local ypos = y+((h/2 - height/2) - offsetY)
      draw_song(song, xpos, ypos, width, height)
  end

  --after selected
  for i = math.min(selectedIndex + wheelSize/2, #chalwheel.challenges), selectedIndex + 1,-1 do
      local song = chalwheel.challenges[i]
      local xpos = x + offsetX + ((i - selectedIndex - ioffset) ^ 2) * 2
      local offsetY = (selectedIndex - i + ioffset) * ( height - (wheelSize/2*((i-selectedIndex - ioffset)*aspectFloat)))
      local ypos = y+((h/2 - height/2) - (selectedIndex - i) - offsetY)
      local alpha = 255 - (selectedIndex - i + ioffset) * 31
      draw_song(song, xpos, ypos, width, height)
  end
  -- draw selected
  local xpos = x + offsetX/1.2 + ((-ioffset) ^ 2) * 2
  local offsetY = (ioffset) * ( height - (wheelSize/2*((1)*aspectFloat)))
  local ypos = y+((h/2 - height/2) - (ioffset) - offsetY)
  draw_song(chalwheel.challenges[selectedIndex], xpos, ypos, width, height, true)
  return chalwheel.challenges[selectedIndex]
end
draw_legend_pane = function(x,y,w,h,obj)
  local xpos = x+5
  local ypos = y
  local imageSize = h
  gfx.BeginPath()
  gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_LEFT)
  gfx.ImageRect(x, y, imageSize, imageSize, o.image, 1, 0)
  xpos = xpos + imageSize + 5
  gfx.FontSize(16);
  if h < (w-(10+imageSize))/2 then
    gfx.DrawLabel(o.labelSingleLine, xpos, y+(h/2), w-(10+imageSize))
  else
    gfx.DrawLabel(o.labelMultiLine, xpos, y+(h/2), w-(10+imageSize))
  end
  gfx.ForceRender()
end

draw_legend = function(x,y,w,h)
  gfx.TextAlign(gfx.TEXT_ALIGN_MIDDLE + gfx.TEXT_ALIGN_LEFT);
  gfx.BeginPath()
  gfx.FillColor(0,0,0,170)
  gfx.Rect(x,y,w,h)
  gfx.Fill()
  local xpos = 10;
  local legendWidth = math.floor((w-20)/#legendTable)
  for i,v in ipairs(legendTable) do
    local xOffset = draw_legend_pane(xpos+(legendWidth*(i-1)), y+5,legendWidth,h-10,legendTable[i])
  end
end

draw_search = function(x,y,w,h)
  soffset = soffset + (searchIndex) - (chalwheel.searchInputActive and 0 or 1)
  if searchIndex ~= (chalwheel.searchInputActive and 0 or 1) then
  end
  searchIndex = chalwheel.searchInputActive and 0 or 1

  gfx.BeginPath()
  local bgfade = 1 - (searchIndex + soffset)
  --if not chalwheel.searchInputActive then bgfade = soffset end
  gfx.FillColor(0,0,0,math.floor(200 * bgfade))
  gfx.Rect(0,0,resx,resy)
  gfx.Fill()
  gfx.ForceRender()
  local xpos = x + (searchIndex + soffset)*w
  gfx.UpdateLabel(searchText ,string.format("Search: %s",chalwheel.searchText), 30, 0)
  gfx.BeginPath()
  gfx.RoundedRect(xpos,y,w,h,h/2)
  gfx.FillColor(30,30,30)
  gfx.StrokeColor(0,128,255)
  gfx.StrokeWidth(1)
  gfx.Fill()
  gfx.Stroke()
  gfx.BeginPath();
  gfx.LoadSkinFont("SmartFontUI.otf");
  gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
  gfx.DrawLabel(searchText, xpos+10,y+(h/2), w-20)

end

render = function(deltaTime)
    timer = (timer + deltaTime)
    timer = timer % 2
    resx,resy = game.GetResolution();
    adjustScreen(resx,resy);
    gfx.BeginPath();
    gfx.LoadSkinFont("SmartFontUI.otf");
    gfx.FontSize(40);
    gfx.FillColor(255,255,255);
    if chalwheel.challenges == nil then

    elseif chalwheel.challenges[1] ~= nil then
      --draw chalwheel and get selected song
      if aspectRatio == "PortraitWidescreen" then
        local song = draw_songwheel(0,0,fullX,fullY)
        --render selected song information
        draw_selected(song, 0,0,fullX,fifthY)
      else
        local song = draw_songwheel(fifthX*2,0,fifthX*3,fullY)
        --render selected song information
        draw_selected(song, 0,0,fifthX*2,(fifthY/2)*9)
      end
    end
    --Draw Legend Information
	if showGuide then
		if aspectRatio == "PortraitWidescreen" then
			draw_legend(0,(fifthY/3)*14, fullX, (fifthY/3)*1)
		else
			draw_legend(0,(fifthY/2)*9, fullX, (fifthY/2))
		end
	end

    --draw text search
    if aspectRatio == "PortraitWidescreen" then
      draw_search(fifthX*2,5,fifthX*3,fifthY/5)
    else
      draw_search(fifthX*2,5,fifthX*3,fifthY/3)
    end

    ioffset = ioffset * 0.9
    doffset = doffset * 0.9
    soffset = soffset * 0.8
	if chalwheel.searchStatus then
		gfx.BeginPath()
		gfx.FillColor(255,255,255)
		gfx.FontSize(20);
		gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
		gfx.Text(chalwheel.searchStatus, 3, 3)
	end
  gfx.LoadSkinFont("SmartFontUI.otf");
    gfx.ResetTransform()
    gfx.ForceRender()
end

set_index = function(newIndex, scrollamt)
    if newIndex ~= selectedIndex then
        scrollmulOffset = 0
    end
    ioffset = ioffset + selectedIndex - newIndex
    selectedIndex = newIndex
    scrollmul = scrollamt + scrollmulOffset
end;

local badgeRates = {
	0.5,  -- Played
	1.0,  -- Cleared
	1.02, -- Hard clear
	1.04, -- UC
	1.1   -- PUC
}

local gradeRates = {
	{["min"] = 9900000, ["rate"] = 1.05}, -- S
	{["min"] = 9800000, ["rate"] = 1.02}, -- AAA+
	{["min"] = 9700000, ["rate"] = 1},    -- AAA
	{["min"] = 9500000, ["rate"] = 0.97}, -- AA+
	{["min"] = 9300000, ["rate"] = 0.94}, -- AA
	{["min"] = 9000000, ["rate"] = 0.91}, -- A+
	{["min"] = 8700000, ["rate"] = 0.88}, -- A
	{["min"] = 7500000, ["rate"] = 0.85}, -- B
	{["min"] = 6500000, ["rate"] = 0.82}, -- C
	{["min"] =       0, ["rate"] = 0.8}   -- D
}

challenges_changed = function(withAll)
	if not withAll then return end
end
