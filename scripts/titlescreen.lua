controller = require('titlescreen/controller');

local activeButton = 1;
local previousButton = 1;
local allowClick = false;
local buttons = nil;
local hoveredButton = nil;
local buttonW = 0;
local buttonH = 0;

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

local introTimer = 1;
local menuLoaded = false;

local background = gfx.CreateSkinImage('main_menu/menu_bg.png', 0);
local dialogBox = gfx.CreateSkinImage('main_menu/dialog.png', 0);

setupLayout = function()
  resX, resY = game.GetResolution();
  scaledW = 1920;
  scaledH = scaledW * (resY / resX);
  scalingFactor = resX / scaledW;
end

setupButtons = function()
	if (not buttons) then
		buttons = {
			['main'] = {},
			['update'] = {}
		};

		buttons['main'][1] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/singleplayer.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/singleplayer_h.png', 0),
			['action'] = Menu.Start
		};
		buttons['main'][2] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/multiplayer.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/multiplayer_h.png', 0),
			['action'] = Menu.Multiplayer
		};
		buttons['main'][3] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/download_charts.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/download_charts_h.png', 0),
			['action'] = Menu.DLScreen
		};
		buttons['main'][4] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/settings.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/settings_h.png', 0),
			['action'] = Menu.Settings
		};
		buttons['main'][5] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/exit.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/exit_h.png', 0),
			['action'] = Menu.Exit
		};

		buttons['update'][1] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/install_update.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/install_update_h.png', 0),
			['action'] = Menu.Update
		};
		buttons['update'][2] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/view_update.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/view_update_h.png', 0),
			['action'] = viewUpdate
		};
		buttons['update'][3] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/close.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/close_h.png', 0),
			['action'] = closeUpdatePrompt
		};

		buttonW, buttonH = gfx.ImageSize(buttons['main'][1]['img']);
	end
end;

loadMenu = function(deltaTime)
	if (not updateChecked) then
		updateUrl, updateVersion = game.UpdateAvailable();

		if (updateUrl) then
			showUpdatePrompt = true;
			updateChecked = true;
		end
	end

	introTimer = math.max(introTimer - (deltaTime / 4), 0);

	local alpha = math.floor(255 * introTimer);

	gfx.BeginPath();
	gfx.FillColor(0, 0, 0, alpha);
	gfx.Rect(0, 0, scaledW, scaledH);
	gfx.Fill();

	if (introTimer == 0) then
		menuLoaded = true;
	end
end

drawTitle = function()
	local x = math.floor(scaledW / 18);
	local alpha = (showUpdatePrompt and 100) or math.floor(255 * (1 - introTimer));

	gfx.BeginPath();
	gfx.FillColor(255, 255, 255, alpha);
	gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);

	gfx.LoadSkinFont('GothamBook.ttf');
	gfx.FontSize(64);
	gfx.Text('UNNAMED', x, 238);
	gfx.Text('CLONE', x + 774, 402);

	gfx.LoadSkinFont('GothamBold.ttf');
	gfx.FontSize(110);
	gfx.Text('SOUND VOLTEX', x, 300);
end

mouseClipped = function(x, y, w, h)
	local scaledX = x * scalingFactor;
	local scaledY = y * scalingFactor;
	local scaledW = scaledX + (w * scalingFactor);
	local scaledH = scaledY + (h * scalingFactor);

	return (mousePosX > scaledX) and
		(mousePosY > scaledY) and
		(mousePosX < scaledW) and
		(mousePosY < scaledH);
end

drawButton = function(x, y, currentButton)
	local button = buttons['main'][currentButton];
	local isActive = button['action'] == buttons['main'][activeButton]['action'];
	local allowAction = menuLoaded and (not showUpdatePrompt);
	local w = buttonW;
	local h = buttonH;

	gfx.BeginPath();
	gfx.ImageRect(x, y, w, h, button['img'], 0.35, 0);

	if (allowAction and (mouseClipped(x, y, w, h) or isActive)) then
		activeButton = currentButton;
		allowClick = mouseClipped(x, y, w, h);
		hoveredButton = button['action'];
		gfx.ImageRect(x, y, w, h, button['imgHover'], 1, 0);
	end

	return w;
end

drawUpdateButton = function(x, y, currentButton)
	local button = buttons['update'][currentButton];
	local isActive = button['action'] == buttons['update'][activeButton]['action'];
	local w = buttonW * 0.7;
	local h = buttonH * 0.7;

	gfx.BeginPath();
	gfx.ImageRect(x, y, w, h, button['img'], 1, 0);

	if (mouseClipped(x, y, w, h) or isActive) then
		activeButton = currentButton;
		allowClick = mouseClipped(x, y, w, h);
		hoveredButton = button['action'];
		gfx.ImageRect(x, y, w, h, button['imgHover'], 1, 0);
	end

	return w;
end

drawUpdatePrompt = function(deltaTime)
	local w, h = gfx.ImageSize(dialogBox);
	local x = (scaledW / 2) - (w / 2);
	local y = (scaledH / 2) - (h / 2);

	fadeTimer = math.min(fadeTimer + (deltaTime * 3), 1);

	gfx.BeginPath();
	gfx.FillColor(0, 0, 0, math.floor(100 * fadeTimer));
	gfx.Rect(0, 0, scaledW, scaledH);
	gfx.Fill();

	gfx.BeginPath();
	gfx.ImageRect(x, y, w, h, dialogBox, fadeTimer, 0);

	gfx.BeginPath();
	gfx.LoadSkinFont('GothamBook.ttf');
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
	gfx.FontSize(36);
	gfx.FillColor(255, 255, 255, math.floor(255 * fadeTimer));
	gfx.Text('A NEW UPDATE IS AVAILABLE!', scaledW / 2 - 48, (scaledH / 2) - 132);

	local updateButtonX = (scaledW / 2) - (((buttonWidth * 0.7) * 3) / 2) + 26;
	local updateButtonY = scaledH / 2 + 90;

	for currentButton = 1, 3 do
		updateButtonX = updateButtonX + drawUpdateButton(updateButtonX, updateButtonY, currentButton);
	end
end

closeUpdatePrompt = function()
	showUpdatePrompt = false;
	activeButton = 1;
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
	if (hoveredButton and allowClick) then
		hoveredButton();
	end

	return 0;
end

button_pressed = function(button)
	local whichButtons = (showUpdatePrompt and 'update') or 'main';

	if (button == game.BUTTON_STA) then 
		buttons[whichButtons][activeButton]['action']();
	elseif (button == game.BUTTON_BCK) then
		Menu.Exit();
	end
end

render = function(deltaTime)
	setupLayout();
	setupButtons();

	gfx.Scale(scalingFactor, scalingFactor);

	mousePosX, mousePosY = game.GetMousePos();

	gfx.BeginPath();
	gfx.ImageRect(0, 0, scaledW, scaledH, background, 1, 0);

	drawTitle();

	buttonX = math.floor(scaledW / 22.6);
	buttonY = math.floor(scaledH / 1.375);
	hoveredButton = nil;

	for currentButton = 1, 5 do
		buttonX = buttonX + drawButton(buttonX, buttonY, currentButton);
	end
	
	activeButton = controller:handleInput(activeButton, showUpdatePrompt);

	if (not menuLoaded) then
		loadMenu(deltaTime);
	end

	if (menuLoaded and showUpdatePrompt) then
		drawUpdatePrompt(deltaTime);
	end

	if (previousButton ~= activeButton) then
		-- PLAY SAMPLE HERE
		previousButton = activeButton;
	end
end