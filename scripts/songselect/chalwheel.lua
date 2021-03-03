game.LoadSkinSample('click_song');

local CONSTANTS_CHALWHEEL = require('constants/chalwheel');
local CONSTANTS_SONGWHEEL = require('constants/songwheel');

local Cursor = require('common/cursor');
local List = require('common/list');
local ScoreNumber = require('common/scorenumber');
local Scrollbar = require('common/scrollbar');
local SearchBar = require('common/searchbar');

local background = New.Image({ path = 'bg.png' });

local controlsShortcut = getSetting('controlsShortcut', false);
local jacketQuality = getSetting('jacketQuality', 'NORMAL');

local previousChallenge = 1;
local selectedChallenge = 1;

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

local challengeCache = {};
local scrollTimers = {};

cacheChallenge = function(challenge)
  if (not challengeCache[challenge.id]) then
    challengeCache[challenge.id] = {};
    scrollTimers[challenge.id] = { title = 0 };

    challengeCache[challenge.id].bpms = {};
    challengeCache[challenge.id].titles = {};
    challengeCache[challenge.id].jackets = {};
    challengeCache[challenge.id].title = {
      name = New.Label({
        font = 'jp',
        text = string.upper(challenge.title),
        size = 36,
      }),
      timer = 0,
    };

    for i, chart in ipairs(challenge.charts) do
      challengeCache[challenge.id].titles[i] = New.Label({
        font = 'jp',
        text = string.upper(chart.title),
        size = 28,
      });
    end

    challengeCache[challenge.id].requirements = {};

    for requirement in challenge.requirement_text:gmatch('[^\n]+') do
      local label = New.Label({
        font = 'normal',
        text = string.upper(requirement),
        size = 24,
      });

      table.insert(challengeCache[challenge.id].requirements, label);
    end

    for i, chart in ipairs(challenge.charts) do
      challengeCache[challenge.id].bpms[i] = New.Label({
        font = 'number',
        text = chart.bpm,
        size = 24,
      });
    end

    if (challenge.topBadge ~= 0) then
      challengeCache[challenge.id].completion = New.Label({
        font = 'number',
        text = string.format(
          '%d%%',
          math.max(0, ((challenge.bestScore - 8000000) // 10000))
        ),
        size = 24,
      });

      challengeCache[challenge.id].grade = New.Label({
        font = 'number',
        text = string.upper(challenge.grade),
        size = 24,
      });
    end
  end
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

local clears = {};

local difficulties = {};

local labels = {};

local levels = {};

do
  for i, clear in ipairs(CONSTANTS_SONGWHEEL.clears) do
    clears[i] = New.Label({
      font = 'normal',
      text = clear,
      size = 24,
    });
  end

  for i, difficulty in ipairs(CONSTANTS_SONGWHEEL.difficulties) do
    difficulties[i] = New.Label({
      font = 'normal',
      text = difficulty,
      size = 24,
    });
  end

  for name, label in pairs(CONSTANTS_CHALWHEEL.labels) do
    labels[name] = New.Label({
      font = 'medium',
      text = label,
      size = 18,
    });
  end

  for i = 1, 4 do
    levels[i] = New.Label({
      font = 'number',
      text = '',
      size = 24,
    });
  end
end

local challengeInfo = {
  cache = { scaledW = 0, scaledH = 0 },
  images = { panel = New.Image({ path = 'common/panel_wide.png' }) },
  labels = nil,
  padding = {
    x = { double = 0, full = 0 },
    y = { double = 0, full = 0 },
  },
  order = {
    chart = {
      'title',
      'difficulty',
    },
    result = {
      'completion',
      'grade',
      'clear',
    },
  },
  panel = {
    innerWidth = 0,
    w = 0,
    h = 0,
    y = 0,
    h = 0,
  },
  search = SearchBar.New(),
  selectedChallenge = 0,
  timers = { title = 0 },
  
  setSizes = function(self)
    if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
      self.panel.w = scaledW / (1920 / self.images.panel.w);
      self.panel.h = scaledH - (scaledH / 10);
      self.panel.x = scaledW / 20;
      self.panel.y = scaledH / 20;

      self.padding.x.full = self.panel.w / 24;
      self.padding.x.double = self.padding.x.full * 2;

      self.padding.y.full = self.panel.h / 24;
      self.padding.y.double = self.padding.y.full * 2;

      self.panel.innerWidth = self.panel.w - (self.padding.x.double * 2);

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
      self.labels = {
        missingCharts = New.Label({
          font = 'normal',
          text = 'REQUIRED CHARTS MISSING',
          size = 36,
        }),
      };
    end
  end,

  drawCharts = function(self, deltaTime, challenge, initialY)
    local jacketSize = math.floor(scaledW / 17.25);
    local x = 2;
    local y = initialY;

    gfx.Save();

    for i, chart in ipairs(challenge.charts) do
      local info = {
        difficulty = difficulties[getDifficultyIndex(
          chart.jacketPath,
          chart.difficulty
        )],
        title = challengeCache[challenge.id].titles[i],
      };

      local bpm = challengeCache[challenge.id].bpms[i];
      local jacket = jacketCache:getJacket(chart.jacketPath);

      local maxWidth = self.panel.innerWidth - jacketSize - self.padding.x.full;
      local infoX = x + jacketSize + self.padding.x.full;
      local infoY = y - 6;

      if (not levels[i]) then
        levels[i] = New.Label({
          font = 'number',
          text = '',
          size = 24,
        });
      end

      levels[i]:update({ new = string.format('%02d', chart.level) });

      drawRectangle({
        x = x,
        y = y,
        w = jacketSize,
        h = jacketSize,
        image = jacket,
        stroke = { color = 'normal', size = 1 },
      });

      for _, name in ipairs(self.order.chart) do
        drawLabel({
          x = infoX,
          y = infoY,
          color = 'normal',
          label = labels[name],
        });
      
        if (info[name]) then
          if (name == 'difficulty') then
            local bpmX = infoX + labels[name].w * 2.25;
          
            drawLabel({
              x = bpmX,
              y = infoY,
              color = 'normal',
              label = labels.bpm,
            });

            infoY = infoY + labels[name].h * 1.25;

            drawLabel({
              x = infoX,
              y = infoY,
              color = 'white',
              label = info[name],
            });

            drawLabel({
              x = infoX + info[name].w + 8,
              y = infoY,
              color = 'white',
              label = levels[i],
            });

            drawLabel({
              x = bpmX,
              y = infoY,
              color = 'white',
              label = bpm,
            });
          else
            infoY = infoY + labels[name].h * 1.25;

            if (info[name].w > maxWidth) then
              scrollTimers[challenge.id][name] =
                scrollTimers[challenge.id][name] + deltaTime;

              drawScrollingLabel({
                x = infoX,
                y = infoY,
                alpha = 255,
                color = 'white',
                label = info[name],
                scale = scalingFactor,
                timer = scrollTimers[challenge.id][name],
                width = maxWidth,
              });
            else
              drawLabel({
                x = infoX,
                y = infoY,
                color = 'white',
                label = info[name],
              });
            end
          end

          infoY = infoY + info[name].h * 1.75;
        end
      end

      if (i == 3) then
        y = y + jacketSize + self.padding.y.full;
        
        break;
      end

      if (i ~= #challenge.charts) then
        drawRectangle({
          x = x - 1,
          y = y + jacketSize + (self.padding.y.full / 2) - 1,
          w = self.panel.innerWidth,
          h = 2,
          alpha = 100,
          color = 'normal',
        });
      end

      y = y + jacketSize + self.padding.y.full;
    end

    gfx.Restore();

    return y;
  end,

  drawResults = function(self, challenge, initialY)
    local info = {
      clear = clears[challenge.topBadge],
      completion = challengeCache[challenge.id].completion,
      grade = challengeCache[challenge.id].grade,
    };

    local x = 0;
    local y = initialY;

    for _, name in ipairs(self.order.result) do
      if (info[name]) then
        drawLabel({
          x = x,
          y = y,
          color = 'normal',
          label = labels[name],
        });

        drawLabel({
          x = x,
          y = y + (labels[name].h * 1.35),
          color = 'white',
          label = info[name],
        });

        x = x + (labels.grade.w * 1.5) + labels[name].w;
      end
    end
  end,

  drawChallengeInfo = function(self, deltaTime)
    local challenge = chalwheel.challenges[self.selectedChallenge];

    if (not challenge) then return end

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
    
    if (not challenge) then return end
    
    cacheChallenge(challenge);

    local title = challengeCache[challenge.id].title.name;
    local requirements = challengeCache[challenge.id].requirements;

    local y = 0;

    gfx.Save();

    gfx.Translate(
      self.panel.x + self.padding.x.double,
      self.panel.y + self.padding.y.full
    );

    if (challenge.missing_chart) then
      drawLabel({
        x = -2,
        y = y,
        color = 'white',
        label = self.labels.missingCharts,
      });

      y = y + (self.labels.missingCharts.h * 0.5) + self.padding.y.full; 
    else
      y = self:drawCharts(deltaTime, challenge, y);
    end

    drawLabel({
      x = 0,
      y = y,
      color = 'normal',
      label = labels.challenge,
    });

    y = y + labels.challenge.h * 1.25;

    if (title.w > self.panel.innerWidth) then
      self.timers.title = self.timers.title + deltaTime;

      drawScrollingLabel({
        x = 0,
        y = y,
        alpha = 255,
        color = 'white',
        label = title,
        scale = scalingFactor,
        timer = self.timers.title,
        width = self.panel.innerWidth,
      });
    else
      drawLabel({
        x = 0,
        y = y,
        color = 'white',
        label = title,
      });
    end

    y = y + title.h * 1.75;

    drawLabel({
      x = 0,
      y = y,
      color = 'normal',
      label = labels.requirements,
    });

    y = y + labels.requirements.h * 1.35;

    for i = 1, #requirements do
      drawLabel({
        x = 0,
        y = y,
        color = 'white',
        label = requirements[i],
      });

      y = y + (requirements[i].h * 1.75);

      if (i == 6) then
        break;
      end
    end

    if (challenge.topBadge ~= 0) then
      y = y + (requirements[1].h * 0.5);
  
      self:drawResults(challenge, y);
    end

    gfx.Restore();
  end,

  handleChange = function(self)
    if (self.selectedChallenge ~= selectedChallenge) then
      local challenge = chalwheel.challenges[selectedChallenge];

      if (challenge and challenge.id and scrollTimers[challenge.id]) then
        scrollTimers[challenge.id].title = 0;
      end

      self.timers.title = 0;

      self.selectedChallenge = selectedChallenge;
    end
  end,

  render = function(self, deltaTime)
    self:setSizes();

    self:setLabels();

    gfx.Save();

    self:drawChallengeInfo(deltaTime);

    self:handleChange();

    self.search:render(deltaTime, {
      isActive = chalwheel.searchInputActive,
      searchText = chalwheel.searchText,
    });

    gfx.Restore();
  end,
};

local challengeList = {
  cache = { scaledW = 0, scaledH = 0 },
  currentPage = 1,
  cursor = Cursor.New(),
  labels = {
    x = {},
    y = 0,
    amounts = nil,
  },
  list = {
    margin = 0,
    timer = 1,
    w = { base = 0, max = 0 },
    h = { base = 0, item = 0 },
    x = 0,
    y = {
      base = 0,
      current = 0,
      previous = 0,
    },
  },
  order = {
    'collection',
    'difficulty',
    'sort',
  },
  scrollbar = Scrollbar.New(),
  selectedChallenge = 0,
  viewLimit = 6,
  
  setSizes = function(self)
    if ((self.cache.scaledW ~= scaledW) or (self.cache.scaledH ~= scaledH)) then
      self.list.w.base = scaledW - ((scaledW / 20) * 3) - challengeInfo.panel.w;
      self.list.w.max = self.list.w.base - (self.list.w.base / 10);
      self.list.h.base = math.floor(self.list.w.base * 1.125);
      self.list.h.item = self.list.h.base // 7.5;
      self.list.margin = (self.list.h.base - (self.list.h.item * self.viewLimit))
      / (self.viewLimit - 1);

      self.list.x = (scaledW / 10) + challengeInfo.panel.w;
      self.list.y.base = scaledH - (scaledH / 20) - self.list.h.base;

      local width = self.list.w.base // 3.3;
      local gutter = (self.list.w.base - (width * 3)) // 2;

      self.labels.x = {};
      self.labels.x[1] = self.list.x - 1;
      self.labels.x[2] = self.labels.x[1] + (width * 1.5) + gutter;
      self.labels.x[3] = self.labels.x[2] + (width * 0.9);
      self.labels.y = (scaledH / 20) - 2;

      self.cursor:setSizes({
        x = self.list.x,
        y = self.list.y.base,
        w = self.list.w.base,
        h = self.list.h.item,
        margin = self.list.margin,
      });

      if (#chalwheel.challenges > self.viewLimit) then
        self.scrollbar:setSizes({
          screenW = scaledW,
          y = self.list.y.base,
          h = self.list.h.base,
        });
      end

      self.cache.scaledW = scaledW;
      self.cache.scaledH = scaledH;
    end
  end,

  setLabels = function(self)
    if (not self.labels.amounts) then
      self.labels.amounts = {
        of = New.Label({
          font = 'medium',
          text = 'OF',
          size = 18,
        }),
      };

      self.labels.amounts.current = ScoreNumber.New({
        digits = 4,
        isScore = false,
        sizes = { 18 },
      });
      self.labels.amounts.total = ScoreNumber.New({
        digits = 4,
        isScore = false,
        sizes = { 18 },
      });
    end
  end,

  drawLabels = function(self)
    gfx.Save();

    for i, name in ipairs(self.order) do
      drawLabel({
        x = self.labels.x[i],
        y = self.labels.y,
        color = 'normal',
        label = labels[name],
      });
    end

    gfx.Restore();
  end,

  drawChallengeList = function(self, deltaTime)
    if (self.list.timer < 1) then
      self.list.timer = math.min(self.list.timer + (deltaTime * 4), 1);
    end

    local change = (self.list.y.current - self.list.y.previous)
      * smoothstep(self.list.timer);
    local offset = self.list.y.previous + change;
    local y = 0;

    self.list.y.previous = offset;

    gfx.Save();

    gfx.Translate(self.list.x, self.list.y.base + offset);

    for i = 1, #chalwheel.challenges do
      local challenge = chalwheel.challenges[i];
      local isSelected = i == self.selectedChallenge;

      y = y + self:drawChallenge(deltaTime, i, challenge, y, isSelected);
    end

    gfx.Restore();
  end,

  drawChallenge = function(self, deltaTime, i, challenge, initialY, isSelected)
    if (not challenge) then return end;

    cacheChallenge(challenge);

    local alpha = (isSelected and 255) or 80;
    local isVisible = List.isVisible(i, self.viewLimit, self.currentPage);
    local title = challengeCache[challenge.id].title.name;
    
    local x = self.list.w.base / 20;
    local y = initialY + (self.list.h.item / 5);

    if (isVisible) then
      drawRectangle({
        x = 0,
        y = initialY,
        w = self.list.w.base,
        h = self.list.h.item,
        alpha = 120,
        color = 'dark',
      });

      drawLabel({
        x = x,
        y = y,
        alpha = alpha,
        color = 'normal',
        label = labels.challenge,
      });

      y = y + (labels.challenge.h * 1.25);

      if (title.w > self.list.w.max) then
        if (isSelected) then
          challengeCache[challenge.id].title.timer =
            challengeCache[challenge.id].title.timer + deltaTime;
        else
          challengeCache[challenge.id].title.timer = 0;
        end

        drawScrollingLabel({
          x = x,
          y = y,
          alpha = alpha,
          color = 'white',
          label = title,
          scale = scalingFactor,
          timer = challengeCache[challenge.id].title.timer,
          width = self.list.w.max,
        });
      else
        drawLabel({
          x = x,
          y = y,
          alpha = alpha,
          color = 'white',
          label = title,
        });
      end
    else
      challengeCache[challenge.id].title.timer = 0;
    end

    return self.list.h.item + self.list.margin;
  end,

  drawChallengeAmount = function(self)
    self.labels.amounts.current:setInfo({ value = self.selectedChallenge });
    self.labels.amounts.total:setInfo({ value = #chalwheel.challenges });

    gfx.Save();

    gfx.Translate(
      self.list.x + self.list.w.base + (scaledW / 40) + 5,
      scaledH - (scaledH / 40) - 12
    );

    self.labels.amounts.current:draw({
      x = -(self.labels.amounts.of.w + (self.labels.amounts.total.w * 2) + 30),
      y = 0,
      align = 'right',
      color = 'normal',
    });

    drawLabel({
      x = -((self.labels.amounts.total.w * 1.25) + 12),
      y = 0,
      align = 'right',
      color = 'normal',
      label = self.labels.amounts.of,
    });

    self.labels.amounts.total:draw({
      x = -(self.labels.amounts.total.w),
      y = 0,
      align = 'right',
      color = 'normal',
    });

    gfx.Restore();
  end,

  drawNoChallengeMessage = function(self)
    gfx.Save();

    gfx.Translate(
      self.list.x + (self.list.w.base / 2),
      self.list.y.base + (self.list.h.base / 2)
    );

    gfx.BeginPath();
    alignText('middle');
    loadFont('normal');
    gfx.FontSize(48);
    setFill('dark', 255 * 0.5);
    gfx.Text('NO CHALLENGES FOUND', 1, 1);
    setFill('white');
    gfx.Text('NO CHALLENGES FOUND', 0, 0);

    gfx.Restore();
  end,

  handleChange = function(self)
    if (selectedChallenge ~= self.selectedChallenge) then
      self.selectedChallenge = selectedChallenge;

      self.currentPage = List.getCurrentPage({
        current = self.selectedChallenge,
        limit = self.viewLimit,
        total = #chalwheel.challenges,
      });
  
      self.list.y.current = (self.list.h.base + self.list.margin)
        * (self.currentPage - 1);
      self.list.y.current = -self.list.y.current;
  
      self.list.timer = 0;
  
      self.cursor:setPosition({
        current = self.selectedChallenge,
        total = self.viewLimit,
        vertical = true,
      });

      self.cursor.timer.flicker = 0;
  
      self.scrollbar:setPosition({
        current = self.selectedChallenge,
        total = #chalwheel.challenges,
      });
    end;
  end,

  render = function(self, deltaTime)
    self:setSizes();

    self:setLabels();

    gfx.Save();

    self:drawLabels();

    if (#chalwheel.challenges > 0) then
      self:drawChallengeList(deltaTime);

      self.cursor:render(deltaTime, {
        size = 16,
        stroke = 1.5,
        vertical = true,
      });

      self:drawChallengeAmount();
    else
      self:drawNoChallengeMessage();
    end

    if (#chalwheel.challenges > self.viewLimit) then
      self.scrollbar:render(deltaTime);
    end

    self:handleChange();

    gfx.Restore();
  end,
};

local miscInfo = {
  labels = nil,

  render = function(self)
    if (not self.labels) then
      self.labels = {
        bta = New.Label({
          font = 'medium',
          text = '[BT-A]',
          size = 20,
        }),
        showControls = New.Label({
          font = 'medium',
          text = 'SHOW CONTROLS',
          size = 20,
        }),
        volforce = {
          label = New.Label({
            font = 'medium',
            text = 'VF',
            size = 20,
          }),
        },
      };

      self.labels.volforce.value = New.Label({ 
        font = 'number',
        text = '',
        size = 20,
      });
    end

    local forceValue = get(userData.contents, 'volforce', 0);
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

      gfx.Translate(challengeInfo.panel.w + 2, 0);

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

  challengeInfo:render(deltaTime);
  challengeList:render(deltaTime);
  miscInfo:render();

  gfx.Restore();
end

challenges_changed = function(withAll)
	if (not withAll) then return end
end

get_page_size = function()
  return 6;
end

set_index = function(newChallenge)
  selectedChallenge = newChallenge;

  if (previousChallenge ~= selectedChallenge) then
    game.PlaySample('click_song');
  end

  previousChallenge = selectedChallenge;
end;