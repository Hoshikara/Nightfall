controller = require('titlescreen/controller');

local activeButton = 1;
local allowClick = false;
local buttons = nil;
local hoveredButton = nil;

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
local updateUrl, updateVersion = game.UpdateAvailable();

local introTimer = 1;
local menuLoaded = false;

local background = gfx.CreateSkinImage('main_menu/menu_bg.png', 0);

setupLayout = function()
  resX, resY = game.GetResolution();
  scaledW = 1920;
  scaledH = scaledW * (resY / resX);
  scalingFactor = resX / scaledW;
end

setupButtons = function()
	if (buttons == nil) then
		buttons = {};

		buttons[1] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/singleplayer.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/singleplayer_h.png', 0),
			['action'] = Menu.Start
		};
		buttons[2] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/multiplayer.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/multiplayer_h.png', 0),
			['action'] = Menu.Multiplayer
		};
		buttons[3] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/download_charts.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/download_charts_h.png', 0),
			['action'] = Menu.DLScreen
		};
		buttons[4] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/settings.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/settings_h.png', 0),
			['action'] = Menu.Settings
		};
		buttons[5] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/exit.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/exit_h.png', 0),
			['action'] = Menu.Exit
		};
		buttons[6] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/install_update.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/install_update_h.png', 0),
			['action'] = Menu.Update
		};
		buttons[7] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/view_update.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/view_update_h.png', 0),
			['action'] = viewUpdate
		};
		buttons[8] = {
			['img'] =  gfx.CreateSkinImage('main_menu/buttons/close.png', 0),
			['imgHover'] = gfx.CreateSkinImage('main_menu/buttons_hover/close_h.png', 0),
			['action'] = closeUpdatePrompt
		};
	end
end;

loadMenu = function(deltaTime)
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
	return mousePosX > x and
		mousePosY > y and
		mousePosX < (x + w) and
		mousePosY < (y + h);
end

drawButton = function(x, y, currentButton)
	local isActive = buttons[currentButton]['action'] == buttons[activeButton]['action'];
	local isUpdateButton = (currentButton >= 6) and (currentButton <= 8);
	local w, h = gfx.ImageSize(buttons[currentButton]['img']);
	local alpha = (showUpdatePrompt and 1) or 0.35;

	gfx.BeginPath();
	gfx.ImageRect(x, y, w, h, buttons[currentButton]['img'], alpha, 0);
	
	if (showUpdatePrompt) then
		if (mouseClipped(x, y, w, h) and isUpdateButton) then
			allowClick = mouseClipped(x, y, w, h) and isUpdateButton;
			hoveredButton = buttons[currentButton]['action'];
			gfx.ImageRect(x, y, w, h, buttons[currentButton]['imgHover'], 1, 0);
		end
	else
		if (menuLoaded and (mouseClipped(x, y, w, h) or isActive)) then
			activeButton = currentButton;
			allowClick = mouseClipped(x, y, w, h);
			hoveredButton = buttons[currentButton]['action'];
			gfx.ImageRect(x, y, w, h, buttons[currentButton]['imgHover'], 1, 0);
		end
	end

	return w;
end

drawUpdatePrompt = function(updateUrl, updatePrompt, deltaTime)
	if (showUpdatePrompt == false) then return end;

	fadeTimer = math.min(fadeTimer + (deltaTime * 3), 1);

	gfx.BeginPath();
	gfx.FillColor(0, 0, 0, math.floor(235 * fadeTimer));
	gfx.Rect(0, 0, scaledW, scaledH);
	gfx.Fill();

	gfx.BeginPath();
	gfx.LoadSkinFont('GothamBook.ttf');
	gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
	gfx.FontSize(40);
	gfx.FillColor(255, 255, 255, math.floor(255 * fadeTimer));
	gfx.Text('A NEW UPDATE IS AVAILABLE!', scaledW / 2, (scaledH / 2) - 100);

	local updateButtonX = (scaledW / 2) - ((buttonWidth * 3) / 2) - 100;
	local updateButtonY = scaledH / 2;

	for currentButton = 6, 8 do
		updateButtonX = updateButtonX + drawButton(updateButtonX, updateButtonY, currentButton) + 100;
	end
end

closeUpdatePrompt = function()
	showUpdatePrompt = false;
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
	if (button == game.BUTTON_STA) then 
		buttons[activeButton]['action']();
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

		if (hoveredButton == buttons[currentButton]['action']) then
			selectedButton = currentButton;
		end
	end
	
	activeButton = controller:handleInput(activeButton);

	loadMenu(deltaTime);

	if (menuLoaded and updateUrl) then
		showUpdatePrompt = true;
		drawUpdatePrompt(updateUrl, updateVersion, deltaTime);
	end
end