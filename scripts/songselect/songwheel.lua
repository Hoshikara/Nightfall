game.LoadSkinSample('click_difficulty');
game.LoadSkinSample('click_song');

local CONSTANTS = require('constants/songwheel');

local List = require('common/list');
local Cursor = require('common/cursor');
local ScoreNumber = require('common/scorenumber');
local Scrollbar = require('common/scrollbar');
local SearchBar = require('common/searchbar');

local help = require('helpers/songwheel');
local volforce = require('songselect/volforce');

local background = Image.New('bg.png');

local best20 = {};
local best50 = {};

local controlsShortcut = game.GetSkinSetting('controlsShortcut') or false;

local jacketFallback = gfx.CreateSkinImage('common/loading.png', 0);

local previousDifficulty = 1;
local previousSong = 1;
local selectedDifficulty = 1;
local selectedSong = 1;

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

local bestLabels = { large = {}, small = {} };

do
  Font.Normal();

  for index, clear in ipairs(CONSTANTS.clears) do
    clears.labels[index] = Label.New(clear, 24);
  end

  for index, current in ipairs(CONSTANTS.grades) do
    grades.breakpoints[index] = {
      minimum = current.minimum,
      label = Label.New(current.grade, 24),
    };
  end

  bestLabels.large.best = Label.New('BEST', 28);

  Font.Medium();

  bestLabels.small.best = Label.New('BEST', 18);

  Font.Number();

  bestLabels.large['20'] = Label.New('20', 28);
  bestLabels.large['50'] = Label.New('50', 28);

  bestLabels.small['20'] = Label.New('20', 18);
  bestLabels.small['50'] = Label.New('50', 18);
end

local songInfo = {
  cache = { scaledW = 0, scaledH = 0 },
  cursor = Cursor.New(),
  cursorIndex = { current = 0, previous = 0 },
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
  scrollTimers = {
    artist = 0,
    effector = 0,
    title = 0,
  },
  search = SearchBar.New(),
  selectedDifficulty = 0,

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

      self.panel.innerWidth = self.panel.w - (self.padding.x.double * 2);

      self.labels.x = self.padding.x.double;
      self.labels.y = self.padding.y.double + self.jacketSize;

      self.cursor:setSizes({
        x = (scaledW / 20)
          + self.padding.x.double
          + self.jacketSize
          + self.padding.x.full
          + 14,
        y = (scaledH / 20)
          + self.padding.y.double
          + self.labels.difficulty.h
          - 14,
        w = self.images.button.w - 20,
        h = self.images.button.h - 20,
        margin = (self.images.button.h / 5) + 20,
      });

      self.search:setSizes({
        screenW = scaledW,
        screenH = scaledH,
        w = self.panel.w,
      });

      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
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

    if (best20[difficulty.id]) then
      self:drawBestIndicator(self.padding.x.double, self.padding.y.full, '20');
    elseif (best50[difficulty.id]) then
      self:drawBestIndicator(self.padding.x.double, self.padding.y.full, '50');
    end

    gfx.Restore();
  end,

  drawBestIndicator = function(self, x, y, range)
    gfx.BeginPath();
    Fill.Dark(255);
    gfx.Rect(
      x + 12,
      y + 12,
      141,
      42
    );
    gfx.Fill();

    gfx.BeginPath();
    FontAlign.Left();

    bestLabels.large.best:draw({
      x = x + 20,
      y = y + 15,
      color = 'White',
    });

    bestLabels.large[range]:draw({
      x = x + 20 + bestLabels.large.best.w + 12,
      y = y + 15,
      color = 'Normal',
    });
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
    local x = self.padding.x.double
      + self.jacketSize
      + self.padding.x.full
      + 4;
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
      local difficultyIndex = getDifficultyIndex(
        currentDifficulty.jacketPath,
        currentDifficulty.difficulty
      );

      gfx.BeginPath();
      FontAlign.Left();
      self.difficulties[difficultyIndex]:draw({
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

    return self.images.button.h + (self.images.button.h / 5);
  end,

  drawSongInfoPanel = function(self, deltaTime)
    local song = songwheel.songs[selectedSong];

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

    local y = self.padding.y.double + self.labels.difficulty.h - 24;

    for index = 1, 4 do
      local level = self:getDifficulty(song.difficulties, index);
      local isSelected = difficulty.difficulty == (index - 1);

      if (isSelected) then
        self.cursorIndex.current = index;
      end

      y = y + self:drawDifficulty(level, isSelected, y);
    end

    gfx.Restore();
  end,

  handleChange = function(self)
    if (self.selectedDifficulty ~= selectedDifficulty) then
      self.selectedDifficulty = selectedDifficulty;
    end

    if (self.cursorIndex.previous ~= self.cursorIndex.current) then
      self.cursorIndex.previous = self.cursorIndex.current;

      self.cursor:setPosition({
        current = self.cursorIndex.current,
        total = 4,
        vertical = true,
      });

      self.cursor.timer.flicker = 0;
    end
  end,

  render = function(self, deltaTime)
    self:setLabels();

    self:setSizes();

    gfx.Save();

    self:drawSongInfoPanel(deltaTime);

    self.cursor:render(deltaTime, {
      size = 12,
      stroke = 1.5,
      vertical = true,
    });

    self:handleChange();

    self.search:render(deltaTime, {
      isActive = songwheel.searchInputActive,
      searchText = songwheel.searchText,
    });

    gfx.Restore();
  end
};

local songGrid = {
  cache = { scaledW = 0, scaledH = 0 },
  cursor = Cursor.New(),
  grid = {
    jacket = 0,
    margin = 0,
    timer = 1,
    w = 0,
    h = 0,
    x = 0,
    y = {
      base = 0,
      current = 0,
      previous = 0,
    },
  },
  labels = nil,
  order = {
    'collection',
    'difficulty',
    'sort',
  },
  scrollbar = Scrollbar.New(),
  selectedSong = 1,
  viewLimit = 9,

  setSizes = function(self)
    if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
      self.grid.w = scaledW - ((scaledW / 20) * 3) - songInfo.panel.w;
      self.grid.h = self.grid.w;

      self.grid.jacket = self.grid.w / 3.3;

      self.grid.margin = (self.grid.w - (self.grid.jacket * 3)) / 2;

      self.grid.x = (scaledW / 10) + songInfo.panel.w;
      self.grid.y.base = scaledH - (scaledH / 20) - self.grid.h;

      self.labels.x = {};
      self.labels.x[1] = self.grid.x - 1;
      self.labels.x[2] = self.labels.x[1] + (self.grid.jacket * 1.5) + self.grid.margin;
      self.labels.x[3] = self.labels.x[2] + (self.grid.jacket * 0.9); 
      self.labels.y = (scaledH / 20) - 2;

      self.cursor:setSizes({
        x = self.grid.x,
        y = self.grid.y.base,
        w = self.grid.jacket,
        h = self.grid.jacket,
        margin = self.grid.margin,
      });

      if (#songwheel.songs > self.viewLimit) then
        self.scrollbar:setSizes({
          screenW = scaledW,
          y = self.grid.y.base,
          h = self.grid.h,
        });
      end
      
      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
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
      self.grid.x + (self.grid.w / 2),
      self.grid.y.base + (self.grid.h / 2)
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

  drawSongAmount = function(self)
    Font.Number();

    self.labels.currentSong:update({
      new = string.format('%04d', self.selectedSong)
    });
    self.labels.totalSongs:update({
      new = string.format('%04d', #songwheel.songs)
    });

    gfx.Save();

    gfx.Translate(
      self.grid.x + self.grid.w + (scaledW / 40) + 5,
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

  drawSongGrid = function(self, deltaTime)
    if (self.grid.timer < 1) then
      self.grid.timer = math.min(self.grid.timer + (deltaTime * 8), 1);
    end

    local change = (self.grid.y.current - self.grid.y.previous)
      * Ease.OutQuad(self.grid.timer);
    local offset = self.grid.y.previous + change;
    local y = 0;

    self.grid.y.previous = offset;

    gfx.Save();

    gfx.Scissor(
      self.grid.x - 2,
      self.grid.y.base - 2,
      self.grid.w + 4,
      self.grid.h + 4
    );

    gfx.Translate(self.grid.x, self.grid.y.base + offset);

    for i = 1, #songwheel.songs do
      local isSelected = i == self.selectedSong;
      y = y + self:drawSong(i, y, isSelected);
    end

    gfx.ResetScissor();

    gfx.Restore();
  end,

  drawSong = function(self, i, y, isSelected)
    if (not songwheel.songs[i]) then return end

    local alpha = (isSelected and 1) or 0.5;
    local _, column = help.getPosition(i);
    local x = (self.grid.jacket + self.grid.margin) * column;
    local song = songwheel.songs[i];

    verifySongCache(song);

    local difficulty = song.difficulties[selectedDifficulty];

    if (not difficulty) then
      difficulty = song.difficulties[1];
    end

    if ((not songCache[song.id][selectedDifficulty])
      or (songCache[song.id][selectedDifficulty] == jacketFallback)
    ) then
      songCache[song.id][selectedDifficulty] = gfx.LoadImageJob(
        difficulty.jacketPath,
        jacketFallback,
        0,
        0
      );
    end

    if (songCache[song.id][selectedDifficulty]) then
      gfx.BeginPath();
      Fill.Black();
      gfx.Rect(x, y, self.grid.jacket, self.grid.jacket);
      gfx.Fill();

      gfx.BeginPath();
      gfx.StrokeWidth(2);
      
      if (isSelected) then
        gfx.StrokeColor(60, 110, 160, 255);
      else
        gfx.StrokeColor(4, 8, 12, 255);
      end

      gfx.ImageRect(
        x, 
        y, 
        self.grid.jacket, 
        self.grid.jacket, 
        songCache[song.id][selectedDifficulty], 
        alpha,
        0
      );
      gfx.Stroke();

      if (best20[difficulty.id]) then
        self:drawBestIndicator(x, y, alpha, '20');
      elseif (best50[difficulty.id]) then
        self:drawBestIndicator(x, y, alpha, '50');
      end
    end

    if (column == 2) then
      return self.grid.jacket + self.grid.margin;
    end

    return 0;
  end,

  drawBestIndicator = function(self, x, y, alpha, range);
    gfx.BeginPath();
    Fill.Dark(255 * math.min(alpha * 1.5, 1));
    gfx.Rect(
      x + 8,
      y + 8,
      98,
      32
    );
    gfx.Fill();

    gfx.BeginPath();
    FontAlign.Left();

    bestLabels.small.best:draw({
      x = x + 16,
      y = y + 12,
      a = 255 * alpha,
      color = 'White',
    });

    bestLabels.small[range]:draw({
      x = x + 16 + bestLabels.small.best.w + 8,
      y = y + 12,
      a = 255 * math.min(alpha * 1.5, 1),
      color = 'Normal',
    });
  end,

  handleChange = function(self)
    if (self.selectedSong ~= selectedSong) then
      self.selectedSong = selectedSong;

      local currentPage = List.getCurrentPage({
        current = self.selectedSong,
        limit = self.viewLimit,
        total = #songwheel.songs,
      });

      self.grid.y.current = (self.grid.h + self.grid.margin)
        * (currentPage - 1);
      self.grid.y.current = -self.grid.y.current;
      
      self.grid.timer = 0;

      self.cursor:setPosition({
        current = self.selectedSong,
        total = self.viewLimit,
        grid = true,
      });

      self.cursor.timer.flicker = 0;

      self.scrollbar:setPosition({
        current = self.selectedSong,
        total = #songwheel.songs,
      });
    end
  end,

  render = function(self, deltaTime)
    self:setLabels();

    self:setSizes();

    gfx.Save();

    self:drawLabels();

    if (#songwheel.songs > 0) then
      self:drawSongGrid(deltaTime);

      self.cursor:render(deltaTime, {
        size = 18,
        stroke = 1.5,
        grid = true,
      });

      if (#songwheel.songs > self.viewLimit) then
        self.scrollbar:render(deltaTime);
      end

      self:drawSongAmount();
    else
      self:drawNoSongMessage();
    end

    self:handleChange();

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
  miscInfo:render();

  gfx.Restore();
end

get_page_size = function()
  return 9;
end

set_index = function(newSong)
  selectedSong = newSong;

  if (previousSong ~= newSong) then
    game.PlaySample('click_song');
  end

  previousSong = newSong;
end

set_diff = function(newDifficulty)
  selectedDifficulty = newDifficulty;

  if (previousDifficulty ~= newDifficulty) then
    game.PlaySample('click_difficulty');
  end

  previousDifficulty = newDifficulty;
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

  best20 = {};
  best50 = {};
  totalForce = 0;

	for i = 1, 50 do
    if (diffs[i]) then
      if (i <= 20) then
        best20[diffs[i].id] = true;
      end
      
      best50[diffs[i].id] = true;

			totalForce = totalForce + diffs[i].force;
		end
  end
  
  game.SetSkinSetting('cachedVolforce', totalForce);
end
