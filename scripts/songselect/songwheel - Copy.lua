easing = require('easing');

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
local selectedDiff = 1
local doffset = 0
local soffset = 0
local diffColors = {{0,0,255}, {0,255,0}, {255,0,0}, {255, 0, 255}}
local timer = 0
local effector = 0
local searchText = gfx.CreateLabel('',5,0)
local searchIndex = 1
local jacketFallback = gfx.CreateSkinImage('song_select/loading.png', 0)
local showGuide = game.GetSkinSetting('show_guide')

local grades = {
  {['max'] = 6999999, ['image'] = gfx.CreateSkinImage('score/D.png', 0)},
  {['max'] = 7999999, ['image'] = gfx.CreateSkinImage('score/C.png', 0)},
  {['max'] = 8699999, ['image'] = gfx.CreateSkinImage('score/B.png', 0)},
  {['max'] = 8999999, ['image'] = gfx.CreateSkinImage('score/A.png', 0)},
  {['max'] = 9299999, ['image'] = gfx.CreateSkinImage('score/A+.png', 0)},
  {['max'] = 9499999, ['image'] = gfx.CreateSkinImage('score/AA.png', 0)},
  {['max'] = 9699999, ['image'] = gfx.CreateSkinImage('score/AA+.png', 0)},
  {['max'] = 9799999, ['image'] = gfx.CreateSkinImage('score/AAA.png', 0)},
  {['max'] = 9899999, ['image'] = gfx.CreateSkinImage('score/AAA+.png', 0)},
  {['max'] = 99999999, ['image'] = gfx.CreateSkinImage('score/S.png', 0)}
}

local badges = {
    gfx.CreateSkinImage('badges/played.png', 0),
    gfx.CreateSkinImage('badges/clear.png', 0),
    gfx.CreateSkinImage('badges/hard-clear.png', 0),
    gfx.CreateSkinImage('badges/full-combo.png', 0),
    gfx.CreateSkinImage('badges/perfect.png', 0)
}

gfx.LoadSkinFont('NotoSans-Regular.ttf');

game.LoadSkinSample('menu_click')
game.LoadSkinSample('click-02')
game.LoadSkinSample('woosh')

-- START: SONG CACHING --
local songCache = {};

validateSongCache = function(song, shouldLoadJacket)
  if (not songCache[song.id]) then
    songCache[song.id] = {};
  end

  if (not songCache[song.id]['artist']) then
    songCache[song.id]['artist'] = gfx.CreateLabel(song.artist, 30, 0);
  end

  if (not songCache[song.id]['bpm']) then
    songCache[song.id]['bpm'] = gfx.CreateLabel(string.format('BPM: %s', song.bpm), 20, 0);
  end

  if ((not songCache[song.id]['jacket']) and shouldLoadJacket) then
    songCache[song.id]['jacket'] = gfx.CreateImage(song.difficulties[1].jacketPath, 0);
  end

  if (not songCache[song.id]['title']) then
    songCache[song.id]['title'] = gfx.CreateLabel(song.title, 40, 0);
  end
end
-- END: SONG CACHING --














local padding;
local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

resetLayout = function()
  resX, resY = game.GetResolution();
  scaledW = 1920;
  scaledH = scaledW * (resY / resX);
  scalingFactor = resX / scaledW;
  padding = scaledW / 36;

  gfx.Scale(scalingFactor, scalingFactor);
end

render = function(deltaTime)
  resetLayout();

  drawLayout();
end

logParams = function(x, y, params)
  local yPos = y;

  gfx.BeginPath();
  gfx.FontSize(40);
  gfx.FillColor(255, 255, 255);
  for k, v in pairs(params) do
    gfx.Text(k .. ': ' .. v, x, yPos);
    yPos = yPos + 40;
  end
  gfx.Fill();
end

local wheelSize = 15;
local pageIndex = 0;
local rowCount = 3;
local selectedIndex = 1;
local ioffset = 0;

get_page_size = function()
  return math.floor(wheelSize / 2);
end

getPageBounds = function(index)
  local pageStart = math.max(1 + index * rowCount, 1);
  local pageEnd = math.min((index + 3) * rowCount, #songwheel.songs);

  return pageStart, pageEnd;
end

local counter = 1;

drawAllSongs = function(x, y, w, h)
  local songWidth = math.floor(w / 3);
  local songHeight = math.floor(h / 3);
  local pageStart, pageEnd;

  pageStart, pageEnd = getPageBounds(pageIndex);

  newIndex = pageIndex;

  repeat
    if (selectedIndex < pageStart) then
      newIndex = newIndex - 1;
    end

    if (selectedIndex > pageEnd) then
      newIndex = newIndex + 1;
    end

    pageStart, pageEnd = getPageBounds(newIndex);
  until ((selectedIndex >= pageStart) and (selectedIndex <= pageEnd))

  ioffset = ioffset + pageIndex - newIndex;

  pageIndex = newIndex;

  local offsetScissor = songHeight / 2.6;

  logParams(
    10,
    40,
    {
      ['x'] = x,
      ['y'] = y,
      ['w'] = w,
      ['h'] = h,
      ['offsetScissor'] = offsetScissor,
      ['ioffset'] = ioffset,
      ['pageStart - 3'] = pageStart - 3,
      ['pageEnd + 3'] = pageEnd + 3,
      ['selectedIndex'] = selectedIndex
    }
  );

  gfx.Scissor(x, y-offsetScissor, w, h+ songHeight);

  for i = (pageStart - 3), (pageEnd + 3) do
    local song = songwheel.songs[i];
    local isSelected = (i == selectedIndex);
    local iOff = i - pageStart;

    if (song ~= nil) then
      drawSingleSong(
        x+songWidth * (iOff % rowCount),
        y+songHeight * (math.floor(iOff / rowCount) - ioffset),
        songHeight,
        songHeight,
        song,
        isSelected
      );
    end

    counter = counter + 1;
  end

  gfx.ResetScissor();
  gfx.ForceRender();
end

logText = function(text, x, y)
  gfx.BeginPath();
  gfx.FillColor(255, 255, 255);
  gfx.FontSize(40);
  gfx.Text(text, x, y);
  gfx.Fill();
end


local alpha = 1;

drawSingleSong = function(x, y, w, h, song, isSelected)
  validateSongCache(song);

  if ((not songCache[song.id][1]) or (songCache[song.id][1] == jacketFallback)) then
    songCache[song.id][1] = gfx.LoadImageJob(song.difficulties[1].jacketPath, jacketFallback, 0, 0);
  end

  if (songCache[song.id][1]) then
    alpha = isSelected and 0 or 200;
    gfx.BeginPath();
    gfx.ImageRect(x, y, w, h, songCache[song.id][1], 1, 0);
    gfx.FillColor(0, 0, 0, alpha);
    gfx.Rect(x, y, w, h);
    gfx.Fill();
    gfx.FontSize(20);
    gfx.FillColor(255, 255, 255, 255);
    gfx.Text('x: ' .. x .. '  y: '.. y, x, y);
  end
end

drawLayout = function()
  gfx.BeginPath();
  gfx.FillColor(55, 0, 0);
  gfx.Rect(0, 0, scaledW, scaledH);
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(0, 55, 0);
  gfx.Rect(
    scaledW - ((scaledW / 5) * 3),
    0,
    (scaledW / 5) * 3,
    scaledH
  );
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(255, 255, 255, 100);
  gfx.Rect(
    padding,
    padding * 1.5,
    scaledW - ((scaledW / 5) * 3) - (padding * 1.5),
    scaledH - (padding * 3.5)
  );
  gfx.Fill();

  gfx.BeginPath();
  gfx.FillColor(0, 0, 0, 100);
  gfx.Rect(
    0,
    0,
    padding,
    scaledH
  );
  gfx.Rect(
    scaledW - padding,
    0,
    padding,
    scaledH
  );
  gfx.Rect(
    0,
    0,
    scaledW,
    padding * 1.5
  );
  gfx.Rect(
    0,
    scaledH - (padding * 2),
    scaledW,
    padding * 2
  );
  gfx.Rect(
    scaledW - ((scaledW / 5) * 3) - (padding / 2),
    0,
    padding,
    scaledW
  );
  gfx.Fill();
end

set_index = function(newIndex)
    if (newIndex ~= selectedIndex) then
      game.PlaySample('menu_click');
    end

    selectedIndex = newIndex;
end

set_diff = function(newDiff)
    if newDiff ~= selectedDiff then
        game.PlaySample('click-02')
    end
    doffset = doffset + selectedDiff - newDiff
    selectedDiff = newDiff
end

-- force calculation
--------------------
totalForce = nil

local badgeRates = {
	0.5,  -- Played
	1.0,  -- Cleared
	1.02, -- Hard clear
	1.04, -- UC
	1.1   -- PUC
}

local gradeRates = {
	{['min'] = 9900000, ['rate'] = 1.05}, -- S
	{['min'] = 9800000, ['rate'] = 1.02}, -- AAA+
	{['min'] = 9700000, ['rate'] = 1},    -- AAA
	{['min'] = 9500000, ['rate'] = 0.97}, -- AA+
	{['min'] = 9300000, ['rate'] = 0.94}, -- AA
	{['min'] = 9000000, ['rate'] = 0.91}, -- A+
	{['min'] = 8700000, ['rate'] = 0.88}, -- A
	{['min'] = 7500000, ['rate'] = 0.85}, -- B
	{['min'] = 6500000, ['rate'] = 0.82}, -- C
	{['min'] =       0, ['rate'] = 0.8}   -- D
}

calculate_force = function(diff)
	if #diff.scores < 1 then
		return 0
	end
	local score = diff.scores[1]
	local badgeRate = badgeRates[diff.topBadge]
	local gradeRate
    for i, v in ipairs(gradeRates) do
      if score.score >= v.min then
        gradeRate = v.rate
		break
      end
    end
	return math.floor((diff.level * 2) * (score.score / 10000000) * gradeRate * badgeRate) / 100
end

songs_changed = function(withAll)
	if not withAll then return end

	local diffs = {}
	for i = 1, #songwheel.allSongs do
		local song = songwheel.allSongs[i]
		for j = 1, #song.difficulties do
			local diff = song.difficulties[j]
			diff.force = calculate_force(diff)
			table.insert(diffs, diff)
		end
	end
	table.sort(diffs, function (l, r)
		return l.force > r.force
	end)
	totalForce = 0
	for i = 1, 50 do
		if diffs[i] then
			totalForce = totalForce + diffs[i].force
		end
	end
end
