---@meta

---@alias animation any # An animation created with `gfx.LoadAnimation` or `gfx.LoadSkinAnimation`.

---@alias artist string # The chart's artist.

---@alias autoplay boolean # If `true`, autoplay was enabled.

---@alias autoFlags integer # If `> 0`, partial or all gameplay inputs were autoplayed.

---The badge achieved.
---* `0` = Manual Exit
---* `1` = No Clear
---* `2` = Effective Clear
---* `3` = Excessive Clear
---* `4` = Ultimate Chain
---* `5` = Perfect Ultimate Chain
---@alias badge integer

---The mesh blending mode.
---* `0` = Normal (default)
---* `1` = Additive
---* `2` = Multiply
---@alias blendMode integer

---@alias BPM string # The chart's BPM.

---An array of `Cursor`.
---* `[0]` = Left Cursor
---* `[1]` = Right Cursor
---@alias cursors { [0]: Cursor, [1]: Cursor }

---@alias delta integer # The delta of the hit from `0` in milliseconds.

---The difference (delta) in time since the last frame was rendered.  
---Approximately evaluates to `1 / current FPS`.
---@alias deltaTime number

---@alias difficultyHash string # The chart difficulty's `SHA-1` hash.

---The chart difficulty's difficulty index.
---* `0` = Novice
---* `1` = Advanced
---* `2` = Exhaust
---* `3` = Maximum
---@alias difficultyIndex integer

---@alias effector string # The chart difficulty's effector.

---The gauge type's specific options.  
---For `Blastive Rate` gauge type this is the `Blastive Level * 2`.
---@alias gaugeOption number

---The gauge type.
---* `0` = Effective
---* `1` = Excessive
---* `2` = Permissive
---* `3` = Blastive
---@alias gaugeType integer

---@alias gaugeValue number # The current/ending gauge percentage in range `[0, 1]`.

---@alias header table<string, string>

---@alias illustrator string # The chart difficulty's jacket illustrator.

---@alias image any # An image created with `gfx.CreateImage` or `gfx.CreateSkinImage`.

---@alias imagePath string # The file path to the image.

---@alias jacketPath string # The file path to the chart's jacket image.

---@alias label any # A label created with `gfx.CreateLabel`.

---@alias level integer # The chart difficulty's level.

---@alias mirror boolean # If `true`, mirror mode was enabled.

---A pattern created by any of the following:
---* `gfx.ImagePattern`
---* `gfx.BoxGradient`
---* `gfx.LinearGradient`
---* `gfx.RadialGradient`
---@alias paint any

---@alias playerName string # The name of the player.

---@alias random boolean # If `true`, random mode was enabled.

---The rating of the hit.
---* `0` = Miss
---* `1` = Near
---* `2` = Critical
---* `3` = Idle Press
---@alias rating integer

---@alias score integer # The current/ending score value in range `[0, 10,000,000]`.

---@alias scores Score[] # An array of the chart difficulty's scores.

---@alias timestamp integer # The score's set date in Unix time.

---@alias title string # The chart's title.

---@alias uniformName string # The name of the uniform variable in the shader code.

---@alias userId string # The user ID of the player.
