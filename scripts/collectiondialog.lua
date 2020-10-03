local layout = require('layout/dialog');

menuOptions = {};
selectedIndex = 0;

local buttonScrollTimer = 0;

local cursor = {
	alpha = 0,
	offset = 0,
	timer = 0,
};

local artist = nil;
local title = nil;

local timer = 0;
local timers = {
	artist = 0,
	button = 0,
	cursor = 0,
	title = 0,
};

local cache = { resX = 0, resY = 0 };

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

setupLayout = function()
  resX, resY = game.GetResolution();

  if ((cache.resX ~= resX) or (cache.resY ~= resY)) then
    scaledW = 1920;
    scaledH = scaledW * (resY / resX);
    scalingFactor = resX / scaledW;

    cache.resX = resX;
    cache.resY = resY;
  end

  gfx.Scale(scalingFactor, scalingFactor);
end

local labels = nil;

setLabels = function()
	if (not labels) then
		font.medium();

		labels = {
			artist = cacheLabel('ARTIST', 18),
			collectionName = cacheLabel('COLLECTION NAME', 18),
			confirm = cacheLabel('CONFIRM', 18),
			enter = cacheLabel('[ENTER]', 18),
			title = cacheLabel('TITLE', 18),
		};

		font.jp();

		labels.input = cacheLabel('', 28);
	end
end

drawArrows = function()
	local noHigher = selectedIndex == 0;
	local noLower = (selectedIndex + 1) == #menuOptions;
	local x = layout.x.center - 36;
	local y1 = layout.y.center + 29;
	local y2 = layout.y.center + 45;

	gfx.BeginPath();
	fill.white(timer * ((noHigher and 50) or 255));
	gfx.MoveTo(x, y1);
	gfx.LineTo(x - 12, y1);
	gfx.LineTo(x - 6, y1 - 10);
	gfx.LineTo(x, y1);
	gfx.Fill();

	gfx.BeginPath();
	fill.white(timer * ((noLower and 50) or 255));
	gfx.MoveTo(x, y2);
	gfx.LineTo(x - 12, y2);
	gfx.LineTo(x - 6, y2 + 10);
	gfx.LineTo(x , y2);
	gfx.Fill();
end

drawButton = function(deltaTime, label, isSelected, y)
	if ((y < layout.y.center) or (y > layout.y.bottom)) then return end;

	local alpha = math.floor(((isSelected and 255) or 50) * timer);
	local w = layout.images.button.w;

	if (isSelected) then
		layout.images.buttonHover:draw({
			x = layout.x.outerRight - w + 12,
			y = y,
			a = timer
		});
	else
		layout.images.button:draw({
			x = layout.x.outerRight - w + 12,
			y = y,
			a = (0.45 * timer)
		});
	end

	gfx.Save();

	gfx.Scale(1 / scalingFactor, 1 / scalingFactor);
	
	gfx.BeginPath();
	align.left();

	if (label.w > (w - 90)) then
		buttonScrollTimer = buttonScrollTimer + deltaTime;

		drawScrollingLabel(
			buttonScrollTimer,
			label,
			(w - 90),
			layout.x.outerRight - w + 55,
			y + label.h + 8,
			scalingFactor,
			'white',
			alpha
		);
	else
		label:draw({
			x = layout.x.outerRight - w + 55,
			y = y + label.h + 8,
			a = alpha,
			color = 'white',
		});
	end

	gfx.Restore();
end

drawInput = function()
	local x = layout.x.middleLeft;
	local y = layout.y.center + (layout.h.outer / 10);
	local labelY = layout.y.center + (layout.h.outer / 10);

	y = y + (labels.collectionName.h * 2);

	cursor.offset = math.min(labels.input.w + 2, layout.w.middle - 20);

	gfx.BeginPath();
	gfx.StrokeWidth(1);
	gfx.StrokeColor(60, 110, 160, math.floor(255 * timer));
	fill.dark(255 * timer);
	gfx.Rect(x, y, layout.w.middle, layout.h.outer / 6);
	gfx.Fill();
	gfx.Stroke();

	gfx.BeginPath();
	fill.white(255 * cursor.alpha);
	gfx.Rect(x + 8 + cursor.offset, y + 10, 2, (layout.h.outer / 6) - 20);
	gfx.Fill();

	gfx.Save();

	gfx.Scale(1 / scalingFactor, 1 / scalingFactor);

	font.jp();
	labels.input:update({ new = string.upper(dialog.newName) });

	gfx.BeginPath();
	align.left();

	labels.collectionName:draw({
		x = layout.x.middleLeft,
		y = labelY,
		a = 255 * timer,
		color = 'normal',
	});

	labelY = labelY + (labels.collectionName.h * 2);

	labels.input:draw({
		x = x + 8,
		y = labelY + 7,
		a = 255 * timer,
		color = 'white',
		maxWidth = layout.w.middle - 22,
	});

	labelY = labelY + (layout.h.outer / 6);

	gfx.BeginPath();
	align.right();

	labels.confirm:draw({
		x = layout.x.middleRight + 2,
		y = labelY + labels.confirm.h,
		a = 255 * timer,
		color = 'white',
	});

	labels.enter:draw({
		x = layout.x.middleRight - labels.enter.w - 16,
		y = labelY + labels.enter.h,
		a = 255 * timer,
		color = 'normal',
	});

	gfx.Restore();
end

drawSongInfo = function(deltaTime)
	local alpha = math.floor(255 * timer);
	local maxWidth = layout.w.outer - (176 / 2);
	local x = layout.x.outerLeft;
	local y = layout.y.top - 12;

	gfx.Save();

	gfx.Scale(1 / scalingFactor, 1 / scalingFactor);

	gfx.BeginPath();
	align.left();

	labels.title:draw({
		x = x,
		y = y,
		a = alpha,
		color = 'normal',
	});

	y = y + (labels.title.h * 1.25);

	if (title.w > maxWidth) then
		timers.title = timers.title + deltaTime;

		drawScrollingLabel(
			timers.title,
			title,
			maxWidth,
			x + 2,
			y,
			scalingFactor,
			'white',
			alpha
		);
	else
		title:draw({
			x = x,
			y = y,
			a = alpha,
			color = 'white',
		});
	end

	y = y + (title.h * 1.5);

	labels.artist:draw({
		x = x,
		y = y,
		a = alpha,
		color = 'normal',
	});

	y = y + (labels.artist.h * 1.5);
	
	if (artist.w > maxWidth) then
		timers.artist = timers.artist + deltaTime;

		drawScrollingLabel(
			timers.artist,
			artist,
			maxWidth,
			x + 2,
			y,
			scalingFactor,
			'white',
			alpha
		);
	else
		artist:draw({
			x = x,
			y = y,
			a = alpha,
			color = 'white',
		});
	end

	gfx.Restore();
end

open = function()
	initialIndex = 1;
	menuOptions = {};
	selectedIndex = 0;

	font.medium();

	if (#dialog.collections == 0) then
		menuOptions[initialIndex] = {
			action = createCollection('FAVOURITES'),
			label = cacheLabel('ADD TO FAVOURITES', 18),
		};
	end

	for i, collection in ipairs(dialog.collections) do
		local currentName =
			(collection.exists and string.format('REMOVE FROM %s', string.upper(collection.name)))
			or string.format('ADD TO %s', string.upper(collection.name));

		menuOptions[i] = {
			action = createCollection(collection.name),
			label = cacheLabel(currentName, 18),
		};
	end

	table.insert(menuOptions, {
		action = menu.ChangeState,
		label = cacheLabel('CREATE COLLECTION', 18),
	});
	table.insert(menuOptions, {
		action = menu.Cancel,
		label = cacheLabel('CLOSE', 18),
	});

	font.jp();

	artist = cacheLabel(string.upper(dialog.artist), 28);
	title = cacheLabel(string.upper(dialog.title), 36);
end

render = function(deltaTime)
	gfx.Save();

	setupLayout();

	layout:setSizes(scaledW, scaledH);

	setLabels();

	if (dialog.closing) then
		timer = math.max(timer - (deltaTime * 6), 0);
	else
		timer = math.min(timer + (deltaTime * 8), 1);
	end

	cursor.timer = cursor.timer + deltaTime;
	cursor.alpha = timer * (math.abs(0.8 * math.cos(cursor.timer * 5)) + 0.2);

	layout.images.dialogBox:draw({
		x = scaledW / 2,
		y = scaledH / 2,
		a = timer,
		centered = true,
	});

	drawSongInfo(deltaTime);

	if (dialog.isTextEntry) then
		drawInput();
	else
		local y = layout.y.center;
		local nextY = layout.images.button.h * 1.25;
		
		for i, option in ipairs(menuOptions) do
			local buttonY = y + nextY * ((i - 1) - selectedIndex);
			local isSelected = (i - 1) == selectedIndex;

			drawButton(deltaTime, option.label, isSelected, buttonY);
		end

		drawCursor({
			x = layout.x.outerRight - layout.images.button.w + 20,
			y = layout.y.center + 10,
			w = layout.images.button.w - 20,
			h = layout.images.button.h - 20,
			alpha = cursor.alpha,
			size = 12,
			stroke = 1.5,
		});

		drawArrows();
	end

	gfx.Restore();

	if ((dialog.closing == true) and (timer <= 0)) then
		return false;
	else
		return true;
	end
end

advance_selection = function(value)
  selectedIndex = (selectedIndex + value) % #menuOptions;
end

button_pressed = function(button)
	if (button == game.BUTTON_BCK) then
		menu.Cancel();
	elseif button == game.BUTTON_STA then
		menuOptions[selectedIndex + 1].action();
	end
end

createCollection = function(name)
	return function()
		menu.Confirm(name);
	end
end