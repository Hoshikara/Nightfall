local Controller = require('common/controller');
local Cursor = require('common/cursor');

local controls = require('titlescreen/controls');
local dialog = require('layout/dialog');
local easing = require('lib/easing');

controls:initializeAll();

game.LoadSkinSample('click_button');
game.LoadSkinSample('intro');

local activeButton = 1;
local activePage = 'mainMenu';

local allowClick = false;

local background = Image.New('bg.png');

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
local introSamplePlayed = false;
local menuLoaded = false;

local hoveredPage = nil;
local showControls = false;

local cache = { resX = 0, resY = 0 };

local aspectRatio;
local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

setupLayout = function()
  resX, resY = game.GetResolution();

	if ((cache.resX ~= resX) or (cache.resY ~= resY)) then
		aspectRatio = tonumber(string.format('%.4f', (resX / resY)));

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
	if (not introSamplePlayed) then
		game.PlaySample('intro');

		introSamplePlayed = true;
	end

	if (not updateChecked) then
		updateUrl, updateVersion = game.UpdateAvailable();

		if (updateUrl) then
			showUpdatePrompt = true;
			updateChecked = true;
		end
	end

	introTimer = math.max(introTimer - (deltaTime / 1.8), 0);

	gfx.BeginPath();
	Fill.Black(255 * introTimer);
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
	cursor = Cursor.New(),
	images = {
		button = Image.New('buttons/normal.png'),
		buttonHover = Image.New('buttons/normal_hover.png'),
	},
	labels = nil,
	margin = 0,
	x = {},
	y = 0,

	setSizes = function(self)
		if ((scaledW ~= self.cache.scaledW) or (scaledH ~= self.cache.scaledH)) then
			local maxWidth = scaledW - (scaledW / 6);

			self.margin = (maxWidth - (self.images.button.w * 5)) / 4;
			self.x[1] = scaledW / 20;
			self.y = scaledH - (scaledH / 4);

			local x = self.x[1];

			for i = 2, 5 do
				x = x + self.images.button.w + self.margin;

				self.x[i] = x;
			end

			self.cursor:setSizes({
				x = self.x[1] + 10,
				y = self.y + 10,
				w = self.images.button.w - 20,
				h = self.images.button.h - 20,
				margin = self.margin + 20,
			});

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			Font.Medium();

			self.labels = {
				mainMenu = {
					{
						action = function()
							activeButton = 1;
							activePage = 'playOptions';
							self.activePage = activePage;
						end,
						label = Label.New('PLAY', 18)
					},
					{
						action = Menu.DLScreen,
						label = Label.New('NAUTICA', 18)
					},
					{
						action = function()
							activeButton = 1;
							showControls = true;
						end,
						label = Label.New('CONTROLS', 18)
					},
					{
						action = Menu.Settings,
						label = Label.New('SETTINGS', 18)
					},
					{
						action = Menu.Exit,
						label = Label.New('EXIT', 18)
					}
				},
				playOptions = {
					{
						action = Menu.Start,
						label = Label.New('SINGLEPLAYER', 18)
					},
					{
						action = Menu.Multiplayer,
						label = Label.New('MULTIPLAYER', 18)
					},
					{
						action = Menu.Challenges,
						label = Label.New('CHALLENGES', 18)
					},
					{
						action = function()
							activeButton = 1;
							activePage = 'mainMenu';
							self.activePage = activePage;
						end,
						label = Label.New('MAIN MENU', 18)
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
		FontAlign.Left();
		self.labels[page][i].label:draw({
			x = self.x[i] + (self.images.button.w / 8) + 4,
			y = self.y + (self.images.button.h / 2) - 12,
			a = textAlpha,
			color = 'White',
		});
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		local currentButtons = self.labels[self.activePage];

		for i = 1, #currentButtons do
			self:drawButton(i, self.activePage, currentButtons[i].action);
		end

		if (menuLoaded and (not showControls) and (not showUpdatePrompt)) then
			self.cursor:setPosition({
				current = activeButton,
				total = 5,
				horizontal = true,
			});

			self.cursor:render(deltaTime, {
				size = 12,
				stroke = 1.5,
				horizontal = true,
			});
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
			self.y = scaledH / 4;

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			Font.Medium();

			self.labels = {
				game = Label.New('UNNAMED SDVX CLONE', 31),
			};

			self.labels.skin = Label.New('NIGHTFALL', 120);
		end
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		self.timer = self.timer + deltaTime;

		self.alpha = math.floor(self.timer * 30) % 2;
		self.alpha = ((self.alpha * 55) + 200) / 255;
	
		if (self.timer >= 0.22) then
			self.alpha = 1;
		end
	
		local alpha = (showControls and 30) or math.floor(255 * self.alpha);

		gfx.BeginPath();
		FontAlign.Left();

		self.labels.game:draw({
			x = self.x + 8,
			y = self.y,
			a = alpha,
			color = 'Normal',
			maxWidth = (self.labels.skin.w * 0.54) - 3,
		});
		
		self.labels.skin:draw({
			x = self.x,
			y = self.y + (self.labels.game.h * 0.25),
			a = alpha,
			color = 'White',
		});
	end
};

local updatePrompt = {
	buttons = {
		normal = Image.New('buttons/short.png'),
		hover = Image.New('buttons/short_hover.png'),
		margin = 0,
		x = {},
		y = 0,
	},
	cache = { scaledH = 0, scaledW = 0 },
	cursor = Cursor.New(),
	labels = nil,
	timer = 0,

	setSizes = function(self)
		if ((scaledW ~= self.cache.scaledW) or (scaledH ~= self.cache.scaledH)) then
			dialog:setSizes(scaledW, scaledH);

			self.buttons.margin = (dialog.w.outer - (self.buttons.normal.w * 3)) / 4;

			self.buttons.x[3] = dialog.x.outerRight - self.buttons.normal.w;
			self.buttons.x[2] = self.buttons.x[3]
				- (self.buttons.normal.w + self.buttons.margin);
			self.buttons.x[1] = self.buttons.x[2]
			- (self.buttons.normal.w + self.buttons.margin);
			self.buttons.y = dialog.y.bottom - self.buttons.normal.h + 10;

			self.cursor:setSizes({
				x = self.buttons.x[1] + 10,
				y = self.buttons.y + 10,
				w = self.buttons.normal.w - 20,
				h = self.buttons.normal.h - 20,
				margin = self.buttons.margin + 20,
			});

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			Font.Medium();

			self.labels = {
				{
					action = Menu.Update,
					label = Label.New('UPDATE', 18)
				},
				{
					action = viewUpdate,
					label = Label.New('VIEW', 18)
				},
				{
					action = function()
						activeButton = 1;
						activePage = 'mainMenu';
						showUpdatePrompt = false;
					end,
					label = Label.New('CLOSE', 18)
				}
			};

			Font.Normal();

			self.labels.heading = Label.New('A NEW UPDATE IS AVAILABLE!', 36);
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
		FontAlign.Left();
		button.label:draw({
			x = self.buttons.x[i] + (self.buttons.normal.w / 6) + 2,
			y = self.buttons.y + (self.buttons.normal.h / 2) - 12,
			a = alpha,
			color = 'White',
		});
	end,

	drawCursor = function(self, deltaTime)
		self.cursor:setPosition({
			current = activeButton,
			total = 3,
			horizontal = true,
		});

		self.cursor:render(deltaTime, {
			size = 10,
			stroke = 1.5,
			horizontal = true,
		});
	end,

	render = function(self, deltaTime)
		self:setSizes();

		self:setLabels();

		self.timer = math.min(self.timer + (deltaTime * 3), 1);

		gfx.BeginPath();
		Fill.Black(150 * self.timer);
		gfx.Rect(0, 0, scaledW, scaledH);
		gfx.Fill();

		dialog.images.dialogBox:draw({
			x = scaledW / 2,
			y = scaledH / 2,
			a = self.timer,
			centered = true,
		});

		gfx.BeginPath();
		FontAlign.Left();
		self.labels.heading:draw({
			x = dialog.x.outerLeft,
			y = dialog.y.top - 8,
			a = 255 * self.timer,
			color = 'White',
		});

		for i, button in ipairs(self.labels) do
			self:drawButton(i, button);
		end

		self:drawCursor(deltaTime);
	end,
};

render = function(deltaTime)
	setupLayout();

	mousePosX, mousePosY = game.GetMousePos();

	background:draw({
		x = 0,
		y = 0,
		w = scaledW,
		h = scaledH,
	});

	if (not menuLoaded) then
		loadMenu(deltaTime);
	end

	activeButton = Controller:handleInput({
		current = activeButton,
		total = ((showControls and 8) or buttonCount[activePage]),
	});

	clickAction = nil;

	buttons:render(deltaTime);

	if (menuLoaded) then
		if (showUpdatePrompt) then
			activePage = 'update';

			updatePrompt:render(deltaTime);
		else
			title:render(deltaTime);
		end
	end

	hoveredPage = controls:render(deltaTime, showControls, activeButton);

	if (aspectRatio ~= 1.7778) then
		drawResolutionWarning(6, scaledH - 24);
	end

	if (previousButton ~= activeButton) then
		if (showUpdatePrompt) then
			updatePrompt.cursor.timer.flicker = 0;
		else
			buttons.cursor.timer.flicker = 0;
		end
		
		previousButton = activeButton;
	end

	if (previousPage ~= activePage) then
		buttons.cursor.timer.flicker = 0;

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
		elseif ((activePage ~= 'mainMenu') and (buttons.activePage ~= 'mainMenu')) then
			activeButton = 1;
			activePage = 'mainMenu';
			buttons.activePage = activePage;
		else
			Menu.Exit();
		end
	end
end