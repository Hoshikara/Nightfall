local CONSTANTS = require('constants/songwheel');

local cursor = require('songselect/cursor');
local easing = require('lib/easing');
local volforce = require('songselect/volforce');

local background = cacheImage('bg.png');

local jacketFallback = gfx.CreateSkinImage('song_select/loading.png', 0);

local previousDifficultyIndex = 1;
local previousSongIndex = 1;

game.LoadSkinSample('menu_click');
game.LoadSkinSample('click-02');
game.LoadSkinSample('woosh');

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

local labelHeight = {
  artist = 0,
  bpm = 0,
  clear = 0,
  effector = 0,
  grade = 0,
  title = 0,
};

local songCache = {};

verifySongCache = function(song)
  if (not songCache[song.id]) then
    songCache[song.id] = {};
  end

  font.jp();

  if (not songCache[song.id].title) then
    songCache[song.id].title = cacheLabel(string.upper(song.title), 36);

    if (labelHeight.title == 0) then
      labelHeight.title = songCache[song.id].title.h;
    end
  end

  if (not songCache[song.id].artist) then
    songCache[song.id].artist = cacheLabel(string.upper(song.artist), 36);

    if (labelHeight.artist == 0) then
      labelHeight.artist = songCache[song.id].artist.h;
    end
  end

  if (labelHeight.effector == 0) then
    local tempLabel = cacheLabel('EFFECTOR', 24);

    labelHeight.effector = tempLabel.h;
  end

  font.number();

  if (not songCache[song.id].bpm) then
    songCache[song.id].bpm = cacheLabel(tostring(song.bpm), 24);

    if (labelHeight.bpm == 0) then
      font.medium();

      local tempLabel = cacheLabel('100', 24);

      labelHeight.bpm = tempLabel.h;
      labelHeight.grade = labelHeight.bpm;
      labelHeight.clear = labelHeight.bpm;
    end
  end
end

verifySongCacheEffector = function(song, difficultyIndex)
  local difficulty = song.difficulties[difficultyIndex];

  if (not difficulty) then
    difficulty = song.difficulties[1];
  end

  if (not songCache[song.id].effector) then
    songCache[song.id].effector = {};
  end

  font.jp();

  if (not songCache[song.id].effector[difficultyIndex]) then
    songCache[song.id].effector[difficultyIndex] = cacheLabel(
      string.upper(difficulty.effector), 24
    );
  end
end

local clears = {
  labels = {},

  getClear = function(self, difficulty)
    local label = nil;

    if (difficulty.scores[1]) then
      if (difficulty.topBadge ~= 0) then
        label = self.labels[difficulty.topBadge];
      end
    end

    return label;
  end
};

do
  for index, clear in ipairs(CONSTANTS.clears) do
    clears.labels[index] = cacheLabel(clear, 24);
  end
end

local grades = {
  breakpoints = {},

  getGrade = function(self, difficulty)
    local label = nil;

    if (difficulty.scores[1]) then
      local highScore = difficulty.scores[1];

      for _, breakpoint in ipairs(self.breakpoints) do
        if (highScore.score >= breakpoint.minimum) then
          label = breakpoint.label;
          break;
        end
      end
    end

    return label;
  end
};

do
  font.normal();

  for index, current in ipairs(CONSTANTS.grades) do
    grades.breakpoints[index] = {
      minimum = current.minimum,
      label = cacheLabel(current.grade, 24),
    };
  end
end

local songGrid = {
  cache = { scaledW = 0, scaledH = 0 },
  cursor = {
    alpha = 0,
    animTimer = 0,
    animTotal = 0.1,
    displayPos = 0,
    flickerTimer = 0,
    pos = 0,
    timer = 0,
  },
  easing = {
    grid = {
      duration = 0.2,
      initial = 0,
      timer = 0,
    },
    scrollbar = {
      duration = 0.2,
      initial = 0,
      timer = 0,
    },
  },
  grid = {
    gutter = 0,
    size = 0,
    x = 0,
    y = 0,
  },
  jacketSize = 0,
  labels = nil,
  numColumns = 3,
  numRows = 3,
  rowOffset = 0,
  scrollbar = {
    height = 0,
    pos = 0,
    x = 0,
    y = 0,
  },
  selectedDifficulty = 0,
  selectedSongIndex = 1,

  setSizes = function(self)
    if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
      self.jacketSize = scaledH / 4;
      self.grid.gutter = self.jacketSize / 8;
      self.grid.size = (self.jacketSize + self.grid.gutter) * 4;
      self.grid.x = scaledW - self.grid.size + (self.grid.gutter * 7);
      self.grid.y = self.jacketSize - (self.grid.gutter * 3.75);

      self.labels.spacing = (self.jacketSize * 2) / 3.5;
      self.labels.x = {
        self.grid.x,
        (self.jacketSize * 1.5) + self.grid.gutter,
        ((self.jacketSize * 1.5) + self.grid.gutter) / 2,
      };
      self.labels.y = scaledH / 20;

      self.scrollbar.height = (self.jacketSize * 3) + (self.grid.gutter * 2);
      self.scrollbar.x = scaledW - (self.grid.gutter * 1.5);
      self.scrollbar.y = self.grid.y;
      
      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
  end,

  setDifficulty = function(self, newDifficulty)
    self.selectedDifficulty = newDifficulty;
  end,

  setLabels = function(self)
    if (not self.labels) then
      font.medium();

      self.labels = {
        of = cacheLabel('OF', 18),
      };

      for name, str in pairs(CONSTANTS.labels.grid) do
        self.labels[name] = cacheLabel(str, 18);
      end

      font.number();

      self.labels.currentSong = cacheLabel('', 18);
      self.labels.totalSongs = cacheLabel('', 18);
    end
  end,

  setRowOffset = function(self, newRowOffset)
    self.easing.grid.initial = self.rowOffset;
    self.easing.grid.timer = self.easing.grid.duration;
    self.rowOffset = newRowOffset;
  end,

  setScrollbarPos = function(self, completion)
    self.easing.scrollbar.initial = self.scrollbar.pos;
    self.easing.scrollbar.timer = self.easing.scrollbar.duration;
    self.scrollbar.pos = self.scrollbar.y + (completion * (self.scrollbar.height - 32));
  end,

  setSongIndex = function(self, newSongIndex)
    local delta = newSongIndex - self.selectedSongIndex;

    if ((delta < -1) or (delta > 1)) then
      local newOffset = newSongIndex - 1;

      self:setRowOffset(math.floor((newSongIndex - 1) / self.numColumns) * self.numColumns);
      self.cursor.pos = (newSongIndex - 1) - self.rowOffset;
      self.cursor.displayPos = self.cursor.pos;
    else
      local newCursorPos = self.cursor.pos + delta;

      if (newCursorPos < 0) then
        self:setRowOffset(self.rowOffset - self.numColumns);

        newCursorPos = newCursorPos + self.numColumns;
      elseif (newCursorPos >= (self.numColumns * self.numColumns)) then
        self:setRowOffset(self.rowOffset + self.numColumns);

        newCursorPos = newCursorPos - self.numColumns;
      end

      if (self.cursor.animTimer > 0) then
        self.cursor.displayPos = easing.outQuad(
          0.5 - self.cursor.animTimer,
          self.cursor.displayPos,
          self.cursor.pos - self.cursor.displayPos,
          0.5
        );
      end

      self.cursor.animTimer = self.cursor.animTotal;
      self.cursor.pos = newCursorPos;
    end

    if (self.selectedSongIndex ~= newSongIndex) then
      self.cursor.flickerTimer = 0;
    end

    self.selectedSongIndex = newSongIndex;

    self:setScrollbarPos((self.rowOffset + self.cursor.pos) / (#songwheel.songs - 1));
  end,

  getCurrentRowOffset = function(self)
    return easing.outQuad(
      self.easing.grid.duration - self.easing.grid.timer,
      self.easing.grid.initial,
      self.rowOffset - self.easing.grid.initial,
      self.easing.grid.duration
    );
  end,

  getCursorPosition = function(self, position, yOffset)
    local whichColumn = position % self.numColumns;
    local whichRow = math.floor(position / self.numColumns) + (yOffset or 0);
    local x = self.grid.x + whichColumn * (self.grid.size / 4);
    local y = self.grid.y + whichRow * (self.grid.size / 4);

    return x, y;
  end,

  getScrollbarPos = function(self)
    return easing.outQuad(
      self.easing.scrollbar.duration - self.easing.scrollbar.timer,
      self.easing.scrollbar.initial,
      self.scrollbar.pos - self.easing.scrollbar.initial,
      self.easing.scrollbar.duration
    );
  end,

  drawAllSongs = function(self, deltaTime)
    if (self.easing.grid.timer > 0) then
      self.easing.grid.timer = math.max(self.easing.grid.timer - deltaTime, 0);
    end

    for i = 0, (self.numRows + 1)  do
      for v = 1, self.numColumns do
        local tempIndex = ((i - 1) * 3) + v;
        local index = self.rowOffset + tempIndex;
        local yOffset = (self.rowOffset - self:getCurrentRowOffset()) / 3;

        if (index <= #songwheel.songs) then
          self:drawSong(deltaTime, tempIndex - 1, index, yOffset);
        end
      end
    end
  end,

  drawCursor = function(self, deltaTime)
    self.cursor.timer = self.cursor.timer + deltaTime;
    self.cursor.flickerTimer = self.cursor.flickerTimer + deltaTime;

    self.cursor.alpha = math.floor(self.cursor.flickerTimer * 30) % 2;
    self.cursor.alpha = (self.cursor.alpha * 255) / 255;

    if (self.cursor.flickerTimer >= 0.3) then
      self.cursor.alpha = math.abs(0.8 * math.cos(self.cursor.timer * 5)) + 0.2;
    end

    local position = self.cursor.displayPos;

    if (self.cursor.animTimer > 0) then
      self.cursor.animTimer = self.cursor.animTimer - deltaTime;

      if (self.cursor.animTimer <= 0) then
        self.cursor.displayPos = self.cursor.pos;

        position = self.cursor.pos;
      else
        position = easing.outQuad(
          self.cursor.animTotal - self.cursor.animTimer,
          self.cursor.displayPos,
          self.cursor.pos - self.cursor.displayPos,
          self.cursor.animTotal
        );
      end
    end

    local x, y = self:getCursorPosition(position);

    gfx.Save();

    gfx.Translate(x, y);

    cursor:drawSongCursor(0, 0, self.jacketSize, self.jacketSize, 8, self.cursor.alpha);

    gfx.Restore();
  end,

  drawLabels = function(self)
    gfx.Save();
  
    local x = 0;

    gfx.Translate(self.labels.x[1] - 4, self.labels.y - 4);

    gfx.BeginPath();
    align.left();
    fill.normal();

    self.labels.collection:draw({ x = x, y = 0 });

    x = x + self.labels.x[2];

    self.labels.difficulty:draw({ x = x, y = 0 });

    x = x + self.labels.x[3];
  
    self.labels.sort:draw({ x = x, y = 0 });

    gfx.Restore();
  end,

  drawNoSongMessage = function(self)
    gfx.Save();

    gfx.Translate(
      self.grid.x + ((self.grid.size - self.grid.gutter * 10) / 2),
      (scaledH / 2) + self.grid.gutter
    );

    gfx.BeginPath();
    align.middle();
    font.normal();
    fill.white();
    gfx.FontSize(48);
    gfx.Text('NO SONGS FOUND', 0, 0);

    gfx.Restore();
  end,

  drawScrollbar = function(self, deltaTime)
    if (self.easing.scrollbar.timer > 0) then
      self.easing.scrollbar.timer = math.max(self.easing.scrollbar.timer - deltaTime, 0);
    end

    local y = self:getScrollbarPos();
    local barPos = ((y > 0) and y) or -100;

    gfx.BeginPath();
    fill.dark(120);
    gfx.Rect(self.scrollbar.x, self.scrollbar.y, 8, self.scrollbar.height);
    gfx.Fill();

    gfx.BeginPath();
    fill.normal();
    gfx.Rect(self.scrollbar.x, barPos, 8, 32);
    gfx.Fill();
  end,

  drawSongAmount = function(self)
    font.number();
    self.labels.currentSong:update({ new = string.format('%04d', self.selectedSongIndex) });
    self.labels.totalSongs:update({ new = string.format('%04d', #songwheel.songs) });

    gfx.Save();

    gfx.Translate(
      scaledW - self.grid.gutter * 1.25,
      scaledH - self.grid.gutter - 6
    );

    gfx.BeginPath();
    fill.normal();
    align.right();
    self.labels.currentSong:draw({ x = -(self.labels.of.w + self.labels.totalSongs.w + 16), y = 0 });
    self.labels.of:draw({ x = -(self.labels.totalSongs.w + 8), y = 0 });
    self.labels.totalSongs:draw({ x = 0, y = 0 });

    gfx.Restore();
  end,

  drawSong = function(self, deltaTime, position, songIndex, yOffset)
    if (songIndex < 1) then return end;

    local song = songwheel.songs[songIndex];

    local isSelected = songIndex == self.selectedSongIndex;
    local jacketAlpha = (isSelected and 1) or 0.2;

    if (not song) then return end;

    verifySongCache(song);

    local difficulty = song.difficulties[self.selectedDifficulty];

    if (not difficulty) then
      difficulty = song.difficulties[1];
    end

    if ((not songCache[song.id][self.selectedDifficulty])
      or (songCache[song.id][self.selectedDifficulty] == jacketFallback)) then
        songCache[song.id][self.selectedDifficulty] = gfx.LoadImageJob(
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

    if (songCache[song.id][self.selectedDifficulty]) then
      gfx.BeginPath();
      fill.black();
      gfx.Rect(0, 0, self.jacketSize, self.jacketSize);
      gfx.Fill();

      gfx.BeginPath();
      gfx.StrokeWidth(2);
      
      if (isSelected) then
        gfx.StrokeColor(60, 110, 160, 255);
      else
        gfx.StrokeColor(4, 8, 12, 255);
      end

      gfx.ImageRect(
        0, 
        0, 
        self.jacketSize, 
        self.jacketSize, 
        songCache[song.id][self.selectedDifficulty], 
        jacketAlpha,
        0
      );
      gfx.Stroke();
    end

     gfx.Restore();
  end,

  render = function(self, deltaTime)
    self:setLabels();

    self:setSizes();

    gfx.Save();

    gfx.Scissor(
      self.grid.x - (self.grid.gutter),
      self.grid.gutter * 3.5,
      self.grid.size - self.grid.gutter * 8,
      self.grid.size - self.grid.gutter * 8.4
    );

    self:drawAllSongs(deltaTime);

    if (songwheel.songs[self.selectedSongIndex]) then
      self:drawCursor(deltaTime);
    else
      self:drawNoSongMessage();
    end

    gfx.ResetScissor();

    if (songwheel.songs[self.selectedSongIndex]) then
      self:drawSongAmount();
    end

    self:drawLabels();
    self:drawScrollbar(deltaTime);

    gfx.Restore();
  end
};

local songInfo = {
  cache = { scaledW = 0, scaledH = 0 },
  cursor = {
    alpha = 0,
    flickerTimer = 0,
    pos = 0,
    selected = 0,
    timer = 0,
    x = 0,
    y = {},
  },
  difficulties = nil,
  highScore = 0,
  images = {
    button = cacheImage('song_select/button.png'),
    buttonHover = cacheImage('song_select/button_hover.png'),
    panel = cacheImage('song_select/panel.png')
  },
  jacketSize = 0,
  labels = nil,
  levels = nil,
  order = {
    conditional = { 'grade', 'clear' },
    main = {
      'title',
      'artist',
      'effector',
      'bpm',
    },
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
  selectedDifficulty = 0,
  selectedSongIndex = 0,
  scrollTimers = {
    artist = 0,
    effector = 0,
    title = 0,
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

      self.panel.innerWidth = self.panel.w - (self.padding.x.double * 2);

      self.labels.x = self.padding.x.double;
      self.labels.y = self.padding.y.double + self.jacketSize;

      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
  end,

  setDifficulty = function(self, newDifficulty)
    if (self.selectedDifficulty ~= newDifficulty) then
      self.cursor.flickerTimer = 0;
    end

    self.selectedDifficulty = newDifficulty;
  end,

  setLabels = function(self)
    if (not self.labels) then
      font.number();

      self.difficulties = {};
      self.highScore = {
        cacheLabel('', 90),
        cacheLabel('', 72)
      };
      self.labels = {
        order = {
          conditional = { 'grade', 'clear' },
          main = {
            'title',
            'artist',
            'effector',
            'bpm',
          },
        },
      };
      self.levels = {};

      for index, level in pairs(CONSTANTS.levels) do
        self.levels[index] = cacheLabel(level, 18);
      end

      font.medium();

      for index, name in pairs(CONSTANTS.difficulties) do
        self.difficulties[index] = cacheLabel(name, 18);
      end

      for name, str in pairs(CONSTANTS.labels.info) do
        self.labels[name] = cacheLabel(str, 18);
      end
    end
  end,

  setSongIndex = function(self, newSongIndex)
    self.selectedSongIndex = newSongIndex;
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

  drawJacket = function(self, song, difficulty)
    gfx.Save();

    if ((not songCache[song.id][self.selectedDifficulty])
      or (songCache[song.id][self.selectedDifficulty] == jacketFallback)) then
        songCache[song.id][self.selectedDifficulty] = gfx.LoadImageJob(
          difficulty.jacketPath,
          jacketFallback,
          self.jacketSize,
          self.jacketSize
        );
    end

    if (songCache[song.id][self.selectedDifficulty]) then
      gfx.BeginPath();
      gfx.StrokeWidth(2);
      gfx.StrokeColor(60, 110, 160, 255);
      gfx.ImageRect(
        self.padding.x.double,
        self.padding.y.full,
        self.jacketSize,
        self.jacketSize,
        songCache[song.id][self.selectedDifficulty],
        1,
        0
      );
      gfx.Stroke();
    end

    gfx.Restore();
  end,

  drawLabels = function(self, song)
    gfx.Save();

    local baseLabelHeight = self.labels.title.h;
    local y = self.labels.y - 4;

    gfx.BeginPath();
    align.left();
    fill.normal();

    self.labels.difficulty:draw({
      x = self.padding.x.double + self.jacketSize + self.padding.x.full + 6,
      y = self.padding.y.full - 4
    });

    for _, name in ipairs(self.labels.order.main) do
      self.labels[name]:draw({
        x = self.labels.x,
        y = y
      });

      y = y
        + baseLabelHeight
        + self.padding.y.quarter
        + labelHeight[name]
        + self.padding.y.half
        - 4;
    end

    if (song) then
      local difficulty = song.difficulties[self.selectedDifficulty];

      if (not difficulty) then
        difficulty = song.difficulties[1];
      end

      if (grades:getGrade(difficulty)) then
        for _, name in ipairs(self.labels.order.conditional) do
          self.labels[name]:draw({ x = self.labels.x, y = y });

          y = y 
            + baseLabelHeight
            + self.padding.y.quarter
            + labelHeight[name]
            + self.padding.y.half
            - 4;
        end
      end
    end

    gfx.Restore();
  end,

  drawSongInfo = function(self, deltaTime, id, difficulty)
    local baseLabelHeight = self.labels.title.h;
    local y = self.labels.y + baseLabelHeight + self.padding.y.quarter - 8;
    local clearLabel = clears:getClear(difficulty);
    local gradeLabel = grades:getGrade(difficulty);

    gfx.Save();

    gfx.BeginPath();
    align.left();
    fill.white();

    for _, name in ipairs(self.order.main) do
      local currentLabel = ((name == 'effector') and songCache[id][name][self.selectedDifficulty])
        or songCache[id][name];
      local doesOverflow = currentLabel.w > self.panel.innerWidth;
  
      if (doesOverflow and self.scrollTimers[name] ~= nil) then
        self.scrollTimers[name] = self.scrollTimers[name] + deltaTime;

        drawScrollingLabel(
          self.scrollTimers[name],
          currentLabel,
          self.panel.innerWidth,
          self.labels.x,
          y,
          scalingFactor,
          {255, 255, 255, 255}
        );
      else
        currentLabel:draw({ x = self.labels.x, y = y - 1 });
      end

      y = y
        + labelHeight[name]
        + self.padding.y.half
        + baseLabelHeight
        + self.padding.y.quarter
        - 4;
    end

    if (clearLabel and gradeLabel) then
      for _, name in ipairs(self.order.conditional) do
        local currentLabel = ((name == 'grade') and gradeLabel) or clearLabel;

        currentLabel:draw({ x = self.labels.x, y = y });

        y = y
          + labelHeight[name]
          + self.padding.y.half
          + baseLabelHeight
          + self.padding.y.quarter
          - 4;
      end

      local highScore = difficulty.scores[1].score;
      local scoreText = string.format('%08d', highScore);

      font.number();
      self.highScore[1]:update({ new = string.sub(scoreText, 1, 4) });
      self.highScore[2]:update({ new = string.sub(scoreText, -4) });
      
      gfx.BeginPath();

      local x = self.labels.x + (self.padding.x.double * 2.4);
      local y = scaledH - (scaledH / 20) - (self.padding.y.double * 2.15);

      align.left();
      fill.normal();
      self.labels.highScore:draw({ x = x, y = y });

      y = y + (self.padding.y.quarter / 2) + 2;

      fill.white();
      self.highScore[1]:draw({ x = x - 4, y = y });

      fill.normal();
      self.highScore[2]:draw({ x = x + self.highScore[1].w, y = y + self.padding.y.half - 6 });
    end

    gfx.Restore();
  end,

  drawDifficulty = function(self, currentDifficulty, isSelected, y)
    local x = self.cursor.x;
    local alpha = math.floor(255 * ((isSelected and 1) or 0.2));

    gfx.Save();

    if (isSelected) then
      self.images.buttonHover:draw({ x = x, y = y });
    else
      self.images.button:draw({ x = x, y = y, a = 0.45 });
    end

    if (currentDifficulty) then
      gfx.BeginPath();
      align.left();
      fill.white(alpha);
      self.difficulties[currentDifficulty.difficulty + 1]:draw({
        x = x + 36,
        y = y + (self.images.button.h / 2.85),
      });

      align.right();
      self.levels[currentDifficulty.level]:draw({
        x = x + self.images.button.w - 36,
        y = y + (self.images.button.h / 2.85),
      });
    end

    gfx.Restore();

    return (y + self.images.button.h + 6);
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

    self.cursor.pos = self.cursor.pos - (self.cursor.pos - y) * deltaTime * 36;

    gfx.BeginPath();

    cursor:drawDifficultyCursor(self.cursor.x, self.cursor.pos, 222, 74, 4, self.cursor.alpha);

    gfx.Restore();
  end,

  drawSongInfoPanel = function(self, deltaTime)
    local song = songwheel.songs[self.selectedSongIndex];

    gfx.Save();

    gfx.Translate(self.panel.x, self.panel.y);

    self.images.panel:draw({
      x = 0,
      y = 0,
      a = 0.65,
    });

    self:drawLabels(song);

    gfx.Restore();

    if (not song) then return end;

    gfx.Save();

    verifySongCache(song);
    verifySongCacheEffector(song, self.selectedDifficulty);

    local difficulty = song.difficulties[self.selectedDifficulty];

    if (not difficulty) then
      difficulty = song.difficulties[1];
    end

    gfx.Translate(self.panel.x, self.panel.y);

    self:drawJacket(song, difficulty);

    self:drawSongInfo(deltaTime, song.id, difficulty);

    local difficultyY = self.padding.y.double + self.labels.difficulty.h - 24;

    for index = 1, 4 do
      local level = self:getDifficulty(song.difficulties, index);
      local isSelected = difficulty.difficulty == (index - 1);

      if (isSelected) then
        self.cursor.selected = index;
      end

      self.cursor.y[index] = difficultyY;
      difficultyY = self:drawDifficulty(level, isSelected, difficultyY);
    end

    self:drawCursor(deltaTime, self.cursor.y[self.cursor.selected]);
    
    gfx.Restore();
  end,

  render = function(self, deltaTime)
    self:setLabels();

    self:setSizes();

    gfx.Save();

    self:drawSongInfoPanel(deltaTime);

    gfx.Restore();
  end
};

local search = {
  alpha = 0,
  cache = {
    scaledW = 0,
    scaledH = 0,
  },
  cursor = {
    timer = 0,
    alpha = 0,
  },
  index = 1,
  labels = nil,
  w = 0,
  h = 0,
  x = 0,
  y = 0,
  timer = 0,

  setSizes = function(self)
    if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
      self.w = songInfo.panel.w + 6;
      self.h = (songGrid.grid.gutter * 1.5);
      self.x = scaledW / 20;
      self.y = scaledH / 40;

      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
  end,

  setLabels = function(self)
    if (not self.labels) then
      font.medium();

      self.labels = {
        search = cacheLabel('SEARCH', 18),
      };

      font.jp();

      self.labels.input = cacheLabel('', 24);
    end
  end,

  drawSearch = function(self, deltaTime)
    gfx.Save();
  
    local acceptInput = songwheel.searchInputActive;
    local shouldShow = (string.len(songwheel.searchText) > 0) or songwheel.searchInputActive;

    if (shouldShow) then
      self.timer = math.min(self.timer + (deltaTime * 6), 1);
      self.cursor.timer = self.cursor.timer + deltaTime;
    elseif (self.timer > 0 and (not shouldShow)) then
      self.timer = math.max(self.timer - (deltaTime * 6), 0);
      self.cursor.timer = 0;
    end

    self.alpha = math.floor(255 * math.min(self.timer * 2, 1));
    self.cursor.alpha = (acceptInput and math.abs(0.9 * math.cos(self.cursor.timer * 5)) + 0.1) or 0;

    font.jp();
    self.labels.input:update({ new = string.upper(songwheel.searchText) });

    local cursorOffset = math.min(self.labels.input.w + 2, self.w - 24);

    if (self.index ~= ((acceptInput and 0) or 1)) then
      game.PlaySample('woosh');
    end

    self.index = (acceptInput and 0) or 1;

    gfx.BeginPath();
    fill.black(150);
    gfx.FastRect(self.x + 2, self.y - 6, (self.w - 8) * self.timer, self.h + 12);
    gfx.Fill();

    if (acceptInput) then
      gfx.BeginPath();
      gfx.StrokeWidth(2);
      gfx.StrokeColor(60, 110, 160, self.alpha);
      fill.black(0);
      gfx.Rect(self.x + 2, self.y - 6, (self.w - 8) * self.timer, self.h + 12);
      gfx.Fill();
      gfx.Stroke();
    end

    gfx.BeginPath();
    align.left();
    fill.normal(self.alpha);
    self.labels.search:draw({ x = self.x + 8, y = self.y - 4 });

    if (shouldShow) then
      gfx.BeginPath();
      fill.white(255 * self.cursor.alpha);
      gfx.FastRect(self.x + 8 + cursorOffset, self.y + (self.h / 2) - 4, 2, 28 );
      gfx.Fill();

      gfx.BeginPath();
      align.left();
      fill.white();
      self.labels.input:draw({
        x = self.x + 8,
        y = self.y + 20,
        maxWidth = self.w - 24,
      });
    end

    gfx.Restore();
  end,

  render = function(self, deltaTime)
    self:setSizes();

    self:setLabels();

    gfx.Save();

    self:drawSearch(deltaTime);

    gfx.Restore();
  end
};

local miscInfo = {
  labels = nil,

  render = function(self)
    if (not self.labels) then
      font.medium();
  
      self.labels = {
        bta = cacheLabel('[BT-A]', 20),
        showControls = cacheLabel('SHOW CONTROLS', 20),
        volforce = {
          label = cacheLabel('VF', 20),
        },
      };

      font.number();
      self.labels.volforce.value = cacheLabel('', 20);
    end

    local y = self.labels.bta.h - 6;
  
    gfx.Save();
  
    gfx.Translate((scaledW / 20) - 1, scaledH - (scaledH / 20));

    gfx.BeginPath();
    align.left();
    fill.normal();
    self.labels.bta:draw({ x = 0, y = y });

    fill.white();
    self.labels.showControls:draw({ x = self.labels.bta.w + 8, y = y + 1 });

    local forceValue = totalForce or game.GetSkinSetting('cachedVolforce');

    gfx.Translate(songInfo.panel.w + 2, 0);

    font.number();
    self.labels.volforce.value:update({ new = string.format('%.2f', forceValue) });

    gfx.BeginPath();
    align.right();
    fill.normal();
    self.labels.volforce.label:draw({ x = 0, y = y });

    fill.white();
    self.labels.volforce.value:draw({ x = -(self.labels.volforce.label.w + 8), y = y });

    gfx.Restore();
  end
};

render = function(deltaTime)
  setupLayout();

  gfx.Save();

  background:draw({
    x = 0,
    y = 0,
    w = scaledW,
    h = scaledH,
  });

  songGrid:render(deltaTime);
  songInfo:render(deltaTime);
  search:render(deltaTime);
  miscInfo:render();

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

totalForce = nil;

calculateForce = function(diff)
  if (#diff.scores < 1) then
    return 0;
  end

  local score = diff.scores[1];

  return volforce(score.score, diff.topBadge, diff.level);
end

songs_changed = function(withAll)
	if (not withAll) then return end;

  local diffs = {};

	for i = 1, #songwheel.allSongs do
    local song = songwheel.allSongs[i];

		for j = 1, #song.difficulties do
      local diff = song.difficulties[j];
  
      diff.force = calculateForce(diff);

			table.insert(diffs, diff);
		end
  end
  
	table.sort(diffs, function (l, r)
		return (l.force > r.force);
  end)

  totalForce = 0;

	for i = 1, 50 do
		if (diffs[i]) then
			totalForce = totalForce + diffs[i].force;
		end
  end
  
  game.SetSkinSetting('cachedVolforce', totalForce);
end
