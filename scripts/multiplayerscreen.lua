local Constants = require('constants/multiplayerscreen');

local JSON = require('lib/json');

local Knobs = require('common/knobs');
local Mouse = require('common/mouse');

local MpDialogWindow = require('components/multiplayer/mpdialogwindow');
local MpLobby = require('components/multiplayer/mplobby');
local MpRooms = require('components/multiplayer/mprooms');
local MpSounds = require('components/multiplayer/mpsounds');

local window = Window:new();
local background = Background:new(window);
local mouse = Mouse:new(window);

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

	---@param this Multiplayer
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

	---@param this Multiplayer
	makeRoom = function(this)
		this.lobby.host = this.user.id;
		this.lobby.owner = this.user.id;

		mpScreen.NewRoomStep();
	end,

	---@param this Multiplayer
	readyUp = function(this)
		Tcp.SendLine(JSON.encode({ topic = 'user.ready.toggle' }));
	end,

	---@param this Multiplayer
	selectSong = function(this)
		this.lobby.missingSong = false;

		mpScreen.SelectSong();
	end,

	---@param this Multiplayer
	startGame = function(this)
		selected_song.self_picked = false;

		if (not selected_song) then return; end

		if (this.lobby.starting) then return; end

		Tcp.SendLine(JSON.encode({ topic = 'room.game.start' }));
	end,

	---@param this Multiplayer
	toggleHard = function(this)
		Tcp.SendLine(JSON.encode({ topic = 'user.hard.toggle' }));
	end,

	---@param this Multiplayer
	toggleMirror = function(this)
		Tcp.SendLine(JSON.encode({ topic = 'user.mirror.toggle' }));
	end,
};

-- Multiplayer components
local enterPass = MpDialogWindow:new(window, Constants.dialog.enterPass);
local knobs = Knobs:new(state);
local makePass = MpDialogWindow:new(window, Constants.dialog.makePass);
local makeRoom = MpDialogWindow:new(window, Constants.dialog.makeRoom);
local makeUsername = MpDialogWindow:new(window, Constants.dialog.makeUsername);
local mpLobby = MpLobby:new(window, mouse, state, Constants.lobby);
local mpRooms = MpRooms:new(window, mouse, state);
local mpSounds = MpSounds:new();

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
	mouse:watch();

	window:set();

	state.btnEvent = nil;

	gfx.Save();

	background:render();

	if (screenState == 'setUsername') then
		state.loading = false;

		makeUsername:render(dt, screenState);
	elseif (screenState ~= 'inRoom') then
		if (state.roomCount > 0) then
			knobs:handleChange('roomCount', 'currRoom');
		end

		mpRooms:render(dt, screenState == 'roomList');

		-- TODO: this should not be needed
		if (selected_song) then
			selected_song = nil;
			mpLobby.panel.song = nil;
			state.lobby.jacket = nil;
		end
	else
		mpLobby:render(dt);
	end

	enterPass:render(dt, screenState);
	makePass:render(dt, screenState);
	makeRoom:render(dt, screenState);

	gfx.Restore();

	mpSounds:play(dt);
end

-- Called by the game when a (gamepad) button is pressed
---@param btn integer
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

-- Called by the game when a key is pressed
---@param key integer
key_pressed = function(key)
	if (state.roomCount > 0) then
		if (key == 1073741906) then -- up arrow
			state.currRoom = advance(state.currRoom, state.roomCount, -1);
		elseif (key == 1073741905) then -- down arrow
			state.currRoom = advance(state.currRoom, state.roomCount, 1);
		end
	end
end

-- Called by the game when the mouse is pressed
---@param btn integer
mouse_pressed = function(btn)
	if (state.btnEvent) then state:btnEvent(); end

	return 0;
end

-- Called by the game when multiplayer screen is entered
init_tcp = function()
	Tcp.SetTopicHandler('server.info',
		function(data)
			state.loading = false;
			state.user.id = data.userid;
		end
	);

	Tcp.SetTopicHandler('server.rooms',
		function(data)
			local dataRooms = (Developer and require('developer/rooms'))
				or data.rooms
				or {};

			state.roomCount = 0;
			state.roomList = {};

			if (#dataRooms > 0) then
				for i, room in ipairs(dataRooms) do
					state.roomCount = state.roomCount + 1;
					state.roomList[i] = room;
				end
			end
		end
	);

	Tcp.SetTopicHandler('room.update',
		function(data)
			local dataUsers =	(Developer and require('developer/users'))
				or data.users
				or {};
			local lobby = state.lobby;
			local ready = lobby.ready;
			local user = state.user;

			lobby.users = {};
			lobby.userCount = 0;
			lobby.ready = true;
			
			if (#dataUsers > 0) then
				for i, u in ipairs(dataUsers) do
					lobby.users[i] = u;

					if (u.id == user.id) then user.ready = u.ready; end

					if (not u.ready) then lobby.ready = false; end

					lobby.userCount = lobby.userCount + 1;
				end
			end

			if ((user.id == lobby.host)
				and (#dataUsers > 1)
				and lobby.ready
				and (not ready)
			) then
				mpSounds:trigger(2, 3, 0.1);
			end

			if ((data.host == user.id) and (lobby.host ~= user.id)) then
				mpSounds:trigger(2, 3, 0.1);
			end

			if ((data.song ~= nil) and (data.song ~= lobby.prevSong)) then
				mpSounds:trigger(1);

				lobby.prevSong = data.song;
			end

			lobby.host = data.host;
			lobby.owner = data.owner or lobby.host;

			lobby.hard = data.hard_mode;
			lobby.mirror = data.mirror_mode;
			lobby.rotate = data.do_rotate;
			
			if ((data.start_soon) and (not lobby.starting)) then
				mpSounds:trigger(1, 5, 1);
			end

			lobby.starting = data.start_soon;
		end
	);
end
