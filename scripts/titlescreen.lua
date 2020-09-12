local controller = require('titlescreen/controller');
local controls = require('titlescreen/controls');
local cursor = require('titlescreen/cursor');
local easing = require('lib/easing');

controls:initializeAll();

local activeButton = 1;
local previousButton = 1;
local allowClick = false;
local buttons = nil;
local buttonW = 0;
local buttonH = 0;
local hoveredButton = nil;
local maxButtons = 6;

local cursorAlpha = 0;
local cursorPos = {};
local cursorTimer = 0;
local cursorX = nil;

local flickerTimer = 0;

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

local mousePosX = 0;
local mousePosY = 0;

local fadeTimer = 0;
local showUpdatePrompt = false;
local updateChecked = false;

local updateCursorAlpha = 0;
local updateCursorPos = {};
local updateCursorTimer = 0;
local updateCursorX = nil;

local titleAlpha = 0;
local titleTimer = 0;

local introTimer = 1;
local menuLoaded = false;

local hoveredPage = nil;
local showControls = false;

local background = cacheImage('main_menu/menu_bg.png');
local dialogBox = cacheImage('main_menu/dialog.png');

local title = nil;

setupLayout = function()
  resX, resY = game.GetResolution();
  scaledW = 1920;
  scaledH = scaledW * (resY / resX);
	scalingFactor = resX / scaledW;
	
	gfx.Scale(scalingFactor, scalingFactor);
end

setupButtons = function()
	if (not buttons) then
		gfx.LoadSkinFont('GothamMedium.ttf');

		buttons = {
			['main'] = {
				[1] = {
					['action'] = Menu.Start,
					['label'] = cacheLabel('SINGLEPLAYER', 18)
				},
				[2] = {
					['action'] = Menu.Multiplayer,
					['label'] = cacheLabel('MULTIPLAYER', 18)
				},
				[3] = {
					['action'] = Menu.DLScreen,
					['label'] = cacheLabel('NAUTICA', 18)
				},
				[4] = {
					['action'] = displayControls,
					['label'] = cacheLabel('CONTROLS', 18)
				},
				[5] = {
					['action'] = Menu.Settings,
					['label'] = cacheLabel('SETTINGS', 18)
				},
				[6] = {
					['action'] = Menu.Exit,
					['label'] = cacheLabel('EXIT', 18)
				},
			},
			['update'] = {
				[1] = {
					['action'] = Menu.Update,
					['label'] = cacheLabel('UPDATE', 16)
				},
				[2] = {
					['action'] = viewUpdate,
					['label'] = cacheLabel('VIEW', 16)
				},
				[3] = {
					['action'] = closeUpdatePrompt,
					['label'] = cacheLabel('CLOSE', 16)
				}
			},
			['img'] = cacheImage('main_menu/button.png'),
			['imgHover'] = cacheImage('main_menu/button_hover.png'),
			['spacing'] = 20
		};

		gfx.LoadSkinFont('GothamBook.ttf');
		buttons['update']['heading'] = cacheLabel('A NEW UPDATE IS AVAILABLE!', 36);
	end
end

loadMenu = function(deltaTime)
	if (not updateChecked) then
		updateUrl, updateVersion = game.UpdateAvailable();

		if (updateUrl) then
			showUpdatePrompt = true;
			updateChecked = true;
		end
	end

	if (not title) then
		title = {};

		gfx.LoadSkinFont('GothamBook.ttf');
		title['UNNAMED'] = cacheLabel('UNNAMED', 64);
		title['CLONE'] = cacheLabel('CLONE', 64);

		gfx.LoadSkinFont('GothamBold.ttf');
		title['SOUNDVOLTEX'] = cacheLabel('SOUND VOLTEX', 110);
	end

	introTimer = math.max(introTimer - (deltaTime / 3), 0);

	local alpha = math.floor(255 * introTimer);

	gfx.BeginPath();
	gfx.FillColor(0, 0, 0, alpha);
	gfx.Rect(0, 0, scaledW, scaledH);
	gfx.Fill();

	if (introTimer == 0) then
		menuLoaded = true;
	end
end

drawTitle = function(deltaTime)
	titleTimer = math.min(titleTimer + (deltaTime * 4), 1);
	titleAlpha = math.floor(titleTimer * 255);

	local alpha = (showControls and 30) or titleAlpha;
	local x = scaledW / 20;

	gfx.BeginPath();
	gfx.FillColor(255, 255, 255, alpha);
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
	title['UNNAMED']:draw({
		['x'] = x,
		['y'] = 238
	});
	title['SOUNDVOLTEX']:draw({
		['x'] = x,
		['y'] = 279
	});
	title['CLONE']:draw({
		['x'] = x + 689,
		['y'] = 380
	});
end

mouseClipped = function(x, y, w, h)
	local scaledX = x * scalingFactor;
	local scaledY = y * scalingFactor;
	local scaledW = scaledX + (w * scalingFactor);
	local scaledH = scaledY + (h * scalingFactor);

	return (mousePosX > scaledX)
		and (mousePosY > scaledY)
		and (mousePosX < scaledW)
		and (mousePosY < scaledH);
end

setCursorX = function()
	if (not cursorX) then
		cursorX = scaledH - (scaledH / 5);
		updateCursorX = (scaledW / 2) - (((buttons['img']['w'] * 0.8) * 3) / 2) + 13;
	end
end 

drawButton = function(x, initialY, i)
	local isNavigable = menuLoaded and (not showControls);
	local allowAction = isNavigable and (not showUpdatePrompt);
	local button = buttons['main'][i];
	local isActive = button['action'] == (isNavigable and buttons['main'][activeButton]['action']);
	local textAlpha = math.floor(255 * ((allowAction and isActive and 1) or 0.2));
	local w = buttons['img']['w'];
	local h = buttons['img']['h'];
	local y = initialY - (h / 2);

	buttons['img']:draw({
		['x'] = x,
		['y'] = y,
		['a'] = 0.45
	});

	if (allowAction and (mouseClipped(x, y, w, h) or isActive)) then
		activeButton = i;
		allowClick = mouseClipped(x, y, w, h);
		hoveredButton = button['action'];

		buttons['imgHover']:draw({
			['x'] = x,
			['y'] = y
		});
	end

	gfx.FillColor(255, 255, 255, textAlpha);
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
	button['label']:draw({
		['x'] = x + 35,
		['y'] = initialY - 3
	});

	return (w + buttons['spacing']);
end

drawCursor = function(deltaTime, x, y)
	cursorTimer = cursorTimer + deltaTime;
	flickerTimer = flickerTimer + deltaTime;

	cursorAlpha = math.floor(flickerTimer * 30) % 2;

	if (flickerTimer >= 0.3) then
		cursorAlpha = math.abs(0.8 * math.cos(cursorTimer * 5)) + 0.2;
	end

	cursorX = cursorX - (cursorX - x) * deltaTime * 50;

	gfx.Save();

	gfx.BeginPath();

	cursor:drawCursor(cursorX, y, 258, 50, 4, cursorAlpha);

	gfx.Restore();
end

drawUpdateButton = function(x, initialY, i)
	local button = buttons['update'][i];
	local isActive = button['action'] == buttons['update'][activeButton]['action'];
	local textAlpha = math.floor(255 * ((isActive and 1) or 0.2));
	local w = buttons['img']['w'] * 0.8;
	local h = buttons['img']['h'] * 0.8;
	local y = initialY - (h / 2);

	buttons['img']:draw({
		['x'] = x,
		['y'] = y,
		['s'] = 0.8,
		['a'] = 0.45
	});

	if (mouseClipped(x, y, w, h) or isActive) then
		activeButton = i;
		allowClick = mouseClipped(x, y, w, h);
		hoveredButton = button['action'];

		buttons['imgHover']:draw({
			['x'] = x,
			['y'] = y,
			['s'] = 0.8
		});
	end

	gfx.FillColor(255, 255, 255, textAlpha);
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
	button['label']:draw({
		['x'] = x + 29,
		['y'] = initialY - 3
	});

	return (w + buttons['spacing']);
end

drawUpdateCursor = function(deltaTime, x, y)
	updateCursorTimer = updateCursorTimer + deltaTime;
	flickerTimer = flickerTimer + deltaTime;

	updateCursorAlpha = math.floor(flickerTimer * 30) % 2;

	if (flickerTimer >= 0.3) then
		updateCursorAlpha = math.abs(0.8 * math.cos(updateCursorTimer * 5)) + 0.2;
	end

	updateCursorX = updateCursorX - (updateCursorX - x) * deltaTime * 50;

	gfx.Save();

	gfx.BeginPath();

	cursor:drawCursor(updateCursorX, y, (258 * 0.8), (50 * 0.8), 3, updateCursorAlpha);

	gfx.Restore();
end

drawUpdatePrompt = function(deltaTime)
	fadeTimer = math.min(fadeTimer + (deltaTime * 3), 1);

	gfx.BeginPath();
	gfx.FillColor(0, 0, 0, math.floor(150 * fadeTimer));
	gfx.Rect(0, 0, scaledW, scaledH);
	gfx.Fill();

	dialogBox:draw({
		['x'] = scaledW / 2,
		['y'] = scaledH / 2,
		['a'] = fadeTimer,
		['centered'] = true
	});

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
	gfx.FillColor(255, 255, 255, math.floor(255 * fadeTimer));
	buttons['update']['heading']:draw({
		['x'] = scaledW / 2 - 86,
		['y'] = (scaledH / 2) - 144
	});

	local updateButtonX = (scaledW / 2) - (((buttons['img']['w'] * 0.8) * 3) / 2) + 13;
	local updateButtonY = scaledH / 2 + 133;

	for i = 1, 3 do
		updateCursorPos[i] = updateButtonX;
		updateButtonX = updateButtonX + drawUpdateButton(updateButtonX, updateButtonY, i);
	end

	drawUpdateCursor(deltaTime, updateCursorPos[activeButton], updateButtonY);
end

closeUpdatePrompt = function()
	activeButton = 1;
	showUpdatePrompt = false;
end

displayControls = function()
	activeButton = 1;
	showControls = true;
end

viewUpdate = function()
	if (package.config:sub(1,1) == '\\') then
		updateUrl, updateVersion = game.UpdateAvailable();
		os.execute('start ' .. updateUrl);
	else
		os.execute('xdg-open ' .. updateUrl);
	end
end

mouse_pressed = function(button)
	if (showControls and (not hoveredPage)) then
		activeButton = 1;
		showControls = false;
	end

	if (hoveredPage) then
		activeButton = hoveredPage;
	end

	if (hoveredButton and allowClick) then
		hoveredButton();
	end

	return 0;
end

button_pressed = function(button)
	local whichButtons = (showUpdatePrompt and 'update') or 'main';

	if (button == game.BUTTON_STA) then
		if (showControls) then
			activeButton = 1;
			showControls = false;
		else
			buttons[whichButtons][activeButton]['action']();
		end
	elseif (button == game.BUTTON_BCK) then
		if (showControls) then
			activeButton = 1;
			showControls = false;
		else
			Menu.Exit();
		end
	end
end

render = function(deltaTime)
	setupButtons();
	setupLayout();
	setCursorX();

	if (not renderX) then
		renderX = scaledH - (scaledH / 5);
	end

	mousePosX, mousePosY = game.GetMousePos();

	background:draw({
		['x'] = 0,
		['y'] = 0,
		['w'] = scaledW,
		['h'] = scaledH
	});

	if (not menuLoaded) then
		loadMenu(deltaTime);
	end

	buttonX = scaledW / 20;
	buttonY = scaledH - (scaledH / 5);
	hoveredButton = nil;

	for i = 1, maxButtons do
		cursorPos[i] = buttonX;
		buttonX = buttonX + drawButton(buttonX, buttonY, i);
	end

	activeButton = controller:handleInput(
		activeButton,
		showControls,
		showUpdatePrompt
	);

	if (menuLoaded) then
		if (showUpdatePrompt) then
			drawUpdatePrompt(deltaTime);
		else
			drawTitle(deltaTime);

			if (not showControls) then
				drawCursor(deltaTime, cursorPos[activeButton], buttonY);
			end
		end
	end

	if (previousButton ~= activeButton) then
		-- PLAY SAMPLE HERE
		flickerTimer = 0;

		previousButton = activeButton;
	end

	hoveredPage = controls:render(deltaTime, showControls, activeButton);
end