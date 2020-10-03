local CONSTANTS_SONGWHEEL = require('constants/songwheel')
local CONSTANTS_MULTI = require('constants/multiplayerscreen');

local dialogWindow = require('multiplayerscreen/dialogWindow');
local json = require('lib/json');
local number = require('common/number');
local pages = require('common/pages');

game.LoadSkinSample('click-02');
game.LoadSkinSample('click-01');
game.LoadSkinSample('menu_click');

local allowClick = false;

local allReady;
local allRooms = {};
local allUsers = {};

local background = cacheImage('bg.png');

local allowHardToggle = game.GetSkinSetting('toggleHard') or false;
local allowMirrorToggle = game.GetSkinSetting('toggleMirror') or false;

local didExit = false;

local hardGauge = false;
local host = nil;

local isLoading = true;
local isMissingSong = false;
local isStartingGame = false;

local hoveredButton = nil;

local mirrorMode = false;

local jacket = nil;
local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

local mousePosX = 0;
local mousePosY = 0;

local owner = nil;

local previousAllReady = nil;
local previousWindow = '';
local previousSong = nil;

local selectedRoom = nil;
local selectedRoomIndex = 1;

local userId = nil;
local userName = nil;
local userReady;

do
	local usernameKey = game.GetSkinSetting('multi.user_name_key');

	if (not userNameKey) then
		userNameKey = 'displayName';
	end

	local userName = game.GetSkinSetting(userNameKey) or '';

	if ((not userName) or (userName == '')) then
		userName = 'GUEST';
	end
end

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

getGrade = function(score)
	for _, breakpoint in ipairs(CONSTANTS_SONGWHEEL.grades) do
		if (score >= breakpoint.minimum) then
			return breakpoint.grade;
		end
	end
end

local roomCreation = dialogWindow.create(CONSTANTS_MULTI.dialog.roomCreation);
local passwordCreation = dialogWindow.create(CONSTANTS_MULTI.dialog.passwordCreation);
local passwordRequired = dialogWindow.create(CONSTANTS_MULTI.dialog.passwordRequired);
local usernameCreation = dialogWindow.create(CONSTANTS_MULTI.dialog.usernameCreation);

local roomList = {
	alpha = 0,
	bounds = { lower = 0, upper = 0 },
	cache = { scaledW = 0, scaledH = 0 },
	cursor = {
		alpha = 0,
		flickerTimer = 0,
		index = selectedRoomIndex,
		pos = 0,
		timer = 0,
		y = {},
	},
	images = {
		button = cacheImage('buttons/normal.png'),
		buttonHover = cacheImage('buttons/normal_hover.png'),
	},
	info = nil,
	labels = nil,
	order = {
		'name',
		'capacity',
		'password',
		'status',
	},
	room = {
		padding = 0,
		spacing = {
			inner = 0,
			outer = 0,
		},
		w = 0,
		h = 0,
		x = 0,
		y = 0,
	},
	roomCount = 0,
	text = {},
	timer = 0,
	viewLimit = 5,
	x = 0,
	y = 0,

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.x = scaledW / 20;
			self.y = scaledH / 20;

			self.room.w = scaledW / 1.75;
			self.room.h = scaledH / 10;
			self.room.x = (scaledW / 2) - (self.room.w / 2);
			self.room.y = self.y + (self.labels.heading.h * 2.5);
			self.room.padding = self.room.h / 4;
			self.room.spacing.inner = (self.room.w - (self.room.padding * 2)) / 8;
			self.room.spacing.outer = (scaledH
				- (scaledH / 6)
				- self.room.y
				- (self.room.h * self.viewLimit)
			) / (self.viewLimit - 1);

			self.text[1] = 0;
			self.text[2] = self.room.spacing.inner * 3.5;
			self.text[3] = self.room.spacing.inner * 5;
			self.text[4] = self.room.spacing.inner * 6.5;

			self.cursor.y = {};

			self.cache.scaledW = scaledW;
			self.cache.scaledH = scaledH;
		end
	end,

	setLabels = function(self)
		if (not self.labels) then
			font.medium();

			self.labels = {
				createRoom = cacheLabel('CREATE ROOM', 18),
			};

			font.normal();

			self.labels.heading = cacheLabel('MULTIPLAYER ROOMS', 60);
		end
	end,

	setInfo = function(self)
		if (#allRooms ~= self.roomCount) then
			self.info = {};

			for i, room in ipairs(allRooms) do
				self.info[i] = {
					capacity = string.format('%d  /  %d', room.current, room.max),
					name = string.upper(room.name),
				password = (room.password and 'YES') or 'NO',
					status = (room.ingame and 'IN GAME') or 'IN LOBBY',
				};
			end

			self.roomCount = #allRooms;
		end
	end,

	handleNavigation = function(self)
		local cursorIndex = ((selectedRoomIndex % self.viewLimit > 0)
			and (selectedRoomIndex % self.viewLimit))
			or self.viewLimit;
		local lowerBound, upperBound = pages.getPageBounds(
			self.viewLimit,
			#allRooms,
			selectedRoomIndex
		);

		self.cursor.index = selectedRoomIndex;
		self.bounds.lower = lowerBound;
		self.bounds.upper = upperBound;
	end,

	drawButton = function(self)
		local x = (scaledW / 2) - (self.images.button.w / 2);
		local y = scaledH - (scaledH / 20) - self.images.button.h;
		local allowAction = mouseClipped(
			x,
			y,
			self.images.button.w,
			self.images.button.h
		) and (screenState == 'roomList');

		gfx.Save();

		gfx.BeginPath();

		if (allowAction) then
			hoveredButton = createRoom;

			self.images.buttonHover:draw({ x = x, y = y });
		else
			self.images.button:draw({
				x = x,
				y = y,
				a = 0.45,
			});
		end

		gfx.BeginPath();
		align.left();
		self.labels.createRoom:draw({
			x = x + 40,
			y = y + 25,
			a = (allowAction and 255) or 50,
			color = 'white',
		});

		gfx.Restore();
	end,

	drawCursor = function(self, deltaTime)
		self.cursor.timer = self.cursor.timer + deltaTime;
		self.cursor.flickerTimer = self.cursor.flickerTimer + deltaTime;
	
		self.cursor.alpha = math.floor(self.cursor.flickerTimer * 30) % 2;
	
		if (self.cursor.flickerTimer >= 0.3) then
			self.cursor.alpha = math.abs(0.8 * math.cos(self.cursor.timer * 5)) + 0.2;
		end

		self.cursor.pos = self.cursor.pos
			- (self.cursor.pos - self.cursor.y[selectedRoomIndex])
			* deltaTime
			* 36;

		gfx.Save();
	
		drawCursor({
			x = self.room.x,
			y = self.room.y,
			w = self.room.w,
			h = self.room.h,
			alpha = self.cursor.alpha,
			size = 16,
			stroke = 1.5,
		});

		gfx.Restore();
	end,

	drawRoom = function(self, roomIndex, initialY)
		if (not allRooms[roomIndex]) then return end

		local x = self.room.x + self.room.padding;
		local y = self.room.y + self.room.padding + initialY;

		gfx.BeginPath();
		fill.dark(120);
		gfx.Rect(self.room.x, self.room.y + initialY, self.room.w, self.room.h);
		gfx.Fill();

		gfx.BeginPath();
		align.left();

		for i, name in ipairs(self.order) do
			font.medium();
			gfx.FontSize(18);

			fill.dark(255 * 0.5);
			gfx.Text(string.upper(name), x + self.text[i] + 1, y + 1);

			fill.normal();
			gfx.Text(string.upper(name), x + self.text[i], y);

			local infoY = ((name == 'capacity') and (y + 24)) or (y + 28);

			if (name == 'capacity') then
				font.number();
				gfx.FontSize(30);
			else
				font.normal();
				gfx.FontSize(24);
			end

			fill.dark(255 * 0.5);
			gfx.Text(self.info[roomIndex][name], x + self.text[i] + 1, infoY + 1);

			fill.white();
			gfx.Text(self.info[roomIndex][name], x + self.text[i], infoY);
		end

		if (mouseClipped(
			self.room.x,
			self.room.y + initialY,
			self.room.w,
			self.room.h
		)) then
			if (screenState == 'roomList') then
				hoveredButton = function()
					joinRoom(allRooms[roomIndex]);
				end

				selectedRoomIndex = roomIndex;
			end
		end

		return self.room.h + self.room.spacing.outer;
	end,

	render = function(self, deltaTime)
		if (screenState ~= 'roomList') then
			self.timer = math.min(self.timer + (deltaTime * 8), 1);
		else
			if (self.timer > 0) then
				self.timer = math.max(self.timer - (deltaTime * 6), 0);
			end
		end

		self.alpha = 255 - (180 * self.timer);

		self:setLabels();

		self:setSizes();

		self:setInfo();

		self:handleNavigation();
		
		gfx.Save();

		gfx.BeginPath();
		align.left();
		self.labels.heading:draw({
			x = self.x,
			y = self.y,
			a = self.alpha,
			color = 'white',
		});

		if (#allRooms > 0) then
			local y = 0;

			if (not self.cursor.y[self.viewLimit]) then
				for i = 1, self.viewLimit do
					self.cursor.y[i] = self.room.y
						+ ((self.room.h + self.room.spacing.outer) * (i - 1));
				end
			end

			for i = self.bounds.lower, self.bounds.upper do
				y = y + self:drawRoom(i, y);
			end

			if (screenState == 'roomList') then
				self:drawCursor(deltaTime);
			end
		end

		if (not isLoading) then
			self:drawButton();
		end

		gfx.BeginPath();
		fill.black(170 * self.timer);
		gfx.Rect(0, 0, scaledW, scaledH);
		gfx.Fill();

		gfx.Restore();
	end,
};

local songInfo = {
	cache = { scaledW = 0, scaledH = 0 },
	cursor = {
    alpha = 0,
    flickerTimer = 0,
    selected = 0,
    timer = 0,
    x = 0,
    y = {},
  },
	difficulties = nil,
	images = {
    button = cacheImage('buttons/short.png'),
    buttonHover = cacheImage('buttons/short_hover.png'),
    panel = cacheImage('common/panel.png')
	},
	jacketSize = 0,
	labels = nil,
	levels = nil,
	order = {
		'title',
		'artist',
		'effector',
		'bpm',
	},
	padding = {
		x = {
			double = 0,
			full = 0,
			half = 0,
			quarter = 0,
		},
		y = {
			double = 0,
			full = 0,
			half = 0,
			quarter = 0,
		},
	},
  panel = {
		centerX = 0,
    w = 0,
    h = 0,
    x = 0,
    y = 0,
  },
	scrollTimers = {
    artist = 0,
    effector = 0,
    title = 0,
	},
	selectedDifficulty = nil,
	songInfo = nil,
	toggles = {
		spacing = 0,
	},

	setSizes = function(self)
    if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
      self.jacketSize = scaledW / 5;

      self.panel.w = scaledW / (scaledW / self.images.panel.w);
      self.panel.h = scaledH - (scaledH / 10);
      self.panel.x = scaledW / 20;
      self.panel.y = scaledH / 20;
      self.panel.centerX = self.panel.w / 2;

      self.padding.x.full = self.panel.w / 20;
      self.padding.x.double = self.padding.x.full * 2;
      self.padding.x.half = self.padding.x.full / 2;
      self.padding.x.quarter = self.padding.x.full / 4;

      self.padding.y.full = self.panel.h / 20;
      self.padding.y.double = self.padding.y.full * 2;
      self.padding.y.half = self.padding.y.full / 2;
      self.padding.y.quarter = self.padding.y.full / 4;

			self.cursor.x = self.padding.x.double + self.jacketSize + self.padding.x.full - 6;
			self.cursor.y = {};

      self.panel.innerWidth = self.panel.w - (self.padding.x.double * 2);

      self.labels.x = self.padding.x.double;
			self.labels.y = self.padding.y.double + self.jacketSize;
			
			local maxWidth = scaledW - ((scaledW / 20) * 3) - self.panel.w;

			self.toggles.spacing = (maxWidth
				- (32 * 3)
				- self.labels.rotateHost.w
				- self.labels.hardGauge.w
				- self.labels.mirrorMode.w
			) / 2;

      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
	end,
	
	setLabels = function(self)
		if (not self.labels) then
			self.difficulties = {};
			self.levels = {};
			self.songInfo = {};

			font.number();

			for i, level in ipairs(CONSTANTS_SONGWHEEL.levels) do
				self.levels[i] = cacheLabel(level, 18);
			end

			self.songInfo.bpm = cacheLabel('000', 24);

			font.medium();

			self.labels = {
				hardGauge = cacheLabel('HARD GAUGE', 20),
				mirrorMode = cacheLabel('MIRROR MODE', 20),
				rotateHost = cacheLabel('ROTATE HOST', 20),
			};

			for name, label in pairs(CONSTANTS_SONGWHEEL.labels.info) do
				self.labels[name] = cacheLabel(label, 18);
			end

			for i, difficulty in ipairs(CONSTANTS_SONGWHEEL.difficulties) do
				self.difficulties[i] = cacheLabel(difficulty, 18);
			end

			font.normal();

			self.songInfo.effector = cacheLabel('EFFECTOR', 24);

			self.labels.disabled = cacheLabel('DISABLED', 24);
			self.labels.enabled = cacheLabel('ENABLED', 24);
			self.labels.hard = cacheLabel('HARD', 24);
			self.labels.normal = cacheLabel('NORMAL', 24);

			font.jp();

			self.songInfo.artist = cacheLabel('ARTIST', 36);
			self.songInfo.title = cacheLabel('TITLE', 36);
		end
	end,

	setDifficulty = function(self, newDifficulty)
		if (self.selectedDifficulty ~= newDifficulty) then
			self.cursor.flickerTimer = 0;

			self.selectedDifficulty = newDifficulty;
		end
	end,

	getDifficulty = function(self, difficulties, index)
		local difficultyIndex = nil;
	
		for i, v in pairs(difficulties) do
			if ((v.difficulty + 1) == index) then
				difficultyIndex = i;
			end
		end
	
		local difficulty = nil;
	
		if (difficultyIndex) then
			difficulty = difficulties[difficultyIndex];
		end
	
		return difficulty;
	end,

	drawLabels = function(self)
		local baseHeight = self.labels.title.h;
		local y = self.labels.y - 4;

		gfx.Save();

		gfx.BeginPath();
		align.left();

		self.labels.difficulty:draw({
			x = self.padding.x.double + self.jacketSize + self.padding.x.full + 6,
			y = self.padding.y.full - 4,
			color = 'normal',
		});

		for _, name in ipairs(self.order) do
			self.labels[name]:draw({
				x = self.labels.x,
				y = y,
				color = 'normal',
			});

			y = y
				+ baseHeight
				+ self.padding.y.quarter
				+ self.songInfo[name].h
				+ self.padding.y.half
				- 4;
		end

		gfx.Restore();
	end,

	drawButton = function(self, x, y, a, enabled, action, clickAllowed)
		gfx.BeginPath();
		gfx.StrokeColor(60, 110, 160, math.floor(255 * a));

		if (enabled) then
			gfx.StrokeWidth(2);
			gfx.FillColor(255, 205, 0, math.floor(255 * a));
		else
			gfx.StrokeWidth(1);
			fill.dark(150 * a);
		end
		
		gfx.Rect(x, y, 24, 24);
		gfx.Fill();
		gfx.Stroke();

		if (clickAllowed and mouseClipped(x, y, 24, 24)) then
			hoveredButton = action;
		end
	end,

	drawCursor = function(self, deltaTime, y)
    gfx.Save();

    self.cursor.timer = self.cursor.timer + deltaTime;
    self.cursor.flickerTimer = self.cursor.flickerTimer + deltaTime;

    self.cursor.alpha = math.floor(self.cursor.flickerTimer * 30) % 2;
    self.cursor.alpha = (self.cursor.alpha * 255) / 255;

    if (self.cursor.flickerTimer >= 0.3) then
      self.cursor.alpha = math.abs(0.8 * math.cos(self.cursor.timer * 5)) + 0.2;
    end

    gfx.BeginPath();

		drawCursor({
			x = self.cursor.x + 10,
			y = y + 10,
			w = self.images.button.w - 20,
			h = self.images.button.h - 20,
			alpha = self.cursor.alpha,
			size = 12,
			stroke = 1.5,
		});

    gfx.Restore();
  end,

	drawDifficulty = function(self, y, currentDifficulty, isSelected)
		local x = self.cursor.x;
		local alpha = math.floor(255 * ((isSelected and 1) or 0.2));

		gfx.Save();

		if (isSelected) then
			self.images.buttonHover:draw({ x = x, y = y });
		else
			self.images.button:draw({
				x = x,
				y = y,
				a = 0.45,
			});
		end

		if (currentDifficulty) then
			gfx.BeginPath();

			align.left();
			self.difficulties[currentDifficulty.difficulty + 1]:draw({
				x = x + 36,
				y = y + (self.images.button.h / 2.85),
				a = alpha,
				color = 'white',
			});

			align.right();
			self.levels[currentDifficulty.level]:draw({
				x = x + self.images.button.w - 36,
				y = y + (self.images.button.h / 2.85),
				a = alpha,
				color = 'white',
			});
		end

		gfx.Restore();

		return (y + self.images.button.h + 6);
	end,

	drawJacket = function(self)
		if (not jacket) then
			jacket = jacketFallback;
		end

		if ((not selected_song.jacket) or (selected_song.jacket == jacketFallback)) then
			jacket = gfx.LoadImageJob(
				selected_song.jacketPath,
				jacketFallback,
				self.jacketSize,
				self.jacketSize
			);
		end

		gfx.Save();

		gfx.BeginPath();
		gfx.StrokeWidth(2);
		gfx.StrokeColor(60, 110, 160, 255);
		gfx.ImageRect(
			self.padding.x.double,
			self.padding.y.full,
			self.jacketSize,
			self.jacketSize,
			jacket,
			1,
			0
		);
		gfx.Stroke();

		gfx.Restore();
	end,

	drawSongInfo = function(self, deltaTime)
		local baseHeight = self.labels.title.h;
		local y = self.labels.y + baseHeight + self.padding.y.quarter - 8;

		font.jp();

		self.songInfo.artist:update({ new = string.upper(selected_song.artist) });
		self.songInfo.effector:update({ new = string.upper(selected_song.effector)} );
		self.songInfo.title:update({ new = string.upper(selected_song.title) });

		font.number();

		self.songInfo.bpm:update({ new = selected_song.bpm });

		gfx.Save();

		gfx.BeginPath();
		align.left();

		for _, name in pairs(self.order) do
			local doesOverflow = self.songInfo[name].w > self.panel.innerWidth;

			if (doesOverflow and self.scrollTimers[name]) then
				self.scrollTimers[name] = self.scrollTimers[name] + deltaTime;

				drawScrollingLabel(
					self.scrollTimers[name],
					self.songInfo[name],
					self.panel.innerWidth,
					self.labels.x,
					y,
					scalingFactor,
					'white',
					255
				);
			else
				self.songInfo[name]:draw({
					x = self.labels.x,
					y = y - 1,
					color = 'white',
				});
			end

			y = y
				+ self.songInfo[name].h
				+ self.padding.y.half
				+ baseHeight
				+ self.padding.y.quarter
				- 4;
		end

		gfx.Restore();
	end,

	drawSongInfoPanel = function(self, deltaTime)
		gfx.Save();

		gfx.Translate(self.panel.x, self.panel.y);

		self.images.panel:draw({
			x = 0,
			y = 0,
			a = 0.65,
		});

		self:drawLabels();

		if (selected_song) then
			self:drawJacket();

			self:drawSongInfo(deltaTime);

			self:setDifficulty(selected_song.difficulty);

			local y = self.padding.y.double + self.labels.difficulty.h - 24;

			for i = 1, 4 do
				local isSelected = (i - 1) == selected_song.difficulty;
				local current = self:getDifficulty(selected_song.all_difficulties, i);

				if (isSelected) then
					self.cursor.selected = i;
				end

				if (not self.cursor.y[i]) then
					self.cursor.y[i] = y;
				end

				y = self:drawDifficulty(y, current, isSelected);
			end

			self:drawCursor(deltaTime, self.cursor.y[self.cursor.selected]);
		end

		gfx.Restore();
	end,

	drawToggles = function(self)
		local x = (scaledW / 10) + self.panel.w;
		local y = scaledH - (scaledH / 20) + (self.labels.hardGauge.h - 4);

		gfx.Save();

		gfx.BeginPath();
		align.left();

		self:drawButton(x, y + 1, 1, hardGauge, toggleHard, not isStartingGame);

		self.labels.hardGauge:draw({
			x = x + 32,
			y = y,
			color = 'white',
		});

		x = x + 32 + self.labels.hardGauge.w + self.toggles.spacing;

		self:drawButton(x, y + 1, 1, mirrorMode, toggleMirror, not isStartingGame);

		self.labels.mirrorMode:draw({
			x = x + 32,
			y = y,
			color = 'white',
		});


		x = x + 32 + self.labels.rotateHost.w + self.toggles.spacing;

		self:drawButton(
			x,
			y + 1,
			((host == userId) and 1) or 0.2,
			rotateHost,
			toggleRotate,
			(host == userId) and (not isStartingGame)
		);

		self.labels.rotateHost:draw({
			x = x + 32,
			y = y,
			a = ((host == userId) and 255) or 50,
			color = 'white',
		});

		gfx.Restore();
	end,

	render = function(self, deltaTime)
		self:setLabels();

		self:setSizes();

		gfx.Save();

		self:drawSongInfoPanel(deltaTime);

		self:drawToggles();

		gfx.Restore();
	end
};

local lobby = {
	cache = { scaledW = 0, scaledH = 0 },
	images = {
		buttonM = cacheImage('buttons/medium.png'),
		buttonMHover = cacheImage('buttons/medium_hover.png'),
		buttonN = cacheImage('buttons/normal.png'),
		buttonNHover = cacheImage('buttons/normal_hover.png'),
	},
	button = {
		spacing = 0,
		x = 0,
		y = {},
	},
	order = {
		'player',
		'level',
		'grade',
		'clear',
		'score',
	},
	timer = 0,
	user = {
		spacing = {
			inner = 0,
			outer = 0,
		},
		w = 0,
		h = 0,
		x = {},
	},
	userCount = 0,
	userInfo = {},
	x = 0,
	y = 0,

	setSizes = function(self)
		if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
			self.x = (scaledW / 10) + songInfo.panel.w;
			self.y = scaledH / 20;

			local maxWidth = scaledW - ((scaledW / 20) * 3) - songInfo.panel.w;
			local maxHeight = scaledH - (scaledH / 10);

			self.user.w = maxWidth;
			self.user.h = scaledH / 10;
			self.user.spacing.inner = maxWidth / 20;
			self.user.spacing.outer = (maxHeight - (self.user.h * 8)) / 7;

			local spacing = maxWidth / 12;

			self.user.x[1] = self.x + 24;
			self.user.x[2] = self.x + spacing * 4;
			self.user.x[3] = self.x + spacing * 5.25
			self.user.x[4] = self.x + spacing * 7;
			self.user.x[5] = self.x + spacing * 9.375;
			

			self.button.x = (scaledW / 20) + songInfo.padding.x.double - 10;
			self.button.y[1] = scaledH
				- (scaledH / 20)
				- (songInfo.padding.y.double * 1.75)
				- 10;
			self.button.y[2] = self.button.y[1] + self.images.buttonM.h;
			
      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
	end,

	setLabels = function(self)
		if (not self.labels) then
			self.labels = {};

			font.medium();

			for name, label in pairs(CONSTANTS_MULTI.buttons) do
				self.labels[name] = cacheLabel(label, 18);
			end

			for name, label in pairs(CONSTANTS_MULTI.user) do
				self.labels[name] = cacheLabel(label, 18);
			end
		end
	end,

	setUserInfo = function(self)
		if (#allUsers ~= self.userCount) then
			for i = 1, #allUsers do
				font.normal();

				self.userInfo[i] = {
					clear = cacheLabel('', 30),
					grade = cacheLabel('', 30),
					player = cacheLabel('', 30),
				};

				font.number();

				self.userInfo[i].level = cacheLabel('0', 30);
				self.userInfo[i].score = number.create({
					isScore = true,
					sizes = { 30, 26 },
				});
			end

			self.userCount = #allUsers;
		end
	end,

	updateLabels = function(self, i, currentUser)
		font.normal();

		self.userInfo[i].player:update({ new = string.upper(currentUser.name) });
		
		if (currentUser.level ~= 0) then
			font.number();
	
			self.userInfo[i].level:update({ new = currentUser.level });
		end

		if (currentUser.score) then
			font.normal();

			self.userInfo[i].clear:update({
				new = CONSTANTS_SONGWHEEL.clears[currentUser.clear]
			});

			self.userInfo[i].grade:update({ new = getGrade(currentUser.score) });

			self.userInfo[i].score:setInfo({ value = currentUser.score });
		end
	end,

	drawButtons = function(self)
		local action;
		local allowAction = true;
		local isHoveringMain = mouseClipped(
			self.button.x,
			self.button.y[1],
			self.images.buttonM.w,
			self.images.buttonM.h
		);
		local isHoveringSettings = mouseClipped(
			self.button.x,
			self.button.y[2],
			self.images.buttonM.w,
			self.images.buttonM.h
		);
		local label;

		if (isStartingGame) then
			label = 'startingGame';

			return;
		else
			if (host == userId) then
				if ((not selected_song) or (not selected_song.self_picked)) then
					action = function()
						isMissingSong = false;

						mpScreen.SelectSong();
					end

					label = 'selectSong';
				elseif (userReady and allReady) then
					action = startGame;
					label = 'startGame';
				elseif (userReady and (not allReady)) then
					action = function()
						isMissingSong = false;

						mpScreen.SelectSong();
					end

					label = 'playersNotReady';
				else
					action = readyUp;
					label = 'readyUp';
				end
			elseif (host == nil) then
				action = function() end
				allowAction = false;
				label = 'gameInProgress';
			elseif (isMissingSong) then
				action = function() end
				allowAction = false;
				label = 'songMissing';
			elseif (selected_song) then
				if (userReady) then
					action = readyUp;
					label = 'cancel';
				else
					action = readyUp;
					label = 'readyUp';
				end
			else
				action = function() end
				allowAction = false;
				label = 'hostSelecting';
			end
		end

		gfx.Save();

		if (allowAction and isHoveringMain) then
			hoveredButton = action;

			self.images.buttonMHover:draw({ x = self.button.x, y = self.button.y[1] });
		else
			self.images.buttonM:draw({
				x = self.button.x,
				y = self.button.y[1],
				a = 0.75,
			});
		end

		gfx.BeginPath();
		align.left();

		self.labels[label]:draw({
			x = self.button.x + 44,
			y = self.button.y[1] + 25,
			a = ((allowAction and isHoveringMain) and 255) or 150,
			color = 'white',
		});

		if (isHoveringSettings) then
			hoveredButton = mpScreen.OpenSettings;

			self.images.buttonMHover:draw({
				x = self.button.x,
				y = self.button.y[2],
			});
		else
			self.images.buttonM:draw({
				x = self.button.x,
				y = self.button.y[2],
				a = 0.75,
			});
		end

		self.labels.settings:draw({
			x = self.button.x + 44,
			y = self.button.y[2] + 25,
			a = (isHoveringSettings and 255) or 150,
			color = 'white',
		});

		gfx.Restore();
	end,

	drawHostControls = function(self, initialY, currentUser)
		local x1 = self.x + (self.user.w / 2) - (self.images.buttonN.w) - 32;
		local x2 = self.x + (self.user.w / 2) + 32;
		local y = initialY + (self.user.h / 2) - (self.images.buttonN.h / 2);
		local isHoveringHost = mouseClipped(
			x1,
			y,
			self.images.buttonN.w,
			self.images.buttonN.h
		);
		local isHoveringKick = mouseClipped(
			x2,
			y,
			self.images.buttonN.w,
			self.images.buttonN.h
		);

		gfx.BeginPath();
		fill.dark(120);
		gfx.Rect(self.x, initialY, self.user.w, self.user.h);
		gfx.Fill();

		if (isHoveringHost) then
			hoveredButton = function()
				changeHost(currentUser);
			end
		
			self.images.buttonNHover:draw({ x = x1, y = y });
		else
			self.images.buttonN:draw({
				x = x1,
				y = y,
				a = 0.75,
			});
		end

		self.labels.makeHost:draw({
			x = x1 + 40,
			y = y + 25,
			a = (isHoveringHost and 255) or 150,
			color = 'white',
		});

		if (isHoveringKick) then
			hoveredButton = function()
				kickUser(currentUser);
			end
		
			self.images.buttonNHover:draw({ x = x2, y = y });
		else
			self.images.buttonN:draw({
				x = x2,
				y = y,
				a = 0.75,
			});
		end

		self.labels.kickUser:draw({
			x = x2 + 40,
			y = y + 25,
			a = (isHoveringKick and 255) or 150,
			color = 'white',
		});
	end,

	drawUser = function(self, initialY, userIndex, currentUser)
		local isHost = (host == userId) and (currentUser.id ~= userId);
		local isHoveringUser = mouseClipped(self.x, initialY, self.user.w, self.user.h);

		if (isHost and isHoveringUser) then
			self:drawHostControls(initialY, currentUser);
		else
			local y = initialY + (self.user.h / 5);
			local infoY = y + (self.labels.notReady.h * 1.25);
			local nameLabel = 'notReady';

			if (host == currentUser.id) then
				nameLabel = 'host';
			elseif (currentUser.missing_map) then
				nameLabel = 'missingSong';
			elseif (currentUser.ready) then
				nameLabel = 'ready';
			else
				nameLabel = 'notReady';
			end

			self:updateLabels(userIndex, currentUser);

			gfx.Save();

			gfx.BeginPath();
		
			if (currentUser.missing_map) then
				gfx.FillColor(48, 8, 8, 120);
			elseif (currentUser.ready) then
				gfx.FillColor(16, 48, 24, 120);
			else
				fill.dark(120);
			end

			gfx.Rect(self.x, initialY, self.user.w, self.user.h);
			gfx.Fill();

			gfx.BeginPath();
			align.left();

			self.labels[nameLabel]:draw({
				x = self.user.x[1],
				y = y,
				color = 'normal',
			});

			self.userInfo[userIndex].player:draw({
				x = self.user.x[1],
				y = infoY,
				color = 'white'
			});

			if (get(currentUser, 'level') ~= 0) then
				self.labels.level:draw({
					x = self.user.x[2],
					y = y,
					color = 'normal',
				});

				self.userInfo[userIndex].level:draw({
					x = self.user.x[2],
					y = infoY,
					color = 'white'
				});
			end

			if (currentUser.score) then
				for i = 3, 5 do
					local label = self.order[i];

					self.labels[label]:draw({
						x = self.user.x[i],
						y = y,
						color = 'normal',
					});

					if (i == 5) then
						self.userInfo[userIndex].score:draw({
							offset = 2,
							x = self.user.x[i],
							y1 = infoY,
							y2 = infoY + 4,
						});
					else
						self.userInfo[userIndex][label]:draw({
							x = self.user.x[i],
							y = infoY,
							color = 'white',
						});
					end
				end
			end

			gfx.Restore();
		end

		return self.user.h + self.user.spacing.outer;
	end,

	render = function(self, deltaTime)
		self:setLabels();

		local y = self.y;

		gfx.Save();

		songInfo:render(deltaTime, self.timer);

		self:setSizes();

		if (#allUsers > 0) then
			self:setUserInfo();

			for i, user in ipairs(allUsers) do
				y = y + self:drawUser(y, i, user);
			end
		end

		self:drawButtons();

		gfx.Restore();
	end,
};


handleTimers = function(deltaTime)
	if (screenState == 'setUsername') then
		usernameCreation.timer = math.min(usernameCreation.timer + (deltaTime * 8), 1);
	else
		usernameCreation.timer = 0;
	end

	if (screenState == 'newRoomName') then
		roomCreation.timer = math.min(roomCreation.timer + (deltaTime * 8), 1);
	elseif ((screenState ~= 'newRoomName') and (roomCreation.timer > 0)) then
		roomCreation.timer = math.max(roomCreation.timer - (deltaTime * 6), 0);
	end

	if ((screenState == 'newRoomPassword') and (roomCreation.timer == 0)) then
		passwordCreation.timer = math.min(passwordCreation.timer + (deltaTime * 8), 1);

		previousWindow = 'newRoomPassword'
	elseif ((screenState ~= 'newRoomPassword') and (passwordCreation.timer > 0)) then
		passwordCreation.timer = math.max(passwordCreation.timer - (deltaTime * 6), 0);
	end

	if (screenState == 'passwordScreen') then
		passwordRequired.timer = math.min(passwordRequired.timer + (deltaTime * 8), 1);

		previousWindow = 'passwordScreen';
	elseif ((screenState ~= 'passwordScreen') and (passwordRequired.timer > 0)) then
		passwordRequired.timer = math.max(passwordRequired.timer - (deltaTime * 6), 0);
	end
end

render = function(deltaTime)
	gfx.Save();

	setupLayout();

	mousePosX, mousePosY = game.GetMousePos();

	hoveredButton = nil;

	playSounds(deltaTime);

	background:draw({
		x = 0,
		y = 0,
		w = scaledW,
		h = scaledH,
	});

	if (screenState == 'setUsername') then
		isLoading = false;

		usernameCreation:render(deltaTime, scaledW, scaledH);
	elseif (screenState ~= 'inRoom') then
		roomList:render(deltaTime);
	elseif (screenState == 'inRoom') then
		lobby:render(deltaTime);
	end

	roomCreation:render(deltaTime, scaledW, scaledH);
	passwordCreation:render(deltaTime, scaledW, scaledH);
	passwordRequired:render(deltaTime, scaledW, scaledH);

	handleTimers(deltaTime);

	gfx.Restore();
end

local soundDuration = 0;
local soundClip = nil;
local soundsRemaining = 0;
local soundInterval = 0;

function repeatSound(clip, times, interval)
	soundClip = clip;
	soundDuration = 0;
	soundsRemaining = times - 1;
	soundInterval = interval;

	game.PlaySample(clip);
end

function playSounds(deltaTime)
	if (not soundClip) then return end

	soundDuration = soundDuration + deltaTime;

	if soundDuration > soundInterval then
		soundDuration = soundDuration - soundInterval;

		game.PlaySample(soundClip);

		soundsRemaining = soundsRemaining - 1;
		
		if (soundsRemaining <= 0) then
			soundClip = nil;
		end
	end
end

changeHost = function(user)
  Tcp.SendLine(json.encode({ topic = 'room.host.set', host = user.id }));
end

createRoom = function()
	host = userId;
	owner = userId;

	mpScreen.NewRoomStep();
end

joinRoom = function(room)
	host = userId;
	selectedRoom = room;

	if (room.password) then
		mpScreen.JoinWithPassword(room.id);
	else
		mpScreen.JoinWithoutPassword(room.id);
	end
end

kickUser = function(user)
  Tcp.SendLine(json.encode({topic = 'room.kick', id = user.id }));
end

readyUp = function()
  Tcp.SendLine(json.encode({ topic = 'user.ready.toggle' }));
end

startGame = function()
	selected_song.self_picked = false;

	if (not selected_song) then return end

	if (isStartingGame) then return end
	
	Tcp.SendLine(json.encode({ topic = 'room.game.start' }));
end

toggleHard = function()
  Tcp.SendLine(json.encode({ topic = 'user.hard.toggle' }));
end

toggleMirror = function()
  Tcp.SendLine(json.encode({ topic = 'user.mirror.toggle' }));
end

toggleRotate = function()
  Tcp.SendLine(json.encode({ topic = 'room.option.rotation.toggle' }));
end

button_pressed = function(button)
	if (button == game.BUTTON_STA) then
		if (isStartingGame) then return end

		if (screenState == 'setUsername') then
			isLoading = true;

			mpScreen.SaveUsername();
		elseif (screenState == 'roomList') then
			if (#allRooms == 0) then
				createRoom();
			else
				joinRoom(allRooms[selectedRoomIndex]);
			end
		elseif (screenState == 'inRoom') then
			if (host == userId) then
				if (selected_song and selected_song.self_picked) then
					if (allReady) then
						startGame();
					else
						isMissingSong = false;
						
						mpScreen.SelectSong();
					end
				else
					isMissingSong = false;
					
					mpScreen.SelectSong();
				end
			else
				readyUp();
			end
		end
	end
	
	if ((button == game.BUTTON_FXL) and allowHardToggle) then
		toggleHard();
	end

	if ((button == game.BUTTON_FXR) and allowMirrorToggle) then
		toggleMirror();
	end
end

key_pressed = function(key)
	if (key == 27) then
		if (screenState == 'roomList') then
			didExit = true;

			mpScreen.Exit();

			return;
		end

		allRooms = {};
		screenState = 'roomList';
		selectedRoom = nil;
		jacket = nil;
	end
end

mouse_pressed = function(button)
	if (hoveredButton) then
		hoveredButton();
	end

	return 0;
end

init_tcp = function()
	Tcp.SetTopicHandler('server.info',
		function(data)
			isLoading = false;
			userId = data.userid;
		end
	);

	Tcp.SetTopicHandler('server.rooms',
		function(data)
			allRooms = {};

			if (#get(data, 'rooms', {}) > 0) then
				for i, room in ipairs(data.rooms) do
					allRooms[i] = room;
				end
			end
		end
	);

	Tcp.SetTopicHandler('server.room.joined',
		function(data)
			selectedRoom = data.room;
		end
	);

	Tcp.SetTopicHandler('room.update',
		function(data)
			allUsers = {};

			local previousAllReady = allReady;

			allReady = true;
			
			if (#get(data, 'users', {}) >= 0) then
				for i, user in ipairs(data.users) do
					allUsers[i] = user;

					if (user.id == userId) then
						userReady = user.ready;
					end

					if (not user.ready) then
						allReady = false;
					end
				end
			end

			if ((userId == host)
				and (#data.users > 1)
				and allReady
				and (not previousAllReady)
			) then
				repeatSound('click-02', 3, .1);
			end

			if ((data.host == userId) and (host ~= userId)) then
				repeatSound('click-02', 3, .1);
			end

			if ((data.song ~= nil) and (previousSong ~= data.song)) then
				game.PlaySample('menu_click');
				previousSong = data.song;
			end

			host = data.host;

			if (data.owner) then
				owner = data.owner;
			else
				owner = host;
			end

			rotateHost = data.do_rotate;
			hardGauge = data.hard_mode;
			mirrorMode = data.mirror_mode;
			
			if ((data.start_soon) and (not isStartingGame)) then
				repeatSound('click-01', 5, 1);
			end

			isStartingGame = data.start_soon;
		end
	);
end
