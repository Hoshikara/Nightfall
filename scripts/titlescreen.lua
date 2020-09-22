local controller = require('common/controller');
local controls = require('titlescreen/controls');
local cursor = require('titlescreen/cursor');
local dialog = require('layout/dialog');
local easing = require('lib/easing');

controls:initializeAll();

local activeButton = 1;
local activePage = 'mainMenu';

local allowClick = false;

local buttonCount = {
	mainMenu = 5,
	playOptions = 4,
	update = 3,
};

local clickAction = nil;

local previousButton = 1;
local previousPage = '';

local mousePosX = 0;
local mousePosY = 0;

local showUpdatePrompt = false;
local updateChecked = false;

local introTimer = 1;
local menuLoaded = false;

local hoveredPage = nil;
local showControls = false;

local background = cacheImage('main_menu/menu_bg.png');

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

loadMenu = function(deltaTime)
	if (not updateChecked) then
		updateUrl, updateVersion = game.UpdateAvailable();

		if (updateUrl) then
			showUpdatePrompt = true;
			updateChecked = true;
		end
	end

	introTimer = math.max(introTimer - (deltaTime / 3), 0);

	gfx.BeginPath();
	fill.black(255 * introTimer);
	gfx.Rect(0, 0, scaledW, scaledH);
	gfx.Fill();

	if (introTimer == 0) then
		menuLoaded = true;
	end
end

viewUpdate = function()
	if (package.config:sub(1,1) == '\\') then
		updateUrl, updateVersion = game.UpdateAvailable();
		os.execute('start ' .. updateUrl);
	else
		os.execute('xdg-open ' .. updateUrl);
	end
end

local buttons = {
	activePage = 'mainMenu',
	cache = { scaledH = 0, scaledW = 0 },
	cursor = {
		alpha = 0,
		flickerTimer = 0,
		timer = 0,
		x = 0,
	},
	images = {
		button = cacheImage('main_menu/button.png'),
		buttonHover = cacheImage('main_menu/button_hover.png'),
	},
	labels = nil,
	spacing = 0,
	x = {},
	y = 0,

	setSizes = function(self)
		if ((scaledW ~= self.cache.scaledW) or (scaledH ~= self.cache.scaledH)) then
			local maxWidth = scaledW - (scaledW / 6);

			self.spacing = (maxWidth - (self.images.button.w * 5)) / 4;
			self.x[1] = scaledW / 20;
			self.y = scaledH - (scaledH / 4);

			local x = self.x[1];

			for i = 2, 5 do
				x = x + self.images.button.w + self.spacing;

				self.x[i] = x;
			end

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			font.medium();

			self.labels = {
				mainMenu = {
					{
						action = function()
							activeButton = 1;
							activePage = 'playOptions';
							self.activePage = activePage;
						end,
						label = cacheLabel('PLAY', 18)
					},
					{
						action = Menu.DLScreen,
						label = cacheLabel('NAUTICA', 18)
					},
					{
						action = function()
							activeButton = 1;
							showControls = true;
						end,
						label = cacheLabel('CONTROLS', 18)
					},
					{
						action = Menu.Settings,
						label = cacheLabel('SETTINGS', 18)
					},
					{
						action = Menu.Exit,
						label = cacheLabel('EXIT', 18)
					}
				},
				playOptions = {
					{
						action = Menu.Start,
						label = cacheLabel('SINGLEPLAYER', 18)
					},
					{
						action = Menu.Multiplayer,
						label = cacheLabel('MULTIPLAYER', 18)
					},
					{
						action = function()
						end,--Menu.Challenges,
						label = cacheLabel('CHALLENGES', 18)
					},
					{
						action = function()
							activeButton = 1;
							activePage = 'mainMenu';
							self.activePage = activePage;
						end,
						label = cacheLabel('MAIN MENU', 18)
					}
				}
			};
		end
	end,

	drawButton = function(self, i, page, currentAction)
		local isNavigable = menuLoaded and (not showControls);
		local allowAction = isNavigable and (not showUpdatePrompt);
		local isActive = currentAction
			== (isNavigable and self.labels[page][activeButton].action);
		local isHovering = mouseClipped(
			self.x[i],
			self.y - 10,
			self.images.button.w,
			self.images.button.h + 20
		);
		local textAlpha = math.floor(255 * ((allowAction and isActive and 1) or 0.2));

		if (allowAction and (isHovering or isActive)) then
			activeButton = i;
			allowClick = isHovering;
			clickAction = currentAction;

			self.images.buttonHover:draw({ x = self.x[i], y = self.y });
		else
			self.images.button:draw({
				x = self.x[i],
				y = self.y,
				a = 0.45,
			});
		end

		gfx.BeginPath();
		align.left();
		fill.white(textAlpha);
		self.labels[page][i].label:draw({
			x = self.x[i] + (self.images.button.w / 8) + 4,
			y = self.y + (self.images.button.h / 2) - 12,
		});
	end,

	drawCursor = function(self, deltaTime, x)
		self.cursor.timer = self.cursor.timer + deltaTime;
		self.cursor.flickerTimer = self.cursor.flickerTimer + deltaTime;
	
		self.cursor.alpha = math.floor(self.cursor.flickerTimer * 30) % 2;
	
		if (self.cursor.flickerTimer >= 0.3) then
			self.cursor.alpha = math.abs(0.8 * math.cos(self.cursor.timer * 5)) + 0.2;
		end
	
		self.cursor.x = self.cursor.x - (self.cursor.x - x - 4) * deltaTime * 36;
	
		gfx.Save();
	
		gfx.BeginPath();
	
		cursor:drawCursor(
			self.cursor.x,
			self.y + (self.images.button.h / 2),
			self.images.button.w - 24,
			self.images.button.h - 24,
			4,
			self.cursor.alpha
		);
	
		gfx.Restore();
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		local currentButtons = self.labels[self.activePage];

		for i = 1, #currentButtons do
			self:drawButton(i, self.activePage, currentButtons[i].action);
		end

		if (menuLoaded and (not showControls) and (not showUpdatePrompt)) then
			self:drawCursor(deltaTime, self.x[activeButton]);
		end
	end,
};

local title = {
	alpha = 0,
	cache = { scaledW = 0, scaledH = 0 },
	labels = nil,
	timer = 0,
	x = 0,
	y = 0,

	setSizes = function(self)
		if ((scaledW ~= self.cache.scaledW) or (scaledH ~= self.cache.scaledH)) then
			self.x = scaledW / 20;
			self.y = scaledH / 5;

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			font.normal();

			self.labels = {
				unnamed = cacheLabel('UNNAMED', 64),
				clone = cacheLabel('CLONE', 64)
			};

			font.bold();

			self.labels.soundVoltex = cacheLabel('SOUND VOLTEX', 110);
		end
	end,

	drawTitle = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		self.timer = self.timer + deltaTime;

		self.alpha = math.floor(self.timer * 30) % 2;
		self.alpha = ((self.alpha * 55) + 200) / 255;
	
		if (self.timer >= 0.22) then
			self.alpha = 1;
		end
	
		local alpha = (showControls and 30) or math.floor(255 * self.alpha);
		local y = self.y;

		gfx.BeginPath();
		fill.white(alpha);
	
		align.left();
		self.labels.unnamed:draw({ x = self.x, y = y });

		y = y + self.labels.unnamed.h * 0.7;

		self.labels.soundVoltex:draw({ x = self.x, y = y });

		y = y + self.labels.soundVoltex.h;

		align.right();
		self.labels.clone:draw({ x = self.x + self.labels.soundVoltex.w, y = y });
	end
};

local updatePrompt = {
	buttons = {
		normal = cacheImage('main_menu/button_short.png'),
		hover = cacheImage('main_menu/button_short_hover.png'),
		spacing = 0,
		x = {},
		y = 0,
	},
	cache = { scaledH = 0, scaledW = 0 },
	cursor = {
		alpha = 0,
		flickerTimer = 0,
		timer = 0,
		x = 0,
	},
	labels = nil,
	timer = 0,

	setSizes = function(self)
		if ((scaledW ~= self.cache.scaledW) or (scaledH ~= self.cache.scaledH)) then
			dialog:setSizes(scaledW, scaledH);

			self.buttons.spacing = (dialog.w.outer - (self.buttons.normal.w * 3)) / 4;

			self.buttons.x[3] = dialog.x.outerRight - self.buttons.normal.w;
			self.buttons.x[2] = self.buttons.x[3]
				- (self.buttons.normal.w + self.buttons.spacing);
			self.buttons.x[1] = self.buttons.x[2]
			- (self.buttons.normal.w + self.buttons.spacing);
			self.buttons.y = dialog.y.bottom - self.buttons.normal.h + 12;

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			font.medium();

			self.labels = {
				{
					action = Menu.Update,
					label = cacheLabel('UPDATE', 18)
				},
				{
					action = viewUpdate,
					label = cacheLabel('VIEW', 18)
				},
				{
					action = function()
						activeButton = 1;
						activePage = 'mainMenu';
						showUpdatePrompt = false;
					end,
					label = cacheLabel('CLOSE', 18)
				}
			};

			font.normal();

			self.labels.heading = cacheLabel('A NEW UPDATE IS AVAILABLE!', 36);
		end
	end,

	drawButton = function(self, i, button)
		local isActive = button.action == self.labels[activeButton].action;
		local isHovering = mouseClipped(
			self.buttons.x[i],
			self.buttons.y - 10,
			self.buttons.normal.w,
			self.buttons.normal.h + 20
		);
		local textAlpha = math.floor(255 * ((isActive and 1) or 0.2));

		if (isHovering or isActive) then
			activeButton = i;
			allowClick = isHovering;
			clickAction = button.action;

			self.buttons.hover:draw({ x = self.buttons.x[i], y = self.buttons.y });
		else
			self.buttons.normal:draw({
				x = self.buttons.x[i],
				y = self.buttons.y,
				a = 0.45,
			});
		end

		gfx.BeginPath();
		align.left();
		fill.white(alpha);
		button.label:draw({
			x = self.buttons.x[i] + (self.buttons.normal.w / 6) + 2,
			y = self.buttons.y + (self.buttons.normal.h / 2) - 12,
		});
	end,

	drawCursor = function(self, deltaTime, x)
		self.cursor.timer = self.cursor.timer + deltaTime;
		self.cursor.flickerTimer = self.cursor.flickerTimer + deltaTime;
	
		self.cursor.alpha = math.floor(self.cursor.flickerTimer * 30) % 2;
	
		if (self.cursor.flickerTimer >= 0.3) then
			self.cursor.alpha = math.abs(0.8 * math.cos(self.cursor.timer * 5)) + 0.2;
		end
	
		self.cursor.x = self.cursor.x - (self.cursor.x - x - 4) * deltaTime * 36;
	
		gfx.Save();
	
		gfx.BeginPath();
	
		cursor:drawCursor(
			self.cursor.x,
			self.buttons.y + (self.buttons.normal.h / 2),
			self.buttons.normal.w - 24,
			self.buttons.normal.h - 24,
			4,
			self.cursor.alpha
		);
	
		gfx.Restore();
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		self.timer = math.min(self.timer + (deltaTime * 3), 1);

		gfx.BeginPath();
		fill.black(150 * self.timer);
		gfx.Rect(0, 0, scaledW, scaledH);
		gfx.Fill();

		dialog.images.dialogBox:draw({
			x = scaledW / 2,
			y = scaledH / 2,
			a = self.timer,
			centered = true,
		});

		gfx.BeginPath();
		align.left();
		fill.white(255 * self.timer);
		self.labels.heading:draw({ x = dialog.x.outerLeft, y = dialog.y.top - 8 });

		for i, button in ipairs(self.labels) do
			self:drawButton(i, button);
		end

		self:drawCursor(deltaTime, self.buttons.x[activeButton]);
	end,
};

render = function(deltaTime)
	setupLayout();

	mousePosX, mousePosY = game.GetMousePos();

	background:draw({
		x = 0,
		y = 0,
		w = scaledW,
		h = scaledH
	});

	if (not menuLoaded) then
		loadMenu(deltaTime);
	end

	activeButton = controller:handleInput(
		activeButton,
		(showControls and 8) or buttonCount[activePage]
	);

	clickAction = nil;

	buttons:render(deltaTime);

	if (menuLoaded) then
		if (showUpdatePrompt) then
			activePage = 'update';

			updatePrompt:render(deltaTime);
		else
			title:drawTitle(deltaTime);
		end
	end

	hoveredPage = controls:render(deltaTime, showControls, activeButton);

	if (previousButton ~= activeButton) then
		-- PLAY SAMPLE HERE
		if (showUpdatePrompt) then
			updatePrompt.cursor.flickerTimer = 0;
		else
			buttons.cursor.flickerTimer = 0;
		end
		
		previousButton = activeButton;
	end

	if (previousPage ~= activePage) then
		buttons.cursor.flickerTimer = 0;

		previousPage = activePage;
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

	if (allowClick and clickAction) then
		clickAction();
	end

	return 0;
end

button_pressed = function(button)
	if (button == game.BUTTON_STA) then
		if (showControls) then
			activeButton = 1;
			showControls = false;
		else
			clickAction();
		end
	elseif (button == game.BUTTON_BCK) then
		if (showControls) then
			activeButton = 1;
			showControls = false;
		elseif (showUpdatePrompt) then
			activeButton = 1;
			showUpdatePrompt = false;
		elseif (activePage ~= 'mainMenu' and buttons.activePage ~= 'mainMenu') then
			activeButton = 1;
			activePage = 'mainMenu';
			buttons.activePage = activePage;
		else
			Menu.Exit();
		end
	end
end