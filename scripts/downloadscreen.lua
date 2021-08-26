-- Global `dlScreen` table is available for this script and its related scripts

local CustomsFolder = ('/%s/'):format(getSetting('nauticaPath'), 'nautica');
local Header = { ['user-agent'] = 'unnamed_sdvx_clone' };
local NextURL = 'https://ksm.dev/app/songs';
local SongsURL = 'https://ksm.dev/app/songs?sort=%s';

local JSON = require('lib/json');

local JSONTable = require('common/jsontable');

local NauticaCache = require('components/downloadscreen/nauticacache');
local NauticaList = require('components/downloadscreen/nauticalist');
local NauticaSidebar = require('components/downloadscreen/nauticasidebar');

local window = Window:new();
local background = Background:new(window);

local jacketFallback = gfx.CreateSkinImage('loading.png', 0);

local nauticaJSON = JSONTable:new('nautica');
local userData = nauticaJSON:get();

if (not userData.blacklist) then
  userData = {
    blacklist = {},
    downloaded = {},
  };
end

---@class DownloadScreen
local state = {
  action = 'BROWSING',
  currLevel = 1,
  currSong = 1,
  filtered = false,
  levels = {},
  loading = false,
  playingSong = nil,
  sort = 'uploaded',
  songs = {},
  songCount = 0,

  -- Add the songs received from nautica
  ---@param this DownloadScreen
  ---@param songs NauticaSong[]
  addSongs = function(this, songs)
    for _, song in ipairs(songs) do
      if (not userData.blacklist[song.user_id]) then
        song.jacket = jacketFallback;

        song.status = userData.downloaded[song.id] and 'DOWNLOADED';

        this.songs[#this.songs + 1] = song;
        this.songCount = this.songCount + 1;
      end
    end

    this.loading = false;
  end,
};

do
  for i = 1, 20 do state.levels[i] = false; end
end

-- Nautica response callback
---@param res HttpResponse
local songsCallback = function(res)
  if (res.status ~= 200) then
    error(('Error accessing %s: status %d'):format(NextURL, res.status));

    return;
  end

  ---@type NauticaResponseBody
  local body = JSON.decode(res.text);

  state:addSongs(body.data);

  NextURL = body.links.next;
end

-- Fetch songs from nautica
local getSongs = function()
  if (NextURL and (not state.loading)) then
    Http.GetAsync(NextURL, Header, songsCallback);

    state.loading = true;
  end
end

-- Reload songs to reflect filters/sorts
local reloadSongs = function()
  if (state.loading) then return; end

  local applyFilter = false;
  local levels = {};

  for i, v in ipairs(state.levels) do
    if (v) then
      applyFilter = true;

      levels[#levels + 1] = i;
    end
  end

  NextURL = SongsURL:format(state.sort:lower());

  if (applyFilter) then
    NextURL = NextURL .. '&levels=' .. table.concat(levels, ',');
  end

  state.currSong = 1;
  state.songs = {};
  state.songCount = 0;

  getSongs();
end

-- DownloadScreen components
local nauticaCache = NauticaCache:new();
local nauticaList = NauticaList:new(window, state, nauticaCache);
local nauticaSidebar = NauticaSidebar:new(window, state);

-- Initial song fetching
Http.GetAsync(NextURL, Header, songsCallback);

-- Called by the game every frame
---@param dt deltaTime
render = function(dt)
  gfx.Save();

  window:set();

  background:render();

  nauticaSidebar:render();

  nauticaList:render(dt);

  gfx.Restore();
end

local chars = '-/_:.';

local charReplace = function(c)
  for i = 1, #chars do
    if (c == chars:sub(i, i)) then return c; end
  end

  return ('%%%02X'):format(c:byte());
end

local encodeURI = function(str)
  if (str) then
    str = str:gsub('\n', '\r\n');
    str = str:gsub('([^%w ])', charReplace);
    str = str:gsub(' ', '%%20');

    return str;
  end

  return '';
end

local archiveCallback = function(entries, id)
  local songsFolder = dlScreen.GetSongsPath();

  local longestPath;
  local res = {};
  local root = songsFolder .. CustomsFolder .. id .. '/';
  local song = state.songs[state.currSong];
  local folders = { songsFolder .. CustomsFolder };

  for _, entry in ipairs(entries) do
    if (longestPath) then
      if (#entry < #longestPath) then
        longestPath = longestPath:sub(1, #entry);
      end

      for i = 1, #longestPath do
        if (longestPath:sub(i, i) ~= entry:sub(i, i)) then
          longestPath = longestPath:sub(1, i - 1);

          break;
        end
      end
    else
      longestPath = entry;
    end
  end

  if (not longestPath) then return res; end

  for i = #longestPath, 1, -1 do
    if (longestPath:sub(i, i) == '/') then
      longestPath = longestPath:sub(1, i);

      break;
    end
  end

  folders[#folders + 1] = root;

  for _, entry in ipairs(entries) do
    local replaced = entry;

    if (#longestPath > 1) then replaced = replaced:sub(#longestPath + 1); end

    if (#replaced > 0) then
      for i = 1, #replaced do
        if (replaced:sub(i, i) == '/') then
          folders[#folders + 1] = root .. replaced:sub(1, i);
        end
      end

      res[entry] = root .. replaced;
    end
  end

  if ((song and song.id) == id) then song.status = 'DOWNLOADED'; end

  userData.downloaded[id] = 'DOWNLOADED';
  res['.folders'] = table.concat(folders, '|');

  return res;
end

-- Toggle current user action
---@param action string
local toggleAction = function(action)
  if (state.action ~= action) then
    state.action = action;
  else
    state.action = 'BROWSING';
  end
end

-- Called by the game when knobs are turned or arrow keys are pressed
---@param step integer # `-1` or `1`
advance_selection = function(step)
  if (state.action == 'BROWSING') then
    if (state.songCount > 0) then
      state.currSong = advance(state.currSong, state.songCount, step);

      if (state.currSong > (state.songCount - 6)) then getSongs(); end
    end
  elseif (state.action == 'FILTERING') then
    state.currLevel = advance(state.currLevel, 20, step);
  end
end

-- Called by the game when a (gamepad) button is pressed
---@param btn integer
button_pressed = function(btn)
  local action = state.action;

  if (btn == game.BUTTON_STA) then
    if (action == 'BROWSING') then
      local song = state.songs[state.currSong];

      if (not song) then return; end

      dlScreen.DownloadArchive(
        encodeURI(song.cdn_download_url),
        Header,
        song.id,
        archiveCallback
      );

      song.status = 'DOWNLOADING';
      userData.downloaded[song.id] = 'DOWNLOADING';
    elseif (action == 'FILTERING') then
      if (state.levels[state.currLevel]) then
        local filtered = false;

        state.levels[state.currLevel] = false;

        for i = 1, 20 do
          if (state.levels[i]) then filtered = true; end
        end

        state.filtered = filtered;
      else
        state.filtered = true;
        state.levels[state.currLevel] = true;
      end

      reloadSongs();
    end
  elseif (btn == game.BUTTON_BTA) then
    if (action == 'BROWSING') then
      local song = state.songs[state.currSong];

      if (not song) then return; end

      if (state.playingSong and (state.playingSong.id == song.id)) then
        dlScreen.StopPreview();
        state.playingSong.status = nil;
        state.playingSong = nil;
      else
        dlScreen.PlayPreview(encodeURI(song.preview_url), Header, song.id);

        song.status = 'PREVIEWING';

        if (state.playingSong) then state.playingSong.status = nil; end

        state.playingSong = song;
      end
    end
  elseif (btn == game.BUTTON_BTB) then
    if (action == 'BROWSING') then
      local song = state.songs[state.currSong];

      if (song) then
        userData.blacklist[song.user_id] = song.user and song.user.name;

        reloadSongs();
      end
    end
  elseif (btn == game.BUTTON_FXL) then
    if (state.sort == 'uploaded') then
      state.sort = 'oldest';
    else
      state.sort = 'uploaded';
    end

    reloadSongs();
  elseif (btn == game.BUTTON_FXR) then
    toggleAction('FILTERING');
  end
end

-- Called by the game when a key is pressed
---@param key integer
key_pressed = function(key)
  if (key == 27) then
    if (state.action == 'BROWSING') then
      nauticaJSON:overwrite(userData);

      dlScreen.Exit();
    else
      state.action = 'BROWSING';
    end
  end
end