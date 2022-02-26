---@param ctx TitlescreenContext
---@return table<string, TitlescreenButton[]>
local function makeTitlescreenButtons(ctx)
  return {
    MainMenu = {
      {
        event = function()
          ctx.currentBtn = 1
          ctx.currentPage = "PlayOptions"
        end,
        text = makeLabel("Medium", "PLAY"),
      },
      {
        event = Menu.DLScreen,
        text = makeLabel("Medium", "NAUTICA"),
      },
      {
        event = function()
          -- ctx.currentBtn = 1
          -- ctx.currentPage = "MainMenu"
          -- ctx.currentView = "Controls"
        end,
        text = makeLabel("Medium", "CONTROLS"),
      },
      {
        event = function()
          ctx.checkForUpdate = true
          ctx.currentBtn = 1

          Menu.Settings()
        end,
        text = makeLabel("Medium", "SETTINGS"),
      },
      {
        event = Menu.Exit,
        text = makeLabel("Medium", "EXIT"),
      },
    },
    PlayOptions = {
      {
        event = Menu.Start,
        text = makeLabel("Medium", "SINGLEPLAYER"),
      },
      {
        event = Menu.Multiplayer,
        text = makeLabel("Medium", "MULTIPLAYER"),
      },
      {
        event = Menu.Challenges,
        text = makeLabel("Medium", "CHALLENGES"),
      },
      {
        event = function()
          ctx.currentBtn = 1
          ctx.currentPage = "PlayOptions"
          ctx.currentView = "GameplaySettings"
        end,
        text = makeLabel("Medium", "GAMEPLAY SETTINGS"),
      },
      {
        event = function()
          -- ctx.currentBtn = 1
          -- ctx.currentPage = "PlayOptions"
          -- ctx.currentView = "PlayerInfo"
        end,
        text = makeLabel("Medium", "PLAYER INFO"),
      },
    },
  }
end

return makeTitlescreenButtons
