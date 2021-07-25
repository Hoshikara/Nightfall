---@alias Alignment
---| "'center'"
---| "'left'" # Default
---| "'leftMid'"
---| "'middle'"
---| "'right'"
---| "'rightMid'"

---@alias Color
---| "'black'"
---| "'dark'"
---| "'light'"
---| "'med'"
---| "'norm'" # Default
---| "'red'"
---| "'redDark'"
---| "'white'"
---| '{ [1]: integer, [2]: integer, [3]: integer }'

---@alias Font
---| "'bold'"
---| "'jp'" # Default
---| "'med'"
---| "'mono'"
---| "'norm'"
---| "'num'"

---@alias RGB '{ [1]: integer, [2]: integer, [3]: integer }'

-- `Animation:new` params
---@class AnimationConstructorParams
---@field alpha? number # Default `1`
---@field blendOp? integer # Default `0`, refer to `gfx` table for values
---@field centered? boolean # Default `false`
---@field fps? number # Default `30`
---@field frameCount? integer # Default `1`
---@field path string # Path to the folder containing the animation frames
---@field loop? boolean # Default `false`
---@field loopPoint? integer # Default `1` # Frame number to loop the animation from
---@field scale? number # Default `1`
AnimationConstructorParams = {};

---@class AnimationState
---@field frame integer # Current frame of the animation
---@field queued boolean # Whether or not the animation is queued up to be played
---@field timer number # Timer to determine when the next frame should be played
AnimationState = {};

-- `Background:render` params
---@class BackgroundRenderParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field w? number # Default `Window x-resolution`
---@field h? number # Default `Window y-resolution`
---@field centered? boolean # Default `false`
BackgroundRenderParams = {};

-- `Button:render` params
---@class ButtonRenderParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field accentAlpha? number # Default `1`
---@field alpha? number # Default `1`
ButtonRenderParams = {};

-- `Cursor:new` params
---@class CursorConstructorParams
---@field size? number # Default `6`
---@field stroke? number # Default `1`
---@field type? string # `'vertical'` (default), `'horizontal'`, `'grid`
CursorConstructorParams = {};

-- `Cursor:setSizes` params
---@class CursorSetSizesParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field w? number # Default `0`
---@field h? number # Default `0`
---@field margin? number # Default `0`, spacing between items
CursorSetSizesParams = {};

-- `Cursor:draw` params
---@class CursorDrawParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field w? number # Default `0`
---@field h? number # Default `0`
---@field alpha? number # Default `255`
---@field alphaMod? number # Default `1`
---@field size? number # Default `6`
CursorDrawParams = {};

-- `Cursor:render` params
---@class CursorRenderParams
---@field h? number  # Default `0`
---@field alphaMod? number # Default `1`
---@field curr? integer # Default `1`, current item index
---@field forceFlicker? boolean # Default `false`
---@field total? integer # Default `1`, total number of visible items
CursorRenderParams = {};

-- `DialogBox:render` params
---@class DialogBoxRenderParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field alpha? number # Default `1`
DialogBoxRenderParams = {};

-- `drawRect` params
---@class DrawRectParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field w? number # Default `1000`
---@field h? number # Default `1000`
---@field alpha? number # Default `255`
---@field blendOp? integer # Default `0`, refer to `gfx` table for values
---@field centered? boolean # Default `false`
---@field color? Color # Default `'norm'`
---@field fast? boolean # Default `false`
---@field image? any # Default `nil`, image created by `gfx.CreateImage` or `gfx.CreateSkinImage`
---@field scale? number # Default `1`
---@field stroke? SetStrokeParams # Default `nil`
---@field tint? RGB # Default `nil`
DrawRectParams = {};

-- `Image:draw` params
---@class ImageDrawParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field w? number # Default `500`
---@field h? number # Default `500`
---@field alpha? number # Default `1`
---@field blendOp? integer # Default `0`, refer to `gfx` table for values
---@field centered? boolean # Default `nil`
---@field tint? RGB # Default `nil`
---@field scale? number # Default `1`
---@field stroke? SetStrokeParams # Default `nil`
ImageDrawParams = {};

---@class IngamePreviewTab
---@field component? table
---@field h number
---@field heading Label
---@field render? function
---@field status IngamePreviewSetting
---@field settings IngamePreviewSetting[]
---@field text? Label[]
IngamePreviewTab = {};

-- Table returned by `makeSetting`
---@class IngamePreviewSetting
---@field color Color
---@field event function
---@field idx? integer
---@field label Label
---@field multi? number
---@field options? string[]
---@field value number|string
---@field valueLabel Label
IngamePreviewSetting = {};

-- `Label:new` params
---@class LabelConstructorParams
---@field color? Color # Default `'norm'`
---@field font? Font # Default `'jp'`
---@field size? number # Default `50`
---@field text? string|LabelMulticolorText[] # Default `'LABEL TEXT'`
LabelConstructorParams = {};

-- `Label:draw` params
---@class LabelDrawParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field align? Alignment # Default `'left'`
---@field alpha? number # Default `255`
---@field color? Color # Default `'norm'`
---@field maxWidth? number # Default `-1`
---@field text? string # Default `nil`
---@field update? boolean # Default `false`
LabelDrawParams = {};

-- `Label:drawScrolling` params
---@class LabelDrawScrollingParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field align? Alignment # Default `left`
---@field alpha? number # Default `255`
---@field color? Color # Default `norm`
---@field scale? number # Default `1`
---@field timer? number # Default `0`
---@field width? number # Default `0`
LabelDrawParams = {};

---@class LabelMulticolorText
---@field color? string # Default `'norm'`
---@field text? string # Default `'LABEL TEXT'`
LabelMulticolorText = {};

-- `Label:update` params
---@class LabelUpdateParams
---@field font? string # Default `'jp'`
---@field size? number # Default `50`
---@field text? string # Default `'LABEL TEXT'`
LabelUpdateParams = {};

-- `List:setSizes` params
---@class ListSetSizesParams
---@field max? integer # Default `0`, number of items on a page
---@field shift? number # Default `0`, width/height of a page in pixels
ListSetSizesParams = {};

-- `List:handleChange` params
---@class ListHandleChangeParams
---@field duration? number # Default `0.25`, duration of the scrolling transition
---@field isPortrait? boolean # Default `nil`, used for prevent unexpected behavior when switching game window orientation
---@field watch integer # Current item index to watch for changes
ListHandleChangeParams = {};

-- `makeSetting` params
---@class MakeSettingParams
---@field default any
---@field format? string
---@field key string
---@field label string
---@field max? number
---@field min? number
---@field multi? number
---@field options? string[]
---@field step? number
MakeSettingParams = {};

---@class RingAnimationEffectState
---@field alpha integer
---@field playIn boolean
---@field playOut boolean
---@field timer number
RingAnimationEffectState = {};

-- `ScoreNumber:new` params
---@class ScoreNumberConstructorParams
---@field digits? integer # Default `4`
---@field size? integer # Default `100`
---@field val? integer # Default `0`
ScoreNumberConstructorParams = {};

-- ScoreNumber:draw` params
---@class ScoreNumberDrawParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field align? Alignment # Default `'left'`
---@field alpha? integer # Default `255`
---@field color? Color # Default `'norm'`
---@field offset? number # Default `0`, y-offset for smaller numbers
---@field val? number # Default `0`
ScoreNumberDrawParams = {};

-- `Scrollbar:setSizes` params
---@class ScrollbarSetSizesParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field h? number # Default `0`
ScrollbarSetSizesParams = {};

-- `Scrollbar:render` params
---@class ScrollbarRenderParams
---@field alphaMod? number # Default `1`
---@field color? Color # Default `'norm'`
---@field curr? integer # Default `1`, current item index
---@field total? integer # Default `1`, total number items
ScrollbarRenderParams = {};

-- `SearchBar:setSizes` params
---@class SearchBarSetSizesParams
---@field x? number # Default `0`
---@field y? number # Default `0`
---@field w? number # Default `0`
---@field h? number # Default `0`
SearchBarSetSizesParams = {};

-- `SearchBar:render` params
---@class SearchBarRenderParams
---@field input? string # Default `''`
---@field isActive? boolean # Default `false`
SearchBarRenderParams = {};

-- `setStroke` params
---@class SetStrokeParams
---@field alpha? integer # Default `255`
---@field color? Color # Default `'norm'`
---@field size? number # Default `1`
SetStrokeParams = {};

-- `Spinner:new` params
---@class SpinnerConstructorParams
---@field color? Color # Default `'norm'`
---@field size? number # Default `12`
---@field thickness? number # Default `3`
SpinnerConstructorParams = {};