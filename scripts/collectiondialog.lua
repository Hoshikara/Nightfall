local Cursor = require('components/common/cursor');
local DialogBox = require('components/common/dialogbox');
local Scrollbar = require('components/common/scrollbar');

local min = math.min;

local window = Window:new();

local dialogBox = DialogBox:new();

local artist = nil;
local title = nil;

local options = {};
local currOpt = 1;

---@class CollectionDialogWindow
local dialogWindow = {
	button = {
		margin = 36,
		maxWidth = 0,
		offset = 0,
		x = 0,
		y = 0,
		h = 0,
	},
	cache = { w = 0, h = 0 },
	currOpt = 1,
	cursor = Cursor:new({
		size = 12,
		stroke = 1.5,
		type = 'vertical',
	}),
	cursorIndex = 1,
	input = {
		alpha = 0,
		maxWidth = 0,
		offset = 0,
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	},
	forceFlicker = false,
	labels = {
		artist = makeLabel('med', 'ARTIST'),
		collectionName = makeLabel('med', 'COLLECTION NAME'),
		confirm = makeLabel('med', 'CONFIRM'),
		enter = makeLabel('med', '[ENTER]'),
		input = makeLabel('jp', '', 28),
		title = makeLabel('med', 'TITLE'),
	},
	max = 2,
	scrollbar = Scrollbar:new(),
	timers = {
		artist = 0,
		button = 0,
		cursor = 0,
		fade = 0,
		title = 0,
	},

	-- Sets the sizes for the current component
	---@param this CollectionDialogWindow
	setSizes = function(this)
		if ((this.cache.w ~= window.w) or (this.cache.h ~= window.h)) then
			dialogBox:setSizes(window.w, window.h, window.isPortrait);

			this.button.maxWidth = dialogBox.button.w - 48;
			this.button.x = dialogBox.x.middleRight - dialogBox.button.w + 36;
			this.button.y = dialogBox.y.center + 12;
			this.button.h = dialogBox.button.h;

			this.input.x = dialogBox.x.middleLeft + 24;
			this.input.y = dialogBox.y.center + (dialogBox.h.outer / 10);
			this.input.w = dialogBox.w.middle;
			this.input.h = dialogBox.h.outer / 6;
			this.input.maxWidth = this.input.w - 20;

			this.cursor:setSizes({
				x = this.button.x,
				y = this.button.y,
				w = dialogBox.button.w,
				h = this.button.h,
				margin = this.button.margin,
			});

			this.scrollbar:setSizes({
				x = this.button.x + dialogBox.button.w + 24,
				y = this.button.y,
				h = (this.button.h * 2) + this.button.margin,
			});

			this.cache.w = window.w;
			this.cache.h = window.h;
		end
	end,

	-- Draw the song title and artist
	---@param this CollectionDialogWindow
	---@param dt deltaTime
	drawSongInfo = function(this, dt)
		local alpha = 255 * this.timers.fade;
		local maxWidth = dialogBox.maxWidth;
		local x = dialogBox.x.outerLeft;
		local y = dialogBox.y.top - 12;

		gfx.Save();

		window:unscale();

		this.labels.title:draw({
			x = x,
			y = y,
			alpha = alpha,			
		});

		y = y + (this.labels.title.h * 1.35);

		if (title.w > maxWidth) then
			this.timers.title = this.timers.title + dt;

			title:drawScrolling({
				x = x,
				y = y,
				alpha = alpha,
				color = 'white',
				scale = window:getScale(),
				timer = this.timers.title,
				width = maxWidth,
			});
		else
			title:draw({
				x = x,
				y = y,
				alpha = alpha,
				color = 'white',
			});
		end

		y = y + (title.h * 1.5);

		this.labels.artist:draw({
			x = x,
			y = y,
			alpha = alpha,
		});

		y = y + (this.labels.artist.h * 1.35);

		if (artist.w > maxWidth) then
			this.timers.artist = this.timers.artist + dt;

			artist:drawScrolling({
				x = x,
				y = y,
				alpha = alpha,
				color = 'white',
				scale = window:getScale(),
				timer = this.timers.artist,
				width = maxWidth,
			});
		else
			artist:draw({
				x = x,
				y = y,
				alpha = alpha,
				color = 'white',
			});
		end

		gfx.Restore();
	end,

	-- Draw the window buttons
	---@param this CollectionDialogWindow
	---@param dt deltaTime
	drawButtons = function(this, dt)
		local y = this.button.y + this.button.offset;

		for i, option in ipairs(options) do
			local isVis = true;

			if (currOpt > this.max) then
				if ((i <= (currOpt - this.max)) or (i > currOpt)) then
					isVis = false;
				end
			else
				isVis = (i <= this.max);
			end

			y = y + this:drawButton(
				dt,
				option.label,
				y,
				i == currOpt, isVis
			);
		end
	end,

	-- Draw a single button
	---@param this CollectionDialogWindow
	---@param dt deltaTime
	---@param label Label
	---@param y number
	---@param isCurr boolean
	---@param isVis boolean
	drawButton = function(this, dt, label, y, isCurr, isVis)
		local alpha = ((isCurr and 255) or 50) * this.timers.fade;
		local x = this.button.x;

		if (isVis) then
			dialogBox.button:render({
				x = x,
				y = y,
				accentAlpha = ((isCurr and 1) or 0.3) * this.timers.fade,
				alpha = this.timers.fade,
				color = 'med',
			});

			window:unscale();

			if (label.w > this.button.maxWidth) then
				if (isCurr) then
					this.timers.button = this.timers.button + dt;
				else
					this.timers.button = 0;
				end

				label:drawScrolling({
					x = x + 24,
					y = y + (this.button.h * 0.5) - 12,
					alpha = alpha,
					color = 'white',
					scale = window:getScale(),
					timer = this.timers.button,
					width = this.button.maxWidth,
				});
			else
				label:draw({
					x = x + 24,
					y = y + (this.button.h * 0.5) - 12,
					alpha = alpha,
					color = 'white',
				});
			end

			window:scale();
		end

		return this.button.h + this.button.margin;
	end,

	-- Draw the text input field
	---@param this CollectionDialogWindow
	---@param dt deltaTime
	drawInput = function(this, dt)
		this.timers.cursor = this.timers.cursor + dt;
		this.input.alpha = this.timers.fade * pulse(this.timers.cursor, 1, 0.2);

		local alpha = 255 * this.timers.fade;
		local x = this.input.x;
		local y = this.input.y + (this.labels.collectionName.h * 2);

		this.input.offset = min(this.labels.input.w + 2, this.input.maxWidth);

		drawRect({
			x = x,
			y = y,
			w = this.input.w,
			h = this.input.h,
			alpha = alpha,
			color = 'dark',
			stroke = {
				alpha = alpha,
				color = 'norm',
				size = 1,
			},
		});

		drawRect({
			x = x + 8 + this.input.offset,
			y = y + 10,
			w = 2,
			h = this.input.h - 20,
			alpha = 255 * this.input.alpha,
			color = 'white',
		});

		gfx.Save();

		window:unscale();

		this.labels.collectionName:draw({
			x = x - 2,
			y = y - (this.labels.collectionName.h * 2),
			alpha = alpha,
		});

		this.labels.input:draw({
			x = x + 8,
			y = y + 8,
			alpha = alpha,
			color = 'white',
			maxWidth = this.input.maxWidth - 2,
			text = dialog.newName:upper(),
			update = true,
		});

		y = y + this.input.h;

		this.labels.confirm:draw({
			x = x + this.input.w + 2,
			y = y + 12,
			align = 'right',
			alpha = alpha,
			color = 'white',
		});

		this.labels.enter:draw({
			x = x + this.input.w + 2 - this.labels.confirm.w - 8,
			y = y + 12,
			align = 'right',
			alpha = alpha,
		});

		gfx.Restore();
	end,

	-- Handle user input
	---@param this CollectionDialogWindow
	---@param dt deltaTime
	handleChange = function(this, dt)
		if (dialog.closing) then
			this.timers.artist = 0;
			this.timers.fade = to0(this.timers.fade, dt, 0.16);
			this.timers.title = 0;
		else
			this.timers.fade = to1(this.timers.fade, dt, 0.125);
		end

		this.forceFlicker = this.currOpt ~= currOpt;

		this.currOpt = currOpt;

		local delta = currOpt - this.max;

		if (delta >= 1) then
			this.button.offset = -(delta * (this.button.h + this.button.margin));
			this.cursorIndex = this.max;
		else
			this.button.offset = 0;
			this.cursorIndex = currOpt;
		end
	end,

	-- Renders the current component
	---@param this CollectionDialogWindow
	---@param dt deltaTime
	render = function(this, dt)
		this:setSizes();

		this:handleChange(dt);

		dialogBox:render({
			x = window.w / 2,
			y = window.h / 2,
			alpha = this.timers.fade,
		});

		this:drawSongInfo(dt);

		if (dialog.isTextEntry) then
			this:drawInput(dt);
		else
			this:drawButtons(dt);

			this.cursor:render(dt, {
				alphaMod = this.timers.fade,
				curr = this.cursorIndex,
				forceFlicker = this.forceFlicker,
				total = this.max,
			});

			gfx.Save();

			window:unscale();

			this.scrollbar:render(dt, {
				alphaMod = this.timers.fade,
				color = 'med',
				curr = currOpt,
				total = #options,
			});

			gfx.Restore();
		end
	end,
};

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
	game.SetSkinSetting(
		'_collections',
		((not dialog.closing) and 'TRUE') or 'FALSE'
	);

	gfx.Save();

	window:set();

	dialogWindow:render(dt);

	gfx.Restore();

	return not (dialog.closing and (dialogWindow.timers.fade <= 0));
end

-- Collection factory helper
---@param name string
makeCollection = function(name)
	return function()
		menu.Confirm(name);
	end
end

-- Called by the game when the collection dialog is opened
open = function()
	currOpt = 1;
	options = {};

	if (#dialog.collections == 0) then
		options[1] = {
			event = makeCollection('FAVOURITES'),
			label = makeLabel('med', 'ADD TO FAVOURITES'),
		};
	end

	for i, collection in ipairs(dialog.collections) do
		local name;

		if (collection.exists) then
			name = ('REMOVE FROM %s'):format(collection.name:upper());
		else
			name = ('ADD TO %s'):format(collection.name:upper());
		end

		options[i] = {
			event = makeCollection(collection.name),
			label = makeLabel('med', name),
		};
	end

	options[#options + 1] = {
		event = menu.ChangeState,
		label = makeLabel('med', 'CREATE COLLECTION'),
	};
	options[#options + 1] = {
		event = menu.Cancel,
		label = makeLabel('med', 'CLOSE'),
	};

	artist = makeLabel('jp', dialog.artist, 28);
	title = makeLabel('jp', dialog.title, 36);
end

-- Called by the game when knobs are turned or arrow keys are pressed
---@param step integer # `-1` or `1`
advance_selection = function(step)
	currOpt = advance(currOpt, #options, step);
end

-- Called by the game when a (gamepad) button is pressed
---@param btn integer
button_pressed = function(btn)
	if (btn == game.BUTTON_BCK) then
		menu.Cancel();
	elseif (btn == game.BUTTON_STA) then
		options[currOpt].event();
	end
end