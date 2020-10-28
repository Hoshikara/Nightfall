local CONSTANTS = require('constants/songwheel');

local ScoreNumber = require('common/scorenumber');

local easing = require('lib/easing');
local volforce = require('songselect/volforce');

local background = Image.New('bg.png');

local controlsShortcut = game.GetSkinSetting('controlsShortcut') or false;

local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

local previousDifficultyIndex = 1;
local previousSongIndex = 1;

game.LoadSkinSample('click_difficulty');
game.LoadSkinSample('click_song');
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

local labelHeight = nil;

do
  if (not labelHeight) then
    Font.JP();

    local artist = Label.New('ARTIST', 36);
    local effector = Label.New('EFFECTOR', 24);
    local title = Label.New('TITLE', 36);

    Font.Medium();

    local bpm = Label.New('BPM', 24);
    local clear = Label.New('CLEAR', 24);
    local grade = Label.New('GRADE', 24);

    labelHeight = {
      artist = artist.h,
      bpm = bpm.h,
      clear = clear.h,
      effector = effector.h,
      grade = grade.h,
      title = title.h,
    };
  end
end

local songCache = {};

verifySongCache = function(song)
  if (not songCache[song.id]) then
    songCache[song.id] = {};

    Font.JP();

    songCache[song.id].artist = Label.New(string.upper(song.artist), 36);
    songCache[song.id].title = Label.New(string.upper(song.title), 36);
    
    Font.Number();

    songCache[song.id].bpm = Label.New(tostring(song.bpm), 24);
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

  Font.JP();

  if (not songCache[song.id].effector[difficultyIndex]) then
    songCache[song.id].effector[difficultyIndex] =
      Label.New(string.upper(difficulty.effector), 24);
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
  Font.Normal();

  for index, clear in ipairs(CONSTANTS.clears) do
    clears.labels[index] = Label.New(clear, 24);
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
  Font.Normal();

  for index, current in ipairs(CONSTANTS.grades) do
    grades.breakpoints[index] = {
      minimum = current.minimum,
      label = Label.New(current.grade, 24),
    };
  end
end

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
    button = Image.New('buttons/short.png'),
    buttonHover = Image.New('buttons/short_hover.png'),
    panel = Image.New('common/panel.png')
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
    innerWidth = 0,
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

      self.panel.w = scaledW / (1920 / self.images.panel.w);
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
      Font.Number();

      self.difficulties = {};
      self.highScore = ScoreNumber.New({
        isScore = true,
        sizes = { 90, 72 }
      });
      self.labels = {};
      self.levels = {};

      for index, level in pairs(CONSTANTS.levels) do
        self.levels[index] = Label.New(level, 18);
      end

      Font.Medium();

      for index, name in pairs(CONSTANTS.difficulties) do
        self.difficulties[index] = Label.New(name, 18);
      end

      for name, str in pairs(CONSTANTS.labels.info) do
        self.labels[name] = Label.New(str, 18);
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
    FontAlign.Left();

    self.labels.difficulty:draw({
      x = self.padding.x.double + self.jacketSize + self.padding.x.full + 4,
      y = self.padding.y.full - 4,
      color = 'Normal',
    });

    for _, name in ipairs(self.order.main) do
      self.labels[name]:draw({
        x = self.labels.x,
        y = y,
        color = 'Normal',
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
        for _, name in ipairs(self.order.conditional) do
          self.labels[name]:draw({
            x = self.labels.x,
            y = y,
            color = 'Normal',
          });

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
    FontAlign.Left();

    for _, name in ipairs(self.order.main) do
      local currentLabel = songCache[id][name];

      if (name == 'effector') then
        currentLabel = songCache[id][name][self.selectedDifficulty];
      end

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
          'White',
          255
        );
      else
        currentLabel:draw({
          x = self.labels.x,
          y = y - 1,
          color = 'White',
        });
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

        currentLabel:draw({
          x = self.labels.x,
          y = y,
          color = 'White',
        });

        y = y
          + labelHeight[name]
          + self.padding.y.half
          + baseLabelHeight
          + self.padding.y.quarter
          - 4;
      end

      gfx.BeginPath();

      local x = self.labels.x + (self.padding.x.double * 2.4);
      local y = scaledH - (scaledH / 20) - (self.padding.y.double * 2.15);

      self.highScore:setInfo({ value = difficulty.scores[1].score });

      FontAlign.Left();
      self.labels.highScore:draw({
        x = x,
        y = y,
        color = 'Normal',
      });

      y = y + (self.padding.y.quarter / 2) + 2;

      self.highScore:draw({
        offset = 10,
        x = x - 4,
        y1 = y,
        y2 = y + self.padding.y.half - 6,
      });
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
      self.images.button:draw({
        x = x,
        y = y,
        a = 0.45,
      });
    end

    if (currentDifficulty) then
      gfx.BeginPath();
      FontAlign.Left();
      self.difficulties[currentDifficulty.difficulty + 1]:draw({
        x = x + 36,
        y = y + (self.images.button.h / 2.85),
        a = alpha,
        color = 'White',
      });

      FontAlign.Right();
      self.levels[currentDifficulty.level]:draw({
        x = x + self.images.button.w - 36,
        y = y + (self.images.button.h / 2.85),
        a = alpha,
        color = 'White',
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

    drawCursor({
			x = self.cursor.x + 10,
			y = self.cursor.pos + 10,
			w = self.images.button.w - 20,
			h = self.images.button.h - 20,
      alpha = self.cursor.alpha,
      size = 12,
			stroke = 1.5,
		});

    gfx.Restore();
  end,

  drawSongInfoPanel = function(self, deltaTime)
    local song = songwheel.songs[self.selectedSongIndex];

    gfx.Save();

    gfx.Translate(self.panel.x, self.panel.y);

    self.images.panel:draw({
      x = 0,
      y = 0,
      w = self.panel.w,
      h = self.panel.h,
      a = 0.5,
    });

    self:drawLabels(song);

    gfx.Restore();

    if (not song) then return end

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

      if (not self.cursor.y[index]) then
        self.cursor.y[index] = difficultyY;
      end

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
  order = {
    'collection',
    'difficulty',
    'sort',
  },
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
      self.grid.size = scaledW - ((scaledW / 20) * 3) - songInfo.panel.w;

      self.jacketSize = self.grid.size // 3.3;

      self.grid.gutter = (self.grid.size - (self.jacketSize * 3)) // 2;
      self.grid.x = (scaledW / 10) + songInfo.panel.w;
      self.grid.y = scaledH - (scaledH / 20) - self.grid.size;

      self.labels.x = {};
      self.labels.x[1] = self.grid.x - 1;
      self.labels.x[2] = self.labels.x[1] + (self.jacketSize * 1.5) + self.grid.gutter;
      self.labels.x[3] = self.labels.x[2] + (self.jacketSize * 0.9); 
      self.labels.y = (scaledH / 20) - 2;

      self.scrollbar.height = (self.jacketSize * 3) + (self.grid.gutter * 2);
      self.scrollbar.x = self.grid.x + self.grid.size + (scaledW / 40) - 4;
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
      Font.Medium();

      self.labels = {
        of = Label.New('OF', 18),
      };

      for name, str in pairs(CONSTANTS.labels.grid) do
        self.labels[name] = Label.New(str, 18);
      end

      Font.Number();

      self.labels.currentSong = Label.New('', 18);
      self.labels.totalSongs = Label.New('', 18);
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
    local x = self.grid.x + whichColumn * (self.jacketSize + self.grid.gutter);
    local y = self.grid.y + whichRow * (self.jacketSize + self.grid.gutter);

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


    drawCursor({
			x = 0,
			y = 0,
			w = self.jacketSize,
			h = self.jacketSize,
      alpha = self.cursor.alpha,
      size = 18,
			stroke = 1.5,
		});

    gfx.Restore();
  end,

  drawLabels = function(self)
    gfx.Save();
  
    gfx.BeginPath();
    FontAlign.Left();

    for i, name in ipairs(self.order) do
      self.labels[name]:draw({
        x = self.labels.x[i],
        y = self.labels.y,
        color = 'Normal',
      });
    end

    gfx.Restore();
  end,

  drawNoSongMessage = function(self)
    gfx.Save();

    gfx.Translate(
      self.grid.x + (self.grid.size / 2),
      self.grid.y + (self.grid.size / 2)
    );

    gfx.BeginPath();
    FontAlign.Middle();
    Font.Normal();
    gfx.FontSize(48);
    Fill.Dark(255 * 0.5);
    gfx.Text('NO SONGS FOUND', 1, 1);
    Fill.White();
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
    Fill.Dark(120);
    gfx.Rect(self.scrollbar.x, self.scrollbar.y, 8, self.scrollbar.height);
    gfx.Fill();

    gfx.BeginPath();
    Fill.Normal();
    gfx.Rect(self.scrollbar.x, barPos, 8, 32);
    gfx.Fill();
  end,

  drawSongAmount = function(self)
    Font.Number();

    self.labels.currentSong:update({
      new = string.format('%04d', self.selectedSongIndex)
    });
    self.labels.totalSongs:update({
      new = string.format('%04d', #songwheel.songs)
    });

    gfx.Save();

    gfx.Translate(
      self.grid.x + self.grid.size + (scaledW / 40) + 5,
      scaledH - (scaledH / 40) - 12
    );

    gfx.BeginPath();
    FontAlign.Right();
    self.labels.currentSong:draw({
      x = -(self.labels.of.w + self.labels.totalSongs.w + 16),
      y = 0,
      color = 'Normal',
    });
    self.labels.of:draw({
      x = -(self.labels.totalSongs.w + 8),
      y = 0,
      color = 'Normal',
    });
    self.labels.totalSongs:draw({
      x = 0,
      y = 0,
      color = 'Normal',
    });

    gfx.Restore();
  end,

  drawSong = function(self, deltaTime, position, songIndex, yOffset)
    if (songIndex < 1) then return end

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
      Fill.Black();
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
      self.grid.x - (self.grid.gutter * 0.9),
      self.grid.y - (self.grid.gutter * 0.9),
      self.grid.size + (self.grid.gutter * 1.8),
      self.grid.size + (self.grid.gutter * 1.8)
    )

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

    if (#songwheel.songs > 9) then
      self:drawScrollbar(deltaTime);
    end

    gfx.Restore();
  end
};

local search = {
  alpha = 0,
  cache = { scaledW = 0, scaledH = 0 },
  cursor = { alpha = 0, timer = 0 },
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
      self.h = scaledH / 22;
      self.x = scaledW / 20;
      self.y = scaledH / 40;

      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
  end,

  setLabels = function(self)
    if (not self.labels) then
      Font.Medium();

      self.labels = {
        search = Label.New('SEARCH', 18),
      };

      Font.JP();

      self.labels.input = Label.New('', 24);
    end
  end,

  drawSearch = function(self, deltaTime)
    gfx.Save();
  
    local acceptInput = songwheel.searchInputActive;
    local shouldShow = (string.len(songwheel.searchText) > 0)
      or songwheel.searchInputActive;

    if (shouldShow) then
      self.timer = math.min(self.timer + (deltaTime * 6), 1);
      self.cursor.timer = self.cursor.timer + deltaTime;
    elseif (self.timer > 0 and (not shouldShow)) then
      self.timer = math.max(self.timer - (deltaTime * 6), 0);
      self.cursor.timer = 0;
    end

    self.alpha = math.floor(255 * math.min(self.timer * 2, 1));
    self.cursor.alpha = (acceptInput and math.abs(0.9 * math.cos(self.cursor.timer * 5)) + 0.1) or 0;

    Font.JP();

    self.labels.input:update({ new = string.upper(songwheel.searchText) });

    local cursorOffset = math.min(self.labels.input.w + 2, self.w - 24);

    if (self.index ~= ((acceptInput and 0) or 1)) then
      game.PlaySample('woosh');
    end

    self.index = (acceptInput and 0) or 1;

    gfx.BeginPath();
    Fill.Black(150);
    gfx.FastRect(self.x + 2, self.y - 6, (self.w - 8) * self.timer, self.h + 12);
    gfx.Fill();

    if (acceptInput) then
      gfx.BeginPath();
      gfx.StrokeWidth(2);
      gfx.StrokeColor(60, 110, 160, self.alpha);
      Fill.Black(0);
      gfx.Rect(self.x + 2, self.y - 6, (self.w - 8) * self.timer, self.h + 12);
      gfx.Fill();
      gfx.Stroke();
    end

    gfx.BeginPath();
    FontAlign.Left();
    self.labels.search:draw({
      x = self.x + 7,
      y = self.y - 4,
      a = self.alpha,
      color = 'Normal',
    });

    if (shouldShow) then
      gfx.BeginPath();
      Fill.White(255 * self.cursor.alpha);
      gfx.FastRect(self.x + 8 + cursorOffset, self.y + (self.h / 2) - 4, 2, 28 );
      gfx.Fill();

      gfx.BeginPath();
      FontAlign.Left();
      self.labels.input:draw({
        x = self.x + 8,
        y = self.y + 20,
        color = 'White',
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
      Font.Medium();
  
      self.labels = {
        bta = Label.New('[BT-A]', 20),
        showControls = Label.New('SHOW CONTROLS', 20),
        volforce = {
          label = Label.New('VF', 20),
        },
      };

      Font.Number();
      self.labels.volforce.value = Label.New('', 20);
    end

    local forceValue = totalForce or game.GetSkinSetting('cachedVolforce') or 0;
    local y = 0;

    Font.Number();
    self.labels.volforce.value:update({ new = string.format('%.2f', forceValue) });
  
    gfx.Save();
  
    gfx.Translate(
      (scaledW / 20) - 1,
      scaledH - (scaledH / 40) - 14
    );

    if (controlsShortcut) then
      gfx.BeginPath();
      FontAlign.Left();
      self.labels.bta:draw({
        x = 0,
        y = y,
        color = 'Normal',
      });

      self.labels.showControls:draw({
        x = self.labels.bta.w + 8,
        y = y + 1,
        color = 'White',
      });

      gfx.Translate(songInfo.panel.w + 2, 0);

      Font.Number();
      self.labels.volforce.value:update({ new = string.format('%.2f', forceValue) });

      gfx.BeginPath();
      FontAlign.Right();
      self.labels.volforce.label:draw({
        x = 0,
        y = y,
        color = 'Normal',
      });

      self.labels.volforce.value:draw({
        x = -(self.labels.volforce.label.w + 8),
        y = y,
        color = 'White',
      });
    else
      gfx.BeginPath();
      FontAlign.Left();

      self.labels.volforce.value:draw({
        x = 0,
        y = y,
        color = 'White',
      });

      self.labels.volforce.label:draw({
        x = self.labels.volforce.value.w + 8,
        y = y,
        color = 'Normal',
      });
    end

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

  songInfo:render(deltaTime);
  songGrid:render(deltaTime);
  search:render(deltaTime);
  miscInfo:render();

  gfx.Restore();
end

get_page_size = function()
  return 9;
end

set_index = function(newSongIndex)
  songInfo:setSongIndex(newSongIndex);
  songGrid:setSongIndex(newSongIndex);

  if (previousSongIndex ~= newSongIndex) then
    game.PlaySample('click_song');
  end

  previousSongIndex = newSongIndex;
end

set_diff = function(newDifficultyIndex)
  songInfo:setDifficulty(newDifficultyIndex);
  songGrid:setDifficulty(newDifficultyIndex);

  if (previousDifficultyIndex ~= newDifficultyIndex) then
    game.PlaySample('click_difficulty');
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
