-- Miscellaneous information

---@alias Alignment
---| '"center"'
---| '"left"' # Default
---| '"leftMid"'
---| '"middle"'
---| '"right"'
---| '"rightMid"'

---@alias Color
---| '"black"'
---| '"dark"'
---| '"light"'
---| '"med"'
---| '"norm"' # Default
---| '"red"'
---| '"redDark"'
---| '"white"'
---| '{ r, g, b }'

---@alias Font
---| '"bold"'
---| '"jp"' # Default
---| '"med"'
---| '"mono"'
---| '"norm"'
---| '"num"'

---@alias deltaTime number # Difference (delta) in time since the last frame, evaluates to `1 / current FPS`