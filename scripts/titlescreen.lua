controller = require('titlescreen/controller');
controls = require('titlescreen/controls');
cursor = require('titlescreen/cursor');

if (not controls['initialized']) then
  controls:initializeAll();
end

local activeButton = 1;
local previousButton = 1;
local allowClick = false;
local buttons = nil;
local buttonW = 0;
local buttonH = 0;
local hoveredButton = nil;
local maxButtons = 6;

local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

local mousePosX = 0;
local mousePosY = 0;

local buttonWidth = 350;
local fadeTimer = 0;
local showUpdatePrompt = false;
local updateChecked = false;

local titleAlpha = 0;
local titleTimer = 0;

local introTimer = 1;
local menuLoaded = false;

local hoveredPage = nil;
local showControls = false;

local background = gfx.CreateSkinImage('main_menu/menu_bg.png', 0);
local dialogBox = gfx.CreateSkinImage('main_menu/dialog.png', 0);

local title = nil;

setupLayout = function()
  resX, resY = game.GetResolution();
  scaledW = 1920;
  scaledH = scaledW * (resY / resX);
  scalingFactor = resX / scaledW;
end

setupButtons = function()
	if (not buttons) then
		gfx.LoadSkinFont('GothamMedium.ttf');

		buttons = {
			['main'] = {
				[1] = {
					['action'] = Menu.Start,
					['label'] = gfx.CreateLabel('SINGLEPLAYER', 18, 0)
				},
				[2] = {
					['action'] = Menu.Multiplayer,
					['label'] = gfx.CreateLabel('MULTIPLAYER', 18, 0)
				},
				[3] = {
					['action'] = Menu.DLScreen,
					['label'] = gfx.CreateLabel('NAUTICA', 18, 0)
				},
				[4] = {
					['action'] = displayControls,
					['label'] = gfx.CreateLabel('CONTROLS', 18, 0)
				},
				[5] = {
					['action'] = Menu.Settings,
					['label'] = gfx.CreateLabel('SETTINGS', 18, 0)
				},
				[6] = {
					['action'] = Menu.Exit,
					['label'] = gfx.CreateLabel('EXIT', 18, 0)
				},
			},
			['update'] = {
				[1] = {
					['action'] = Menu.Update,
					['label'] = gfx.CreateLabel('UPDATE', 16, 0)
				},
				[2] = {
					['action'] = viewUpdate,
					['label'] = gfx.CreateLabel('VIEW', 16, 0)
				},
				[3] = {
					['action'] = closeUpdatePrompt,
					['label'] = gfx.CreateLabel('CLOSE', 16, 0)
				}
			},
			['img'] = gfx.CreateSkinImage('main_menu/button.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/button_hover.png', 0),
			['spacing'] = 20
		};

		buttons['width'], buttons['height'] = gfx.ImageSize(buttons['img']);

		gfx.LoadSkinFont('GothamBook.ttf');
		buttons['update']['heading'] = gfx.CreateLabel('A NEW UPDATE IS AVAILABLE!', 36, 0);
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
		title['UNNAMED'] = gfx.CreateLabel('UNNAMED', 64, 0);
		title['CLONE'] = gfx.CreateLabel('CLONE', 64, 0);

		gfx.LoadSkinFont('GothamBold.ttf');
		title['SOUNDVOLTEX'] = gfx.CreateLabel('SOUND VOLTEX', 110, 0);
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
	local x = scaledW / 18;

	titleTimer = math.min(titleTimer + (deltaTime * 4), 1);
	titleAlpha = math.floor(titleTimer * 255);

	local alpha = (showControls and 30) or titleAlpha;

	gfx.BeginPath();
	gfx.FillColor(255, 255, 255, alpha);
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
	gfx.DrawLabel(title['UNNAMED'], x, 238, -1);
	gfx.DrawLabel(title['SOUNDVOLTEX'], x, 279, -1);
	gfx.DrawLabel(title['CLONE'], x + 689, 380, -1);
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

drawButton = function(x, initialY, i)
	local isNavigable = menuLoaded and (not showControls);
	local allowAction = isNavigable and (not showUpdatePrompt);
	local button = buttons['main'][i];
	local isActive = button['action'] == (isNavigable and buttons['main'][activeButton]['action']);
	local textAlpha = math.floor(255 * ((allowAction and isActive and 1) or 0.2));
	local w = buttons['width'];
	local h = buttons['height'];
	local y = initialY - (h / 2);

	gfx.BeginPath();
	gfx.ImageRect(x, y, w, h, buttons['img'], 0.35, 0);

	if (allowAction and (mouseClipped(x, y, w, h) or isActive)) then
		activeButton = i;
		allowClick = mouseClipped(x, y, w, h);
		hoveredButton = button['action'];
		gfx.ImageRect(x, y, w, h, buttons['imgHover'], 1, 0);

		cursor:drawCursor(x, initialY, 258, 50, 4);
	end

	gfx.FillColor(255, 255, 255, textAlpha);
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
	gfx.DrawLabel(button['label'], x + 35, initialY - 3, -1);

	return (w + buttons['spacing']);
end

drawUpdateButton = function(x, initialY, i)
	local button = buttons['update'][i];
	local isActive = button['action'] == buttons['update'][activeButton]['action'];
	local textAlpha = math.floor(255 * ((isActive and 1) or 0.2));
	local w = buttons['width'] * 0.8;
	local h = buttons['height'] * 0.8;
	local y = initialY - (h / 2);

	gfx.BeginPath();
	gfx.ImageRect(x, y, w, h, buttons['img'], 0.7, 0);

	if (mouseClipped(x, y, w, h) or isActive) then
		activeButton = i;
		allowClick = mouseClipped(x, y, w, h);
		hoveredButton = button['action'];
		gfx.ImageRect(x, y, w, h, buttons['imgHover'], 1, 0);

		cursor:drawCursor(x, initialY, (258 * 0.8), (50 * 0.8), 3);
	end

	gfx.FillColor(255, 255, 255, textAlpha);
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_MIDDLE);
	gfx.DrawLabel(button['label'], x + 29, initialY - 3, -1);

	return (w + buttons['spacing']);
end

drawUpdatePrompt = function(deltaTime)
	local w, h = gfx.ImageSize(dialogBox);
	local x = (scaledW / 2) - (w / 2);
	local y = (scaledH / 2) - (h / 2);

	fadeTimer = math.min(fadeTimer + (deltaTime * 3), 1);

	gfx.BeginPath();
	gfx.FillColor(0, 0, 0, math.floor(170 * fadeTimer));
	gfx.Rect(0, 0, scaledW, scaledH);
	gfx.Fill();

	gfx.BeginPath();
	gfx.ImageRect(x, y, w, h, dialogBox, fadeTimer, 0);

	gfx.BeginPath();
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
	gfx.FillColor(255, 255, 255, math.floor(255 * fadeTimer));
	gfx.DrawLabel(buttons['update']['heading'], scaledW / 2 - 86, (scaledH / 2) - 144);

	local updateButtonX = (scaledW / 2) - (((buttons['width'] * 0.8) * 3) / 2) + 13;
	local updateButtonY = scaledH / 2 + 133;

	for i = 1, 3 do
		updateButtonX = updateButtonX + drawUpdateButton(updateButtonX, updateButtonY, i);
	end
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

	gfx.Scale(scalingFactor, scalingFactor);

	mousePosX, mousePosY = game.GetMousePos();

	gfx.BeginPath();
	gfx.ImageRect(0, 0, scaledW, scaledH, background, 1, 0);

	if (not menuLoaded) then
		loadMenu(deltaTime);
	end

	buttonX = scaledW / 20;
	buttonY = scaledH - (scaledH / 5);
	hoveredButton = nil;

	for i = 1, maxButtons do
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
		end
	end

	if (previousButton ~= activeButton) then
		-- PLAY SAMPLE HERE
		previousButton = activeButton;
	end

	hoveredPage = controls:render(deltaTime, showControls, activeButton);
end