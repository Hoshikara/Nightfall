CONSTANTS = require('constants/songwheel');
CONTROL_LIST = require('constants/controls');

cursor = require('songselect/cursor');
jacketDetail = require('songselect/jacketdetail');
easing = require('lib/easing');

local background = gfx.CreateSkinImage('bg.png', 0);

local controllerIcon = gfx.CreateSkinImage('song_select/controller_icon.png', 0);

local jacketFallback = gfx.CreateSkinImage('song_select/loading.png', 0);

local mousePosX = 0;
local mousePosY = 0;

local previousDifficultyIndex = 1;
local previousSongIndex = 1;

local allInitialized = false;

game.LoadSkinSample('menu_click');
game.LoadSkinSample('click-02');
game.LoadSkinSample('woosh');

local padding;
local resX;
local resY;
local scaledW;
local scaledH;
local scalingFactor;

setupLayout = function()
  resX, resY = game.GetResolution();
  scaledW = 1920;
  scaledH = scaledW * (resY / resX);
  scalingFactor = resX / scaledW;
  padding = scaledH / 12;

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

local controls = {
  ['labels'] = nil,
  ['x'] = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0
  },
  ['y'] = {
    [1] = 0,
    [2] = 0
  },
  ['showingControls'] = false,
  ['timer'] = 0
};

local labelHeight = {
  ['artist'] = 0,
  ['bpm'] = 0,
  ['clear'] = 0,
  ['effector'] = 0,
  ['grade'] = 0,
  ['title'] = 0
};

local songCache = {};

verifySongCache = function(song)
  if (not songCache[song.id]) then
    songCache[song.id] = {};
  end

  gfx.LoadSkinFont('DFMGM.ttf');

  if (not songCache[song.id]['title']) then
    songCache[song.id]['title'] = gfx.CreateLabel(string.upper(song.title), 36, 0);

    if (labelHeight['title'] == 0) then
      labelHeight['title'] = getLabelInfo(songCache[song.id]['title'])['h'];
    end
  end

  if (not songCache[song.id]['artist']) then
    songCache[song.id]['artist'] = gfx.CreateLabel(string.upper(song.artist), 36, 0);

    if (labelHeight['artist'] == 0) then
      labelHeight['artist'] = getLabelInfo(songCache[song.id]['artist'])['h'];
    end
  end

  if (labelHeight['effector'] == 0) then
    local tempLabel = gfx.CreateLabel('EFFECTOR', 24, 0);

    labelHeight['effector'] = getLabelInfo(tempLabel)['h'];
  end

  gfx.LoadSkinFont('DigitalSerialBold.ttf');

  if (not songCache[song.id]['bpm']) then
    songCache[song.id]['bpm'] = gfx.CreateLabel(tostring(song.bpm), 24, 0);

    if (labelHeight['bpm'] == 0) then
      gfx.LoadSkinFont('GothamMedium.ttf');

      local tempLabel = gfx.CreateLabel('100', 24, 0);

      labelHeight['bpm'] = getLabelInfo(tempLabel)['h'];
      labelHeight['grade'] = labelHeight['bpm'];
      labelHeight['clear'] = labelHeight['bpm'];
    end
  end
end

verifySongCacheEffector = function(song, difficultyIndex)
  local difficulty = song.difficulties[difficultyIndex];

  if (not difficulty) then
    difficulty = song.difficulties[1];
  end

  if (not songCache[song.id]['effector']) then
    songCache[song.id]['effector'] = {};
  end

  gfx.LoadSkinFont('DFMGM.ttf');

  if (not songCache[song.id]['effector'][difficultyIndex]) then
    songCache[song.id]['effector'][difficultyIndex] = gfx.CreateLabel(string.upper(difficulty.effector), 24, 0);
  end
end

local clears = {
  ['labels'] = {}
};

clears.initialize = function(self)
  gfx.LoadSkinFont('GothamBook.ttf');

  for index, clear in ipairs(CONSTANTS['clears']) do
    self['labels'][index] = gfx.CreateLabel(clear, 24, 0);
  end

  self.getClear = function(self, difficulty)
    local label = nil;

    if (difficulty.scores[1]) then
      if (difficulty.topBadge ~= 0) then
        label = self['labels'][difficulty.topBadge];
      end
    end

    return label;
  end
end

local grades = {
  ['breakpoints'] = {}
};

grades.initialize = function(self)
  gfx.LoadSkinFont('GothamBook.ttf');

  for index, current in ipairs(CONSTANTS['grades']) do
    self['breakpoints'][index] = {
      ['minimum'] = current['minimum'],
      ['label'] = gfx.CreateLabel(current['grade'], 24, 0)
    };
  end

  self.getGrade = function(self, difficulty)
    local label = nil;

    if (difficulty.scores[1]) then
      local highScore = difficulty.scores[1];

      for _, breakpoint in ipairs(self['breakpoints']) do
        if (highScore.score >= breakpoint['minimum']) then
          label = breakpoint['label'];
          break;
        end
      end
    end

    return label;
  end
end

local songGrid = {
  ['cursor'] = {
    ['alpha'] = 0,
    ['animTimer'] = 0,
    ['animTotal'] = 0.1,
    ['pos'] = 0,
    ['displayPos'] = 0,
    ['timer'] = 0
  },
  ['easing'] = {
    ['grid'] = {
      ['duration'] = 0.2,
      ['initial'] = 0,
      ['timer'] = 0
    },
    ['scrollbar'] = {
      ['duration'] = 0.2,
      ['initial'] = 0,
      ['timer'] = 0
    }
  },
  ['grid'] = {
    ['gutter'] = nil,
    ['size'] = nil,
    ['x'] = nil,
    ['y'] = nil
  },
  ['jacketSize'] = nil,
  ['labels'] = nil,
  ['numColumns'] = 3,
  ['numRows'] = 3,
  ['rowOffset'] = 0,
  ['scrollbar'] = {
    ['height'] = 0,
    ['pos'] = 0,
    ['x'] = 0,
    ['y'] = 0
  },
  ['selectedDifficulty'] = 0,
  ['selectedSongIndex'] = 1
};

songGrid.initialize = function(self)
  self.setAllSizes = function(self)
    self['jacketSize'] = scaledH / 4;
    self['grid']['gutter'] = self['jacketSize'] / 8;
    self['grid']['size'] = (self['jacketSize'] + self['grid']['gutter']) * 4;
    self['grid']['x'] = scaledW - self['grid']['size'] + (self['grid']['gutter'] * 7);
    self['grid']['y'] = self['jacketSize'] - (self['grid']['gutter'] * 3.75);

    self['labels']['spacing'] = (self['jacketSize'] * 2) / 3.5;
    self['labels']['x'] = self['grid']['x'];
    self['labels']['y'] = scaledH / 20;

    self['scrollbar']['height'] = (self['jacketSize'] * 3) + (self['grid']['gutter'] * 2);
    self['scrollbar']['x'] = scaledW - (self['grid']['gutter'] * 1.5);
    self['scrollbar']['y'] = self['grid']['y'];
  end

  self.setDifficulty = function(self, newDifficulty)
    self['selectedDifficulty'] = newDifficulty;
  end

  self.setLabels = function(self)
    if (not self['labels']) then
      gfx.LoadSkinFont('GothamMedium.ttf');

      self['labels'] = {};

      self['labels']['of'] = gfx.CreateLabel('OF', 18, 0);

      for name, str in pairs(CONSTANTS['labels']['grid']) do
        self['labels'][name] = gfx.CreateLabel(str, 18, 0);
      end

      gfx.LoadSkinFont('DigitalSerialBold.ttf');

      self['labels']['currentSong'] = gfx.CreateLabel('', 18, 0);
      self['labels']['totalSongs'] = gfx.CreateLabel('', 18, 0);
    end
  end

  self.setRowOffset = function(self, newRowOffset)
    self['easing']['grid']['initial'] = self['rowOffset'];
    self['easing']['grid']['timer'] = self['easing']['grid']['duration'];
    self['rowOffset'] = newRowOffset;
  end

  self.setScrollbarPos = function(self, completion)
    self['easing']['scrollbar']['initial'] = self['scrollbar']['pos'];
    self['easing']['scrollbar']['timer'] = self['easing']['scrollbar']['duration'];
    self['scrollbar']['pos'] = self['scrollbar']['y'] + (completion * (self['scrollbar']['height'] - 32));
  end

  self.setSongIndex = function(self, newSongIndex)
    local delta = newSongIndex - self['selectedSongIndex'];

    if ((delta < -1) or (delta > 1)) then
      local newOffset = newSongIndex - 1;

      self:setRowOffset(math.floor((newSongIndex - 1) / self['numColumns']) * self['numColumns']);
      self['cursor']['pos'] = (newSongIndex - 1) - self['rowOffset'];
      self['cursor']['displayPos'] = self['cursor']['pos'];
    else
      local newCursorPos = self['cursor']['pos'] + delta;

      if (newCursorPos < 0) then
        self:setRowOffset(self['rowOffset'] - self['numColumns']);
        newCursorPos = newCursorPos + self['numColumns'];
      elseif (newCursorPos >= (self['numColumns'] * self['numColumns'])) then
        self:setRowOffset(self['rowOffset'] + self['numColumns']);
        newCursorPos = newCursorPos - self['numColumns'];
      end

      if (self['cursor']['animTimer'] > 0) then
        self['cursor']['displayPos'] = easing.outQuad(
          0.5 - self['cursor']['animTimer'],
          self['cursor']['displayPos'],
          self['cursor']['pos'] - self['cursor']['displayPos'],
          0.5
        );
      end

      self['cursor']['animTimer'] = self['cursor']['animTotal'];
      self['cursor']['pos'] = newCursorPos;
    end

    self['selectedSongIndex'] = newSongIndex;

    self:setScrollbarPos((self['rowOffset'] + self['cursor']['pos']) / (#songwheel.songs - 1));
  end

  self.getCurrentRowOffset = function(self)
    return easing.outQuad(
      self['easing']['grid']['duration'] - self['easing']['grid']['timer'],
      self['easing']['grid']['initial'],
      self['rowOffset'] - self['easing']['grid']['initial'],
      self['easing']['grid']['duration']
    );
  end

  self.getCursorPosition = function(self, position, yOffset)
    local whichColumn = position % self['numColumns'];
    local whichRow = math.floor(position / self['numColumns']) + (yOffset or 0);
    local x = self['grid']['x'] + whichColumn * (self['grid']['size'] / 4);
    local y = self['grid']['y'] + whichRow * (self['grid']['size'] / 4);

    return x, y;
  end

  self.getScrollbarPos = function(self)
    return easing.outQuad(
      self['easing']['scrollbar']['duration'] - self['easing']['scrollbar']['timer'],
      self['easing']['scrollbar']['initial'],
      self['scrollbar']['pos'] - self['easing']['scrollbar']['initial'],
      self['easing']['scrollbar']['duration']
    );
  end

  self.drawAllSongs = function(self, deltaTime)
    if (self['easing']['grid']['timer'] > 0) then
      self['easing']['grid']['timer'] = math.max(self['easing']['grid']['timer'] - deltaTime, 0);
    end

    for i = 0, (self['numRows'] + 1)  do
      for v = 1, self['numColumns'] do
        local tempIndex = ((i - 1) * 3) + v;
        local index = self['rowOffset'] + tempIndex;
        local yOffset = (self['rowOffset'] - self:getCurrentRowOffset()) / 3;

        if (index <= #songwheel.songs) then
          self:drawSong(
            deltaTime,
            tempIndex - 1,
            index,
            yOffset
          );
        end
      end
    end
  end

  self.drawCursor = function(self, deltaTime)
    self['cursor']['timer'] = self['cursor']['timer'] + deltaTime;

    self['cursor']['alpha'] = math.abs(0.8 * math.cos(self['cursor']['timer'] * 5)) + 0.2;

    local position = self['cursor']['displayPos'];

    if (self['cursor']['animTimer'] > 0) then
      self['cursor']['animTimer'] = self['cursor']['animTimer'] - deltaTime;

      if (self['cursor']['animTimer'] <= 0) then
        self['cursor']['displayPos'] = self['cursor']['pos'];

        position = self['cursor']['pos'];
      else
        position = easing.outQuad(
          self['cursor']['animTotal'] - self['cursor']['animTimer'],
          self['cursor']['displayPos'],
          self['cursor']['pos'] - self['cursor']['displayPos'],
          self['cursor']['animTotal']
        );
      end
    end

    local x, y = self:getCursorPosition(position);

    gfx.Save();

    gfx.Translate(x, y);

    cursor:drawSongCursor(0, 0, self['jacketSize'], self['jacketSize'], 8, self['cursor']['alpha']);

    gfx.Restore();
  end

  self.drawLabels = function(self)
    gfx.Save();
  
    local x = 0;

    gfx.Translate(self['labels']['x'] - 4, self['labels']['y'] - 4);

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
    gfx.FillColor(unpack(colors['blueNormal']));

    gfx.DrawLabel(self['labels']['sort'], x, 0);
    x = x + getLabelInfo(self['labels']['sort'])['w'] + self['labels']['spacing'];

    gfx.DrawLabel(self['labels']['difficulty'], x, 0);
    x = x + getLabelInfo(self['labels']['difficulty'])['w'] + self['labels']['spacing'];
  
    gfx.DrawLabel(self['labels']['collection'], x, 0);

    gfx.Restore();
  end

  self.drawNoSongMessage = function(self)
    local x = self['grid']['x'] + ((self['grid']['size'] - self['grid']['gutter'] * 10) / 2);
    local y = scaledH / 2 + self['grid']['gutter'];

    gfx.Save();

    gfx.Translate(x, y);

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE);
    gfx.LoadSkinFont('GothamBook.ttf');
    gfx.FontSize(48);
    gfx.FillColor(unpack(colors['white']));
    gfx.Text('NO SONGS FOUND', 0, 0);

    gfx.Restore();
  end

  self.drawScrollbar = function(self, deltaTime)
    if (self['easing']['scrollbar']['timer'] > 0) then
      self['easing']['scrollbar']['timer'] = math.max(self['easing']['scrollbar']['timer'] - deltaTime, 0);
    end

    local y = self:getScrollbarPos();
    local barPos = ((y > 0) and y) or -100;

    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, 150);
    gfx.Rect(
      self['scrollbar']['x'],
      self['scrollbar']['y'],
      8,
      self['scrollbar']['height']
    );
    gfx.Fill();

    gfx.BeginPath();
    gfx.FillColor(unpack(colors['blueNormal']));
    gfx.Rect(self['scrollbar']['x'], barPos, 8, 32);
    gfx.Fill();
  end

  self.drawSongAmount = function(self)
    local x = scaledW - self['grid']['gutter'] * 5.25;
    local y = scaledH - self['grid']['gutter'] - 5;
  
    gfx.LoadSkinFont('DigitalSerialBold.ttf');

    gfx.UpdateLabel(
      self['labels']['currentSong'],
      string.format('%04d', self['selectedSongIndex']),
      18,
      0
    );
    gfx.UpdateLabel(
      self['labels']['totalSongs'],
      string.format('%04d', #songwheel.songs),
      18,
      0
    );

    gfx.BeginPath();
    gfx.FillColor(unpack(colors['blueNormal']));
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
    gfx.DrawLabel(self['labels']['currentSong'], x + 3, y);
    gfx.DrawLabel(self['labels']['of'], x + 60, y);
    gfx.DrawLabel(self['labels']['totalSongs'], x + 96, y);
  end

  self.drawSong = function(self, deltaTime, position, songIndex, yOffset)
    if (songIndex < 1) then return end;

    local song = songwheel.songs[songIndex];

    local isSelected = songIndex == self['selectedSongIndex'];
    local jacketAlpha = (isSelected and 1) or 0.2;
    local detailAlpha = (isSelected and 1) or 0.06;

    if (not song) then return end;

    verifySongCache(song);

    local difficulty = song.difficulties[self['selectedDifficulty']];

    if (not difficulty) then
      difficulty = song.difficulties[1];
    end

    if ((not songCache[song.id][self['selectedDifficulty']])
      or (songCache[song.id][self['selectedDifficulty']] == jacketFallback)) then
        songCache[song.id][self['selectedDifficulty']] = gfx.LoadImageJob(
          difficulty.jacketPath,
          jacketFallback,
          0,
          0
        );
    end

    local x, y = self:getCursorPosition(position, yOffset);
    local offScreen = (y > (scaledH - (scaledH / 20))) or (y < (scaledH / 20));
    
    gfx.Save();

    gfx.Translate(x, y);

    if (songCache[song.id][self['selectedDifficulty']]) then
      gfx.BeginPath();
      gfx.FillColor(unpack(colors['black']));
      gfx.Rect(0, 0, self['jacketSize'], self['jacketSize']);
      gfx.Fill();

      gfx.BeginPath();
      gfx.StrokeWidth(2);
      
      if (isSelected) then
        gfx.StrokeColor(unpack(colors['blueNormal']));
      else
        gfx.StrokeColor(unpack(colors['blueDark']));
      end

      gfx.ImageRect(
        0, 
        0, 
        self['jacketSize'], 
        self['jacketSize'], 
        songCache[song.id][self['selectedDifficulty']], 
        jacketAlpha,
        0
      );
      gfx.Stroke();

      if (not offScreen) then
        jacketDetail:drawDetail(0, 0, self['jacketSize'], self['jacketSize'], detailAlpha);
      end
    end

     gfx.Restore();
  end

  self.render = function(self, deltaTime)
    gfx.Save();

    self:setLabels();

    self:setAllSizes();

    gfx.Scissor(
      self['grid']['x'] - (self['grid']['gutter']),
      self['grid']['gutter'] * 3.5,
      self['grid']['size'] - self['grid']['gutter'] * 8,
      self['grid']['size'] - self['grid']['gutter'] * 8.4
    );

    self:drawAllSongs(deltaTime);

    if (songwheel.songs[self['selectedSongIndex']]) then
      self:drawCursor(deltaTime);
    else
      self:drawNoSongMessage();
    end

    gfx.ResetScissor();

    if (songwheel.songs[self['selectedSongIndex']]) then
      self:drawSongAmount();
    end

    self:drawLabels();
    self:drawScrollbar(deltaTime);

    gfx.Restore();
  end
end

local songInfo = {
  ['cursor'] = {
    ['alpha'] = 0,
    ['pos'] = 0,
    ['selected'] = nil,
    ['timer'] = 0,
    ['x'] = nil,
    ['y'] = {}
  },
  ['difficulties'] = nil,
  ['highScore'] = nil,
  ['images'] = {
    ['button'] = gfx.CreateSkinImage('song_select/button.png', 0),
    ['buttonHover'] = gfx.CreateSkinImage('song_select/button_hover.png', 0),
    ['panel'] = gfx.CreateSkinImage('song_select/panel.png', 0)
  },
  ['jacketSize'] = nil,
  ['labels'] = nil,
  ['levels'] = nil,
  ['order'] = {
    ['conditional'] = {
      [1] = 'grade',
      [2] = 'clear'
    },
    ['main'] = {
      [1] = 'title',
      [2] = 'artist',
      [3] = 'effector',
      [4] = 'bpm'
    }
  },
  ['padding'] = {
    ['x'] = {
      ['double'] = nil,
      ['full'] = nil,
      ['half'] = nil,
      ['quarter'] = nil
    },
    ['y'] = {
      ['double'] = nil,
      ['full'] = nil,
      ['half'] = nil,
      ['quarter'] = nil
    }
  },
  ['panel'] = {
    ['centerX'] = nil,
    ['w'] = nil,
    ['h'] = nil,
    ['x'] = nil,
    ['y'] = nil
  },
  ['selectedDifficulty'] = 0,
  ['selectedSongIndex'] = 0,
  ['scrollTimers'] = {
    ['artist'] = 0,
    ['effector'] = 0,
    ['title'] = 0
  }
};

songInfo.initialize = function(self)
  self.setAllSizes = function(self)
    self['jacketSize'] = scaledW / 5;

    self['panel']['w'] = scaledW / (scaledW / getImageInfo(self['images']['panel'])['w']);
    self['panel']['h'] = scaledH - (scaledH / 10);
    self['panel']['x'] = scaledW / 20;
    self['panel']['y'] = scaledH / 20;
    self['panel']['centerX'] = self['panel']['w'] / 2;

    self['padding']['x']['full'] = self['panel']['w'] / 20;
    self['padding']['x']['double'] = self['padding']['x']['full'] * 2;
    self['padding']['x']['half'] = self['padding']['x']['full'] / 2;
    self['padding']['x']['quarter'] = self['padding']['x']['full'] / 4;

    self['padding']['y']['full'] = self['panel']['h'] / 20;
    self['padding']['y']['double'] = self['padding']['y']['full'] * 2;
    self['padding']['y']['half'] = self['padding']['y']['full'] / 2;
    self['padding']['y']['quarter'] = self['padding']['y']['full'] / 4;

    self['cursor']['x'] = self['padding']['x']['double'] + self['jacketSize'] + self['padding']['x']['full'] - 6;

    self['panel']['innerWidth'] = self['panel']['w'] - (self['padding']['x']['double'] * 2);

    self['labels']['x'] = self['padding']['x']['double'];
    self['labels']['y'] = self['padding']['y']['double'] + self['jacketSize'];
  end

  self.setDifficulty = function(self, newDifficulty)
    self['selectedDifficulty'] = newDifficulty;
  end

  self.setLabels = function(self)
    if (not self['labels']) then
      gfx.LoadSkinFont('DigitalSerialBold.ttf');

      self['difficulties'] = {};
      self['highScore'] = {
        [1] = gfx.CreateLabel('', 90, 0),
        [2] = gfx.CreateLabel('', 72, 0)
      };
      self['labels'] = {
        ['order'] = {
          ['conditional'] = {
            [1] = 'grade',
            [2] = 'clear'
          },
          ['main'] = {
            [1] = 'title',
            [2] = 'artist',
            [3] = 'effector',
            [4] = 'bpm'
          }
        }
      };
      self['levels'] = {};

      for index, level in pairs(CONSTANTS['levels']) do
        self['levels'][index] = gfx.CreateLabel(level, 18, 0);
      end

      gfx.LoadSkinFont('GothamMedium.ttf');

      for index, name in pairs(CONSTANTS['difficulties']) do
        self['difficulties'][index] = gfx.CreateLabel(name, 18, 0);
      end

      for name, str in pairs(CONSTANTS['labels']['info']) do
        self['labels'][name] = gfx.CreateLabel(str, 18, 0);
      end
    end
  end

  self.setSongIndex = function(self, newSongIndex)
    self['selectedSongIndex'] = newSongIndex;
  end

  self.getDifficulty = function(self, difficulties, index)
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
  end

  self.drawJacket = function(self, song, difficulty)
    gfx.Save();

    if ((not songCache[song.id][self['selectedDifficulty']])
      or (songCache[song.id][self['selectedDifficulty']] == jacketFallback)) then
        songCache[song.id][self['selectedDifficulty']] = gfx.LoadImageJob(
          difficulty.jacketPath,
          jacketFallback,
          self['jacketSize'],
          self['jacketSize']
        );
    end

    if (songCache[song.id][self['selectedDifficulty']]) then
      gfx.BeginPath();
      gfx.StrokeWidth(2);
      gfx.StrokeColor(unpack(colors['blueNormal']));
      gfx.ImageRect(
        self['padding']['x']['double'],
        self['padding']['y']['full'],
        self['jacketSize'],
        self['jacketSize'],
        songCache[song.id][self['selectedDifficulty']],
        1,
        0
      );
      gfx.Stroke();
    end

    gfx.Restore();
  end

  self.drawLabels = function(self, song)
    gfx.Save();

    local baseLabelHeight = getLabelInfo(self['labels']['title'])['h'];
    local y = self['labels']['y'] - 4;

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
    gfx.FillColor(unpack(colors['blueNormal']));

    gfx.DrawLabel(
      self['labels']['difficulty'],
      self['padding']['x']['double'] + self['jacketSize'] + self['padding']['x']['full'] + 6,
      self['padding']['y']['full'] - 4
    );

    for _, name in ipairs(self['labels']['order']['main']) do
      gfx.DrawLabel(self['labels'][name], self['labels']['x'], y, -1);

      y = y 
        + baseLabelHeight
        + self['padding']['y']['quarter']
        + labelHeight[name]
        + self['padding']['y']['half']
        - 4;
    end

    if (song) then
      local difficulty = song.difficulties[self['selectedDifficulty']];

      if (not difficulty) then
        difficulty = song.difficulties[1];
      end

      if (grades:getGrade(difficulty)) then
        for _, name in ipairs(self['labels']['order']['conditional']) do
          gfx.DrawLabel(self['labels'][name], self['labels']['x'], y, -1);

          y = y 
            + baseLabelHeight
            + self['padding']['y']['quarter']
            + labelHeight[name]
            + self['padding']['y']['half']
            - 4;
        end
      end
    end

    gfx.Restore();
  end

  self.drawSongInfo = function(self, deltaTime, id, difficulty)
    gfx.Save();

    local baseLabelHeight = getLabelInfo(self['labels']['title'])['h'];
    local y = self['labels']['y']
      + baseLabelHeight
      + self['padding']['y']['quarter']
      - 8;
    local clearLabel = clears:getClear(difficulty);
    local gradeLabel = grades:getGrade(difficulty);

    gfx.BeginPath();

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
    gfx.FillColor(unpack(colors['white']));

    for _, name in ipairs(self['order']['main']) do
      local currentLabel =
        ((name == 'effector') and songCache[id][name][self['selectedDifficulty']])
        or songCache[id][name];
      local doesOverflow = getLabelInfo(currentLabel)['w'] > self['panel']['innerWidth'];
  
      if (doesOverflow and self['scrollTimers'][name] ~= nil) then
        self['scrollTimers'][name] = self['scrollTimers'][name] + deltaTime;

        drawScrollingLabel(
          self['scrollTimers'][name],
          currentLabel,
          self['panel']['innerWidth'],
          getLabelInfo(currentLabel)['h'],
          self['labels']['x'],
          y,
          scalingFactor,
          1,
          {255, 255, 255, 255}
        );
      else
        gfx.DrawLabel(currentLabel, self['labels']['x'], y - 1);
      end

      y = y
        + labelHeight[name]
        + self['padding']['y']['half']
        + baseLabelHeight
        + self['padding']['y']['quarter']
        - 4;
    end

    if (clearLabel and gradeLabel) then
      for _, name in ipairs(self['order']['conditional']) do
        local currentLabel = ((name == 'grade') and gradeLabel) or clearLabel;

        gfx.DrawLabel(currentLabel, self['labels']['x'], y, -1);

        y = y
          + labelHeight[name]
          + self['padding']['y']['half']
          + baseLabelHeight
          + self['padding']['y']['quarter']
          - 4;
      end

      local highScore = difficulty.scores[1].score;
      local scoreText = string.format('%08d', highScore);
      
      gfx.BeginPath();
      gfx.LoadSkinFont('DigitalSerialBold.ttf');
      gfx.UpdateLabel(self['highScore'][1], string.sub(scoreText, 1, 4), 90, 0);
      gfx.UpdateLabel(self['highScore'][2], string.sub(scoreText, -4), 72, 0);

      local x = self['labels']['x'] + (self['padding']['x']['double'] * 2.4);
      local y = scaledH - (scaledH / 20) - (self['padding']['y']['double'] * 2.15);

      gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
      gfx.FillColor(unpack(colors['blueNormal']));
      gfx.DrawLabel(self['labels']['highScore'], x, y);

      y = y + (self['padding']['y']['quarter'] / 2) + 2;

      gfx.FillColor(unpack(colors['white']));
      gfx.DrawLabel(self['highScore'][1], x - 4, y);

      gfx.FillColor(unpack(colors['blueNormal']));
      gfx.DrawLabel(
        self['highScore'][2],
        x + getLabelInfo(self['highScore'][1])['w'],
        y + self['padding']['y']['half'] - 6
      );
    end

    gfx.Restore();
  end

  self.drawDifficulty = function(self, currentDifficulty, isSelected, y)
    gfx.Save();
  
    local w, h = gfx.ImageSize(self['images']['button']);
    local x = self['cursor']['x'];
    local alpha = math.floor(255 * ((isSelected and 1) or 0.2));
  
    gfx.BeginPath();

    if (isSelected) then
      gfx.ImageRect(x, y, w, h, self['images']['buttonHover'], 1, 0);
    else
      gfx.ImageRect(x, y, w, h, self['images']['button'], 0.45, 0);
    end

    if (currentDifficulty) then
      gfx.BeginPath();
      gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
      gfx.FillColor(255, 255, 255, alpha);
      gfx.DrawLabel(
        self['difficulties'][currentDifficulty.difficulty + 1],
        x + 36,
        y + (h / 2.85)
      );
      gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP);
      gfx.DrawLabel(self['levels'][currentDifficulty.level], x + w - 36, y + (h / 2.85));
    end

    gfx.Restore();

    return (y + h + 6);
  end

  self.drawCursor = function(self, deltaTime, y)
    gfx.Save();

    self['cursor']['timer'] = self['cursor']['timer'] + deltaTime;

    self['cursor']['alpha'] = math.abs(0.8 * math.cos(self['cursor']['timer'] * 5)) + 0.2;

    self['cursor']['pos'] = self['cursor']['pos'] - (self['cursor']['pos'] - y) * deltaTime * 50;

    gfx.BeginPath();

    cursor:drawDifficultyCursor(self['cursor']['x'], self['cursor']['pos'], 222, 74, 4, self['cursor']['alpha']);

    gfx.Restore();
  end

  self.drawSongInfoPanel = function(self, deltaTime)
    local song = songwheel.songs[self['selectedSongIndex']];

    gfx.Save();

    gfx.Translate(self['panel']['x'], self['panel']['y']);

    gfx.BeginPath();
    gfx.ImageRect(0, 0, self['panel']['w'], self['panel']['h'], self['images']['panel'], 0.65, 0);

    self:drawLabels(song);

    gfx.Restore();

    if (not song) then return end;

    gfx.Save();

    verifySongCache(song);
    verifySongCacheEffector(song, self['selectedDifficulty']);

    local difficulty = song.difficulties[self['selectedDifficulty']];

    if (not difficulty) then
      difficulty = song.difficulties[1];
    end

    gfx.Translate(self['panel']['x'], self['panel']['y']);

    self:drawJacket(song, difficulty);

    self:drawSongInfo(deltaTime, song.id, difficulty);

    local difficultyY = self['padding']['y']['double'] + getLabelInfo(self['labels']['difficulty'])['h'] - 24;

    for index = 1, 4 do
      local level = self:getDifficulty(song.difficulties, index);
      local isSelected = difficulty.difficulty == (index - 1);

      if (isSelected) then
        self['cursor']['selected'] = index;
      end

      self['cursor']['y'][index] = difficultyY;
      difficultyY = self:drawDifficulty(level, isSelected, difficultyY);
    end

    self:drawCursor(deltaTime, self['cursor']['y'][self['cursor']['selected']]);
    
    gfx.Restore();
  end

  self.render = function(self, deltaTime)
    gfx.Save();

    self:setLabels();
    self:setAllSizes();

    self:drawSongInfoPanel(deltaTime);

    gfx.Restore();
  end
end

local search = {
  ['alpha'] = 0,
  ['cursor'] = {
    ['timer'] = 0,
    ['alpha'] = 0
  },
  ['index'] = 1,
  ['labels'] = nil,
  ['w'] = 0,
  ['h'] = 0,
  ['x'] = 0,
  ['y'] = 0,
  ['timer'] = 0
};

search.initialize = function(self)
  self.setAllSizes = function(self)
    self['w'] = songInfo['panel']['w'] + 6;
    self['h'] = (songGrid['grid']['gutter'] * 1.5);
    self['x'] = scaledW / 20;
    self['y'] = scaledH / 40;
  end

  self.setLabels = function(self)
    if (not self['labels']) then
      gfx.LoadSkinFont('GothamMedium.ttf');

      self['labels'] = {};

      self['labels']['search'] = gfx.CreateLabel('SEARCH', 18, 0);

      gfx.LoadSkinFont('GothamBook.ttf');

      self['labels']['input'] = gfx.CreateLabel('', 24, 0);
    end
  end

  self.drawSearch = function(self, deltaTime)
    gfx.Save();
  
    local acceptInput = songwheel.searchInputActive;
    local shouldShow = (string.len(songwheel.searchText) > 0) or songwheel.searchInputActive;

    if (shouldShow) then
      self['timer'] = math.min(self['timer'] + (deltaTime * 6), 1);
      self['cursor']['timer'] = self['cursor']['timer'] + deltaTime;
    elseif (self['timer'] > 0 and (not shouldShow)) then
      self['timer'] = math.max(self['timer'] - (deltaTime * 6), 0);
      self['cursor']['timer'] = 0;
    end

    self['alpha'] = math.floor(255 * math.min(self['timer'] * 2, 1));
    self['cursor']['alpha'] = (acceptInput and math.abs(0.9 * math.cos(self['cursor']['timer'] * 5)) + 0.1) or 0;

    gfx.LoadSkinFont('GothamBook.ttf');
    gfx.UpdateLabel(self['labels']['input'], string.upper(songwheel.searchText), 24, 0);

    local cursorOffset = math.min(getLabelInfo(self['labels']['input'])['w'] + 2, self['w'] - 20);

    if (self['index'] ~= ((acceptInput and 0) or 1)) then
      game.PlaySample('woosh');
    end

    self['index'] = (acceptInput and 0) or 1;

    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, 150);
    gfx.FastRect(self['x'] - 6, self['y'] - 6, self['w'] * self['timer'], self['h'] + 12);
    gfx.Fill();

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
    gfx.FillColor(60, 110, 160, self['alpha']);
    gfx.DrawLabel(self['labels']['search'], self['x'], self['y'] - 4, -1);

    if (shouldShow) then
      gfx.BeginPath();
      gfx.FillColor(255, 255, 255, math.floor(255 * self['cursor']['alpha']));
      gfx.FastRect(
        self['x'] + cursorOffset,
        self['y'] + (self['h'] / 2) - 4,
        2,
        28
      );
      gfx.Fill();

      gfx.BeginPath();
      gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
      gfx.FillColor(unpack(colors['white']));
      gfx.DrawLabel(self['labels']['input'], self['x'], self['y'] + 20, self['w'] - 20);
    end

    gfx.Restore();
  end

  self.render = function(self, deltaTime)
    gfx.Save();

    self:setAllSizes();
    self:setLabels();

    self:drawSearch(deltaTime);

    gfx.Restore();
  end
end

controls.initialize = function(self)
  self.setAllSizes = function(self)
    self['x'] = scaledW / 20;
    self['y'] = scaledH / 20;
  end

  self.setLabels = function(self)
    if (not self['labels']) then
      gfx.LoadSkinFont('GothamMedium.ttf');
    
      self['labels'] = {
        ['heading'] = gfx.CreateLabel('CONTROLS', 60, 0),
        ['songSelectHeading'] = gfx.CreateLabel('SONG SELECT', 36, 0),
        ['gameplaySettingsHeading'] = gfx.CreateLabel('GAMEPLAY SETTINGS', 36, 0),
        ['controller'] = gfx.CreateLabel('CONTROLLER', 30, 0),
        ['keyboard'] = gfx.CreateLabel('KEYBOARD', 30, 0),
        ['songSelect'] = {
          ['action'] = {},
          ['controller'] = {},
          ['keyboard'] = {}
        },
        ['gameplaySettings'] = {
          ['action'] = {},
          ['button'] = {},
          ['keyboard'] = {}
        }
      };

      for index, control in ipairs(CONTROL_LIST['songSelect']) do
        self['labels']['songSelect'][index] = {};

        gfx.LoadSkinFont('GothamBook.ttf');
        self['labels']['songSelect'][index]['action'] = gfx.CreateLabel(control['action'], 24, 0);

        gfx.LoadSkinFont('GothamMedium.ttf');
        self['labels']['songSelect'][index]['controller'] = gfx.CreateLabel(control['controller'], 24, 0);
        self['labels']['songSelect'][index]['keyboard'] = gfx.CreateLabel(control['keyboard'], 24, 0);
      end

      for index, control in ipairs(CONTROL_LIST['gameplaySettings']) do
        self['labels']['gameplaySettings'][index] = {};

        gfx.LoadSkinFont('GothamBook.ttf');
        self['labels']['gameplaySettings'][index]['action'] = gfx.CreateLabel(control['action'], 24, 0);

        gfx.LoadSkinFont('GothamMedium.ttf');
        self['labels']['gameplaySettings'][index]['controller'] = gfx.CreateLabel(control['controller'], 24, 0);
        self['labels']['gameplaySettings'][index]['keyboard'] = gfx.CreateLabel(control['keyboard'], 24, 0);
      end
    end
  end

  self.drawButton = function(self, deltaTime)
    local imgW, imgH = gfx.ImageSize(controllerIcon);
    local imgX = (scaledW / 40) - (imgW / 2);
    local w = scaledW / 20;
    local h = (scaledH / 20) + 10;
    local x = 0;
    local y = scaledH - h;

    gfx.BeginPath();
    gfx.ImageRect(imgX, y + 16, imgW, imgH, controllerIcon, math.max(self['timer'] * 0.7, 0.35), 0);

    if (mouseClipped(x, y, w, h)) then
      self['showingControls'] = true;

      self['timer'] = math.min(self['timer'] + (deltaTime * 8), 1);
    end
  end

  self.drawControls = function(self)
    if ((not self['showingControls']) and (self['timer'] == 0)) then return end;

    local alpha = math.floor(255 * self['timer']);
    local x = getLabelInfo(self['labels']['gameplaySettingsHeading'])['w'] + 75;
    local y = 0;

    gfx.BeginPath();
    gfx.FillColor(0, 0, 0, math.floor(235 * self['timer']));
    gfx.FastRect(0, 0, scaledW, scaledH);
    gfx.Fill();

    gfx.Save();

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
    gfx.FillColor(255, 255, 255, alpha);
    gfx.DrawLabel(self['labels']['heading'], self['x'] - 2, self['y']);

    gfx.Translate(self['x'], self['y']);

    y = y + (getLabelInfo(self['labels']['heading'])['h'] * 1.5);

    gfx.BeginPath();
    gfx.FillColor(255, 255, 255, alpha);
    gfx.FastRect(x, y + 52, 4, scaledH / 1.825);
    gfx.Fill();

    gfx.BeginPath();
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP);
    gfx.FillColor(60, 110, 160, alpha);
    gfx.DrawLabel(self['labels']['songSelectHeading'], 0, y + 42);

    x = x + 75;

    gfx.FillColor(255, 255, 255, alpha);
    gfx.DrawLabel(self['labels']['controller'], x, y);
    gfx.DrawLabel(self['labels']['keyboard'], x + 350, y);

    y = y + 43;

    for i, control in ipairs(self['labels']['songSelect']) do
      gfx.FillColor(60, 110, 160, alpha);
      gfx.DrawLabel(control['controller'], x, y);

      gfx.DrawLabel(control['keyboard'], x + 350, y);

      gfx.FillColor(255, 255, 255, alpha);
      gfx.DrawLabel(control['action'], x + 700, y);

      if (i ~= #self['labels']['songSelect']) then
        gfx.BeginPath();
        gfx.FillColor(60, 110, 160, math.floor(100 * self['timer']))
        gfx.FastRect(x + 1, y + 34, scaledW / 1.7, 1);
        gfx.Fill();
      end

      y = y + 38;
    end

    gfx.FillColor(60, 110, 160, alpha);
    gfx.DrawLabel(self['labels']['gameplaySettingsHeading'], 0, y + 22);

    gfx.BeginPath();
    gfx.FillColor(255, 255, 255, alpha);
    gfx.FastRect(x - 75, y + 32, 4, scaledH / 5);
    gfx.Fill();

    y = y + 25;

    for i, control in ipairs(self['labels']['gameplaySettings']) do
      gfx.FillColor(60, 110, 160, alpha);
      gfx.DrawLabel(control['controller'], x, y);
  
      gfx.DrawLabel(control['keyboard'], x + 350, y);

      gfx.FillColor(255, 255, 255, alpha);
      gfx.DrawLabel(control['action'], x + 700, y);

      if (i ~= #self['labels']['gameplaySettings']) then
        gfx.BeginPath();
        gfx.FillColor(60, 110, 160, math.floor(100 * self['timer']))
        gfx.FastRect(x + 1, y + 34, scaledW / 1.7, 1);
        gfx.Fill();
      end

      y = y + 38;
    end

    gfx.Restore();
  end

  self.render = function(self, deltaTime)
    gfx.Save();

    self:setAllSizes();
    self:setLabels();

    self['showingControls'] = false;

    self:drawButton(deltaTime);
    self:drawControls();

    if (not self['showingControls'] and self['timer'] > 0) then
      self['timer'] = math.max(self['timer'] - (deltaTime * 6), 0);
    end

    gfx.Restore();
  end
end


if (not allInitialized) then
  clears:initialize();
  grades:initialize();
  songGrid:initialize();
  songInfo:initialize();
  search:initialize();
  controls:initialize();

  allInitialized = true;
end

render = function(deltaTime)
  gfx.Save();

  setupLayout();

  mousePosX, mousePosY = game.GetMousePos();

  gfx.BeginPath();
  gfx.ImageRect(0, 0, scaledW, scaledH, background, 1, 0);

  songGrid:render(deltaTime);
  songInfo:render(deltaTime);
  search:render(deltaTime);
  controls:render(deltaTime);

  gfx.Restore();
end

get_page_size = function()
  return 9;
end

set_index = function(newSongIndex)
  songGrid:setSongIndex(newSongIndex);
  songInfo:setSongIndex(newSongIndex);

  if (previousSongIndex ~= newSongIndex) then
    game.PlaySample('menu_click');
  end

  previousSongIndex = newSongIndex;
end

set_diff = function(newDifficultyIndex)
  songGrid:setDifficulty(newDifficultyIndex);
  songInfo:setDifficulty(newDifficultyIndex);

  if (previousDifficultyIndex ~= newDifficultyIndex) then
    game.PlaySample('click-02');
  end

  previousDifficultyIndex = newDifficultyIndex;
end

totalForce = nil

local badgeRates = {
	0.5,  -- Played
	1.0,  -- Cleared
	1.02, -- Hard clear
	1.04, -- UC
	1.1   -- PUC
}

local gradeRates = {
	{['min'] = 9900000, ['rate'] = 1.05}, -- S
	{['min'] = 9800000, ['rate'] = 1.02}, -- AAA+
	{['min'] = 9700000, ['rate'] = 1},    -- AAA
	{['min'] = 9500000, ['rate'] = 0.97}, -- AA+
	{['min'] = 9300000, ['rate'] = 0.94}, -- AA
	{['min'] = 9000000, ['rate'] = 0.91}, -- A+
	{['min'] = 8700000, ['rate'] = 0.88}, -- A
	{['min'] = 7500000, ['rate'] = 0.85}, -- B
	{['min'] = 6500000, ['rate'] = 0.82}, -- C
	{['min'] =       0, ['rate'] = 0.8}   -- D
}

calculate_force = function(diff)
	if #diff.scores < 1 then
		return 0
	end
	local score = diff.scores[1]
	local badgeRate = badgeRates[diff.topBadge]
	local gradeRate
    for i, v in ipairs(gradeRates) do
      if score.score >= v.min then
        gradeRate = v.rate
		break
      end
    end
	return math.floor((diff.level * 2) * (score.score / 10000000) * gradeRate * badgeRate) / 100
end

songs_changed = function(withAll)
	if (not withAll) then return end;

	local diffs = {}
	for i = 1, #songwheel.allSongs do
		local song = songwheel.allSongs[i]
		for j = 1, #song.difficulties do
			local diff = song.difficulties[j]
			diff.force = calculate_force(diff)
			table.insert(diffs, diff)
		end
	end
	table.sort(diffs, function (l, r)
		return l.force > r.force
	end)
	totalForce = 0
	for i = 1, 50 do
		if diffs[i] then
			totalForce = totalForce + diffs[i].force
		end
	end
end
