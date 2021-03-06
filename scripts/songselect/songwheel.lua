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

local background = New.Image({ path = 'bg.png' });

local best20 = {};
local best50 = {};

local controlsShortcut = getSetting('controlsShortcut', false);
local jacketQuality = getSetting('jacketQuality', 'NORMAL');

local previousDifficulty = 1;
local previousSong = 1;
local selectedDifficulty = 1;
local selectedSong = 1;

local loadJSON = require('common/jsonloader');
local userData = loadJSON('user_data');

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

local jacketCache = {
  cache = {},
  fallback = gfx.CreateSkinImage('common/loading.png', 0),
  quality = {
    ['LOW'] = 0.1,
    ['NORMAL'] = 0.2,
    ['HIGH'] = 0.5,
    ['ORIGINAL'] = 0.0,
  },

  getJacket = function(self, jacketPath)
    local quality = self.quality[jacketQuality] or self.quality['NORMAL'];

    if ((not self.cache[jacketPath])
      or (self.cache[jacketPath] == self.fallback)
    ) then
      self.cache[jacketPath] = gfx.LoadImageJob(
        jacketPath,
        self.fallback,
        math.floor(scaledW * quality),
        math.floor(scaledW * quality)
      );
    end

    return self.cache[jacketPath];
  end,
};

local songCache = {};

verifySongCache = function(song)
  if (not songCache[song.id]) then
    songCache[song.id] = { jackets = {} };

    songCache[song.id].artist = New.Label({
      font = 'jp',
      text = string.upper(song.artist),
      size = 30,
    });

    songCache[song.id].title = New.Label({
      font = 'jp',
      text = string.upper(song.title),
      size = 36,
    });
    
    songCache[song.id].bpm = New.Label({
      font = 'number',
      text = tostring(song.bpm),
      size = 24,
    });
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

  if (not songCache[song.id].effector[difficultyIndex]) then
    songCache[song.id].effector[difficultyIndex] =
      New.Label({
        font = 'jp',
        text = string.upper(difficulty.effector),
        size = 24,
      });
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

  getGrade = function(self, difficulty, params)
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
  for index, clear in ipairs(CONSTANTS.clears) do
    clears.labels[index] = New.Label({
      font = 'normal',
      text = clear,
      size = 36,
    });
  end

  for index, current in ipairs(CONSTANTS.grades) do
    grades.breakpoints[index] = {
      grade = current.grade,
      minimum = current.minimum,
      label = New.Label({
        font = 'normal',
        text = current.grade,
        size = 36,
      }),
    };
  end

  bestLabels.large.best = New.Label({
    font = 'normal',
    text = 'BEST',
    size = 28,
  });

  bestLabels.small.best = New.Label({
    font = 'medium',
    text = 'BEST',
    size = 18,
  });

  bestLabels.large['20'] = New.Label({
    font = 'number',
    text = '20',
    size = 28,
  });
  bestLabels.large['50'] = New.Label({
    font = 'number',
    text = '50',
    size = 28,
  });

  bestLabels.small['20'] = New.Label({
    font = 'number',
    text = '20',
    size = 18,
  });
  bestLabels.small['50'] = New.Label({
    font = 'number',
    text = '50',
    size = 18,
  });
end

local songInfo = {
  cache = { scaledW = 0, scaledH = 0 },
  cursor = Cursor.New(),
  cursorIndex = { current = 0, previous = 0 },
  difficulties = nil,
  highScore = 0,
  images = {
    button = New.Image({ path = 'buttons/short.png' }),
    buttonHover = New.Image({ path = 'buttons/short_hover.png' }),
    panel = New.Image({ path = 'common/panel.png' }),
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
      self.labels.y = (self.padding.y.double * 0.75) + self.jacketSize;

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
      self.difficulties = {};
      self.highScore = ScoreNumber.New({
        isScore = true,
        sizes = { 100, 80 }
      });
      self.labels = {};
      self.levels = {};

      for i = 1, 4 do
        self.levels[i] = New.Label({
          font = 'number',
          text = '',
          size = 18,
        });
      end

      for index, name in pairs(CONSTANTS.difficulties) do
        self.difficulties[index] = New.Label({
          font = 'medium',
          text = name,
          size = 18,
        });
      end

      for name, str in pairs(CONSTANTS.labels.info) do
        self.labels[name] = New.Label({
          font = 'medium',
          text = str,
          size = 18,
        });
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

  drawJacket = function(self, songId, difficulty)
    local jacket = jacketCache:getJacket(difficulty.jacketPath);

    gfx.Save();

    drawRectangle({
      x = self.padding.x.double,
      y = self.padding.y.full,
      w = self.jacketSize,
      h = self.jacketSize,
      image = jacket,
      stroke = { color = 'normal', size = 2 },
    });

    if (best20[difficulty.id]) then
      self:drawBestIndicator(self.padding.x.double, self.padding.y.full, '20');
    elseif (best50[difficulty.id]) then
      self:drawBestIndicator(self.padding.x.double, self.padding.y.full, '50');
    end

    gfx.Restore();
  end,

  drawBestIndicator = function(self, x, y, range)
    drawRectangle({
      x = x + 12,
      y = y + 12,
      w = 141,
      h = 42,
      color = 'dark',
    });

    drawLabel({
      x = x + 20,
      y = y + 15,
      color = 'white',
      label = bestLabels.large.best,
    });

    drawLabel({
      x = x + 20 + bestLabels.large.best.w + 12,
      y = y + 15,
      color = 'normal',
      label = bestLabels.large[range],
    });
  end,

  drawSongInfo = function(self, deltaTime, song, difficulty)
    local clearLabel = clears:getClear(difficulty);
    local gradeLabel = grades:getGrade(difficulty);
    local y = self.labels.y;

    gfx.Save();

    for _, name in ipairs(self.order.main) do
      local currentLabel = songCache[song.id][name];

      if (name == 'effector') then
        currentLabel = songCache[song.id][name][self.selectedDifficulty];
      end

      local doesOverflow = currentLabel.w > self.panel.innerWidth;

      drawLabel({
        x = self.labels.x,
        y = y,
        color = 'normal',
        label = self.labels[name],
      });
  
      if (doesOverflow and (self.scrollTimers[name] ~= nil)) then
        self.scrollTimers[name] = self.scrollTimers[name] + deltaTime;

        drawScrollingLabel({
          x = self.labels.x,
          y = y + (self.labels[name].h * 1.35),
          alpha = 255,
          color = 'white',
          label = currentLabel,
          scale = scalingFactor,
          timer = self.scrollTimers[name],
          width = self.panel.innerWidth,
        });
      else
        drawLabel({
          x = self.labels.x,
          y = y + (self.labels[name].h * 1.35),
          color = 'white',
          label = currentLabel,
        });
      end

      y = y
        + (self.labels[name].h * 1.35)
        + (currentLabel.h)
        + (self.padding.y.quarter * 1.35);
    end

    if (clearLabel and gradeLabel) then
      for _, name in ipairs(self.order.conditional) do
        drawLabel({
          x = self.labels.x,
          y = y,
          color = 'normal',
          label = self.labels.grade,
        });

        drawLabel({
          x = self.labels.x,
          y = y + (self.labels.grade.h * 1.25),
          color = 'white',
          label = gradeLabel,
        });

        drawLabel({
          x = self.labels.x + (self.padding.x.full * 4.5),
          y = y,
          color = 'normal',
          label = self.labels.clear,
        });

        drawLabel({
          x = self.labels.x + (self.padding.x.full * 4.5),
          y = y + (self.labels.clear.h * 1.25),
          color = 'white',
          label = clearLabel,
        });
      end

      y = y
        + (self.labels.clear.h * 1.35)
        + (clearLabel.h)
        + (self.padding.y.quarter * 1.35);

      drawLabel({
        x = self.labels.x,
        y = y,
        color = 'normal',
        label = self.labels.highScore,
      });

      self.highScore:setInfo({ value = difficulty.scores[1].score });

      self.highScore:draw({
        x = self.labels.x - 4,
        y1 = y + (self.labels.highScore.h * 0.5),
        y2 = y + (self.labels.highScore.h * 0.5) + self.padding.y.half - 5,
        offset = 10,
      });
    end

    gfx.Restore();
  end,

  drawDifficulty = function(self, currentDifficulty, isSelected, y, i)
    local x = self.padding.x.double
      + self.jacketSize
      + self.padding.x.full
      + 4;

    gfx.Save();

    if (isSelected) then
      drawImage({
        x = x,
        y = y,
        image = self.images.buttonHover,
      })
    else
      drawImage({
        x = x,
        y = y,
        alpha = 0.45,
        image = self.images.button,
      });
    end

    if (currentDifficulty) then
      local difficultyIndex = getDifficultyIndex(
        currentDifficulty.jacketPath,
        currentDifficulty.difficulty
      );

      self.levels[i]:update({
        new = string.format('%02d', currentDifficulty.level)
      });

      drawLabel({
        x = x + 36,
        y = y + (self.images.button.h / 2.85),
        alpha = 255 * ((isSelected and 1) or 0.2),
        color = 'white',
        label = self.difficulties[difficultyIndex],
      });

      drawLabel({
        x = x + self.images.button.w - 36,
        y = y + (self.images.button.h / 2.85),
        align = 'right',
        alpha = 255 * ((isSelected and 1) or 0.2),
        color = 'white',
        label = self.levels[i],
      });
    end

    gfx.Restore();

    return self.images.button.h + (self.images.button.h / 5);
  end,

  drawSongInfoPanel = function(self, deltaTime)
    local song = songwheel.songs[selectedSong];

    gfx.Save();

    gfx.Translate(self.panel.x, self.panel.y);

    drawImage({
      x = 0,
      y = 0,
      w = self.panel.w,
      h = self.panel.h,
      alpha = 0.5,
      image = self.images.panel,
    });

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

    self:drawJacket(song.id, difficulty);

    self:drawSongInfo(deltaTime, song, difficulty);

    drawLabel({
      x = self.padding.x.double + self.jacketSize + self.padding.x.full + 4,
      y = self.padding.y.full - 4,
      color = 'normal',
      label = self.labels.difficulty,
    });

    local y = self.padding.y.double + self.labels.difficulty.h - 24;

    for i = 1, 4 do
      local currentDifficulty = self:getDifficulty(song.difficulties, i);
      local isSelected = difficulty.difficulty == (i - 1);

      if (isSelected) then
        self.cursorIndex.current = i;
      end

      y = y + self:drawDifficulty(currentDifficulty, isSelected, y, i);
    end

    gfx.Restore();
  end,

  handleChange = function(self)
    local resetTimers = function(self)
      self.scrollTimers.artist = 0;
      self.scrollTimers.effector = 0;
      self.scrollTimers.title = 0;
    end

    if (self.selectedDifficulty ~= selectedDifficulty) then
      resetTimers(self);

      self.selectedDifficulty = selectedDifficulty;
    end

    if (self.cursorIndex.previous ~= self.cursorIndex.current) then
      resetTimers(self);

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

    if (songwheel.songs[selectedSong]) then
      self.cursor:render(deltaTime, {
        size = 12,
        stroke = 1.5,
        vertical = true,
      });
    end

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
  currentPage = 1,
  cursor = Cursor.New(),
  grid = {
    jacket = 0,
    margin = 0,
    stats = { w = 0, h = 0 },
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

      self.grid.stats.w = (self.grid.jacket // 2.2);
      self.grid.stats.h = (self.grid.jacket // 4);

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
      local newLabel = function(text, size)
        return New.Label({
          font = 'medium',
          text = text,
          size = size,
        });
      end

      self.labels = {
        gameplaySettings = newLabel('GAMEPLAY SETTINGS', 20),
        grade = newLabel('GRADE', 18),
        of = newLabel('OF', 18),
        fxlfxr = newLabel('[FX-L]  +  [FX-R]', 20),
      };

      self.labels.currentSong = ScoreNumber.New({
        digits = 4,
        isScore = false,
        sizes = { 18 },
      });
      self.labels.totalSongs = ScoreNumber.New({
        digits = 4,
        isScore = false,
        sizes = { 18 },
      });
    end
  end,

  drawNoSongMessage = function(self)
    gfx.Save();

    gfx.Translate(
      self.grid.x + (self.grid.w / 2),
      self.grid.y.base + (self.grid.h / 2)
    );

    gfx.BeginPath();
    gfx.FontSize(48);
    alignText('middle');
    loadFont('normal');
    setFill('dark', 255 * 0.5);
    gfx.Text('NO SONGS FOUND', 1, 1);
    setFill('white');
    gfx.Text('NO SONGS FOUND', 0, 0);

    gfx.Restore();
  end,

  drawSongAmount = function(self)
    self.labels.currentSong:setInfo({ value = self.selectedSong });
    self.labels.totalSongs:setInfo({ value = #songwheel.songs });

    gfx.Save();

    gfx.Translate(
      self.grid.x + self.grid.w + (scaledW / 40) + 5,
      scaledH - (scaledH / 40) - 12
    );

    self.labels.currentSong:draw({
      x = -(self.labels.of.w + (self.labels.totalSongs.w * 2) + 30),
      y = 0,
      align = 'right',
      color = 'normal',
    });

    drawLabel({
      x = -((self.labels.totalSongs.w * 1.25) + 12),
      y = 0,
      align = 'right',
      color = 'normal',
      label = self.labels.of,
    });

    self.labels.totalSongs:draw({
      x = -(self.labels.totalSongs.w),
      y = 0,
      align = 'right',
      color = 'normal',
    });

    gfx.Restore();
  end,

  drawSongGrid = function(self, deltaTime)
    if (self.grid.timer < 1) then
      self.grid.timer = math.min(self.grid.timer + (deltaTime * 4), 1);
    end

    local change = (self.grid.y.current - self.grid.y.previous)
      * smoothstep(self.grid.timer);
    local offset = self.grid.y.previous + change;
    local y = 0;

    self.grid.y.previous = offset;

    gfx.Save();

    gfx.Translate(self.grid.x, self.grid.y.base + offset);

    for i = 1, #songwheel.songs do
      local isSelected = i == self.selectedSong;

      y = y + self:drawSong(i, y, isSelected);
    end

    gfx.Restore();
  end,

  drawSong = function(self, i, y, isSelected)
    if (not songwheel.songs[i]) then return end

    local alpha = (isSelected and 1) or 0.5;
    local _, column = help.getPosition(i);
    local x = (self.grid.jacket + self.grid.margin) * column;
    local song = songwheel.songs[i];
    local isVisible = List.isVisible(i, self.viewLimit, self.currentPage);

    verifySongCache(song);

    local difficulty = song.difficulties[selectedDifficulty];

    if (not difficulty) then
      difficulty = song.difficulties[1];
    end

    if (isVisible) then
      local jacket = jacketCache:getJacket(difficulty.jacketPath);

      drawRectangle({
        x = x,
        y = y,
        w = self.grid.jacket,
        h = self.grid.jacket,
        color = 'black',
      });

      drawRectangle({
        x = x,
        y = y,
        w = self.grid.jacket,
        h = self.grid.jacket,
        alpha = alpha,
        image = jacket,
        stroke = {
          color = (isSelected and 'normal') or 'dark',
          size = 2,
        },
      });

      if (best20[difficulty.id]) then
        self:drawBestIndicator(x, y, alpha, '20');
      elseif (best50[difficulty.id]) then
        self:drawBestIndicator(x, y, alpha, '50');
      end

      if (grades:getGrade(difficulty)) then
        self:drawGrade(
          grades:getGrade(difficulty),
          x,
          y,
          alpha
        );
      end
    end

    if (column == 2) then
      return self.grid.jacket + self.grid.margin;
    end

    return 0;
  end,

  drawBestIndicator = function(self, x, y, alpha, range);
    drawRectangle({
      x = x + 8,
      y = y + 8,
      w = 98,
      h = 32,
      alpha = 255 * math.min(alpha * 1.5, 1),
      color = 'dark',
    });

    drawLabel({
      x = x + 16,
      y = y + 12,
      alpha = 255 * alpha,
      color = 'white',
      label = bestLabels.small.best,
    });

    drawLabel({
      x = x + 16 + bestLabels.small.best.w + 8,
      y = y + 12,
      alpha = 255 * math.min(alpha * 1.5, 1),
      color = 'normal',
      label = bestLabels.small[range],
    });
  end,

  drawGrade = function(self, grade, initialX, initialY, alpha)
    local x = initialX + self.grid.jacket - 8 - self.grid.stats.w;
    local y = initialY + self.grid.jacket - 8 - self.grid.stats.h;

    drawRectangle({
      x = x,
      y = y,
      w = self.grid.stats.w,
      h = self.grid.stats.h,
      alpha = 255 * math.min(alpha * 1.5, 1),
      color = 'dark',
    });

    drawLabel({
      x = x + 8,
      y = y + 4,
      alpha = 255 * math.min(alpha * 1.5, 1),
      color = 'normal',
      label = self.labels.grade,
    });

    drawLabel({
      x = x + 8,
      y = y + 4 + (self.labels.grade.h),
      alpha = 255 * alpha,
      color = 'white',
      label = grade,
    });
  end,

  handleChange = function(self)
    if (self.selectedSong ~= selectedSong) then
      self.selectedSong = selectedSong;

      self.currentPage = List.getCurrentPage({
        current = self.selectedSong,
        limit = self.viewLimit,
        total = #songwheel.songs,
      });

      self.grid.y.current = (self.grid.h + self.grid.margin)
        * (self.currentPage - 1);
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

    drawLabel({
      x = self.grid.x - 1,
      y = scaledH - (scaledH / 40) - 14,
      color = 'normal',
      label = self.labels.fxlfxr,
    });

    drawLabel({
      x = self.grid.x - 1 + self.labels.fxlfxr.w + 8,
      y = scaledH - (scaledH / 40) - 14,
      color = 'white',
      label = self.labels.gameplaySettings,
    });

    self:handleChange();

    gfx.Restore();
  end
};

local miscInfo = {
  labels = nil,

  render = function(self)
    if (not self.labels) then
      local newLabel = function(text)
        return New.Label({
          font = 'medium',
          text = text,
          size = 20,
        });
      end

      self.labels = {
        bta = newLabel('[BT-A]');
        showControls = newLabel('SHOW CONTROLS');
        volforce = {
          label = newLabel('VF'),
          value = New.Label({
            font = 'number',
            text = '',
            size = 20,
          }),
        },
      };
    end

    local forceValue = totalForce or get(userData.contents, 'volforce', 0);
    local y = 0;

    self.labels.volforce.value:update({ new = string.format('%.2f', forceValue) });
  
    gfx.Save();
  
    gfx.Translate(
      (scaledW / 20) - 1,
      scaledH - (scaledH / 40) - 14
    );

    if (controlsShortcut) then
      drawLabel({
        x = 0,
        y = y,
        color = 'normal',
        label = self.labels.bta,
      });

      drawLabel({
        x = self.labels.bta.w + 8,
        y = y + 1,
        color = 'white',
        label = self.labels.showControls,
      });

      gfx.Translate(songInfo.panel.w + 2, 0);

      self.labels.volforce.value:update({
        new = string.format('%.2f', forceValue)
      });

      drawLabel({
        x = 0,
        y = y,
        align = 'right',
        color = 'normal',
        label = self.labels.volforce.label,
      });

      drawLabel({
        x = -(self.labels.volforce.label.w + 8),
        y = y,
        align = 'right',
        color = 'white',
        label = self.labels.volforce.value,
      });
    else
      drawLabel({
        x = 0,
        y = y,
        color = 'white',
        label = self.labels.volforce.value,
      });

      drawLabel({
        x = self.labels.volforce.value.w + 8,
        y = y,
        color = 'normal',
        label = self.labels.volforce.label,
      });
    end

    gfx.Restore();
  end
};

render = function(deltaTime)
  setupLayout();

  gfx.Save();

  drawImage({
    x = 0,
    y = 0,
    w = scaledW,
    h = scaledH,
    image = background,
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
      if (diffs[i].force > 0) then
        if (i <= 20) then
          best20[diffs[i].id] = true;
        end
        
        best50[diffs[i].id] = true;
      end

      totalForce = totalForce + diffs[i].force;
		end
  end

  userData:set('volforce', totalForce);
end
