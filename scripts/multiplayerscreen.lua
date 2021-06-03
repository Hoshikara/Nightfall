local Constants = require('constants/multiplayerscreen');

local JSON = require('lib/json');

local Knobs = require('common/knobs');
local Mouse = require('common/mouse');

local DialogWindow = require('components/multiplayer/dialogwindow');
local Lobby = require('components/multiplayer/lobby');
local Rooms = require('components/multiplayer/rooms');
local Sounds = require('components/multiplayer/sounds');

local window = Window:new();
local mouse = Mouse:new(window);

local bg = Image:new('bg.png');
local bgPortrait = Image:new('bg_p.png');

---@class Multiplayer
local state = {
	btnEvent = nil,
	currRoom = 1,
	exited = false,
	loading = false,
	lobby = {
		hard = false,
		host = nil,
		jacket = nil,
		mirror = false,
		missingSong = false,
		owner = nil,
		prevSong = nil,
		ready = false,
		rotate = false,
		starting = false,
		userCount = 0,
		users = {},
	},
	roomCount = 0,
	roomList = {},
	user = {
		id = 0,
		name = '',
		ready = false,
	},

	joinRoom = function(this)
		local room = this.roomList[this.currRoom];

		if (room) then
			this.lobby.host = this.user.id;

			if (room.password) then
				mpScreen.JoinWithPassword(room.id);
			else
				mpScreen.JoinWithoutPassword(room.id);
			end
		else
			this:makeRoom();
		end
	end,

	makeRoom = function(this)
		this.lobby.host = this.user.id;
		this.lobby.owner = this.user.id;

		mpScreen.NewRoomStep();
	end,

	readyUp = function(this)
		Tcp.SendLine(JSON.encode({ topic = 'user.ready.toggle' }));
	end,

	selectSong = function(this)
		this.lobby.missingSong = false;

		mpScreen.SelectSong();
	end,

	startGame = function(this)
		selected_song.self_picked = false;

		if (not selected_song) then return; end

		if (this.lobby.starting) then return; end

		Tcp.SendLine(JSON.encode({ topic = 'room.game.start' }));
	end,

	toggleHard = function(this)
		Tcp.SendLine(JSON.encode({ topic = 'user.hard.toggle' }));
	end,

	toggleMirror = function(this)
		Tcp.SendLine(JSON.encode({ topic = 'user.mirror.toggle' }));
	end,

	watch = function(this)
		this.roomCount = #this.roomList;
		this.lobby.userCount = #this.lobby.users;
	end,
};

-- Multiplayer components
local enterPass = DialogWindow:new(window, Constants.dialog.enterPass);
local knobs = Knobs:new(state);
local lobby = Lobby:new(window, mouse, state, Constants.lobby);
local makePass = DialogWindow:new(window, Constants.dialog.makePass);
local makeRoom = DialogWindow:new(window, Constants.dialog.makeRoom);
local makeUsername = DialogWindow:new(window, Constants.dialog.makeUsername);
local rooms = Rooms:new(window, mouse, state);
local sounds = Sounds:new();

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
	mouse:watch();

	state:watch();

	gfx.Save();

	window:set();

	state.btnEvent = nil;

	if (window.isPortrait) then
		bgPortrait:draw({ w = window.w, h = window.h });
	else
		bg:draw({ w = window.w, h = window.h });
	end

	if (screenState == 'setUsername') then
		state.loading = false;

		makeUsername:render(dt, screenState);
	elseif (screenState ~= 'inRoom') then
		if (state.roomCount > 0) then
			knobs:handleChange('roomCount', 'currRoom');
		end

		rooms:render(dt, screenState == 'roomList');
	else
		lobby:render(dt);
	end

	enterPass:render(dt, screenState);
	makePass:render(dt, screenState);
	makeRoom:render(dt, screenState);

	gfx.Restore();

	sounds:play(dt);
end

button_released = function(btn)
	if (btn == game.BUTTON_STA) then
		if (state.lobby.starting) then return; end

		if (screenState == 'roomList') then
			if (state.roomCount == 0) then
				state:makeRoom();
			else
				state:joinRoom();
			end
		elseif (screenState == 'inRoom') then
			local lobby = state.lobby;

			if (lobby.host == state.user.id) then
				if (selected_song and selected_song.self_picked) then
					if (lobby.ready) then
						state:startGame();
					else
						lobby.missingSong = false;

						mpScreen.SelectSong();
					end
				else
					lobby.missingSong = false;

					mpScreen.SelectSong();
				end
			else
				state:readyUp();
			end
		end
	end

	if (btn == game.BUTTON_BCK) then
		if (screenState == 'roomList') then
			state.exited = true;

			mpScreen.Exit();

			return;
		end

		screenState = 'roomList';
		selected_song = nil;

		state.currRoom = 1;
		state.roomList = {};

		state.lobby.jacket = nil;
	end
end

key_pressed = function(key) end

mouse_pressed = function(btn)
	if (state.btnEvent) then state:btnEvent(); end

	return 0;
end

init_tcp = function()
	Tcp.SetTopicHandler('server.info',
		function(data)
			state.loading = false;
			state.user.id = data.userid;
		end
	);

	Tcp.SetTopicHandler('server.rooms',
		function(data)
			state.roomList = {};

			if (#data.rooms > 0) then
				for i, room in ipairs(data.rooms) do state.roomList[i] = room; end
			end
		end
	);

	Tcp.SetTopicHandler('room.update',
		function(data)
			local lobby = state.lobby;
			local ready = lobby.ready;
			local user = state.user;

			lobby.users = {};
			lobby.ready = true;
			
			if (#data.users > 0) then
				for i, u in ipairs(data.users) do
					lobby.users[i] = u;

					if (u.id == user.id) then user.ready = u.ready; end

					if (not u.ready) then lobby.ready = false; end
				end
			end

			if ((user.id == lobby.host)
				and (#data.users > 1)
				and lobby.ready
				and (not ready)
			) then
				sounds:trigger(2, 3, 0.1);
			end

			if ((data.host == user.id) and (lobby.host ~= user.id)) then
				sounds:trigger(2, 3, 0.1);
			end

			if ((data.song ~= nil) and (data.song ~= lobby.prevSong)) then
				sounds:trigger(1);

				lobby.prevSong = data.song;
			end

			lobby.host = data.host;
			lobby.owner = data.owner or lobby.host;

			lobby.hard = data.hard_mode;
			lobby.mirror = data.mirror_mode;
			lobby.rotate = data.do_rotate;
			
			if ((data.start_soon) and (not lobby.starting)) then
				sounds:trigger(1, 5, 1);
			end

			lobby.starting = data.start_soon;
		end
	);
end
