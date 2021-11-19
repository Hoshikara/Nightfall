---@meta

---
---The global `gfx` table.  
---Available for all scripts.  
---[Official Documentation](https://unnamed-sdvx-clone.readthedocs.io/en/latest/gfx.html)
---
---@class gfx
gfx = {
  BLEND_ZERO = 1,
  BLEND_ONE = 2,
  BLEND_SRC_COLOR = 4,
  BLEND_ONE_MINUS_SRC_COLOR = 8,
  BLEND_DST_COLOR = 16,
  BLEND_ONE_MINUS_DST_COLOR = 32,
  BLEND_SRC_ALPHA = 64,
  BLEND_ONE_MINUS_SRC_ALPHA = 128,
  BLEND_DST_ALPHA = 256,
  BLEND_ONE_MINUS_DST_ALPHA = 512,
  BLEND_SRC_ALPHA_SATURATE = 1024,

  BLEND_OP_SOURCE_OVER = 0,
  BLEND_OP_SOURCE_IN = 1,
  BLEND_OP_SOURCE_OUT = 2,
  BLEND_OP_ATOP = 3,
  BLEND_OP_DESTINATION_OVER = 4,
  BLEND_OP_DESTINATION_IN = 5,
  BLEND_OP_DESTINATION_OUT = 6,
  BLEND_OP_DESTINATION_ATOP = 7,
  BLEND_OP_LIGHTER = 8,
  BLEND_OP_COPY = 9,
  BLEND_OP_XOR = 10,

  IMAGE_GENERATE_MIPMAPS = 1,
  IMAGE_REPEATX = 2,
  IMAGE_REPEATY = 4,
  IMAGE_FLIPY = 8,
  IMAGE_PREMULTIPLIED = 16,
  IMAGE_NEAREST = 32,

  LINE_BUTT = 0,
  LINE_ROUND = 1,
  LINE_SQUARE = 2,
  LINE_BEVEL = 3,
  LINE_MITER = 4,

  -- Horizontal Alignment
  TEXT_ALIGN_LEFT = 1,
  TEXT_ALIGN_CENTER = 2,
  TEXT_ALIGN_RIGHT = 4,

  -- Vertical Alignment
  TEXT_ALIGN_TOP = 8,
  TEXT_ALIGN_MIDDLE = 16,
  TEXT_ALIGN_BOTTOM = 32,
  TEXT_ALIGN_BASELINE = 64,
}

---
---Creates an arc-shaped sub-path with `(x, y)` as the center.
---
---@param x number
---@param y number
---@param radius number
---@param a0 number # The starting angle in radians.
---@param a1 number # The ending angle in radians.
---@param direction integer #
---* `1` = Counter-Clockwise
---* `2` = Clockwise
function gfx.Arc(x, y, radius, a0, a1, direction) end

---
---Adds an arc segment at the corner defined by the previous point and the two specified points.
---
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param radius number
function gfx.ArcTo(x1, y1, x2, y2, radius) end

---
---Clears any defined paths to begin drawing a new shape.
---
function gfx.BeginPath() end

---
---Adds a cubic bezier segment from the previous point to the specified point.  
---The two control points are `(cx1, cy1)` and `(cx2, cy2)`.
---
---@param cx1 number
---@param cy1 number
---@param cx2 number
---@param cy2 number
---@param x number
---@param y number
function gfx.BezierTo(cx1, cy1, cx2, cy2, x, y) end

---
---Creates a box gradient that can be used by `gfx.FillPaint` or `gfx.StrokePaint`.
---
---@param x number
---@param y number
---@param w number
---@param h number
---@param radius number
---@param feather number
function BoxGradient(x, y, w, h, radius, feather) end

---
---Creates a circle-shaped sub-path with `(x, y)` as the center.
---
---@param x number
---@param y number
---@param radius number
function gfx.Circle(x, y, radius) end

---
---Closes the current sub-path with a line segment.
---
function gfx.ClosePath() end

---
---Loads the specified image.
---
---@param imagePath imagePath
---@param options integer # Refer to `gfx.IMAGE_*` for options.
function gfx.CreateImage(imagePath, options) end

---
---Creates a cached text that can be used by `gfx.DrawLabel`.
---
---@param text string
---@param size integer
---@param makeMonospace boolean
function gfx.CreateLabel(text, size, makeMonospace) end

---
---Creates a `ShadedMesh` object.
---
---@param materialName string
---@param materialPath? string # An optional file path to the material, otherwise loads from the `shaders` folder of the current skin.  
---`<materialName>.fs` and `<materialName>.vs` must exist at either location.
---@return ShadedMesh
function gfx.CreateShadedMesh(materialName, materialPath) end

---
---Loads the specified image from the `textures` folder of the current skin.
---
---@param imagePath imagePath
---@param options integer # Refer to `gfx.IMAGE_*` for options.
function gfx.CreateSkinImage(imagePath, options) end

---
---Draws a label created with `gfx.CreateLabel`.  
---Labels will be drawn on top of other drawn elements.
---
---@param label label
---@param x number
---@param y number
---@param maxWidth? number # If `> 0`, the label is scaled width-wise to fit.
function gfx.DrawLabel(label, x, y, maxWidth) end

---
---Creates an ellipse-shaped sub-path with `(x, y)` as the center.
---
---@param x number
---@param y number
---@param radiusX number
---@param radiusY number
function gfx.Ellipse(x, y, radiusX, radiusY) end

---
---Creates a rectangle shaped sub-path.
---`FastRect` will be drawn on top of other drawn elements.
---
---@param x number
---@param y number
---@param w number
---@param h number
function gfx.FastRect(x, y, w, h) end

---
---Draws the given text at the specified location.  
---`FastText` will be drawn on top of other drawn elements.
---
---@param text string
---@param x number
---@param y number
function gfx.FastText(text, x, y) end

---
---Gets the size of a fast text.
---
---@param text string
---@return number w, number h
function gfx.FastTextSize(text) end

---
---Fills the current path with the current fill style.
---
function gfx.Fill() end

---
---Sets the current fill style to a solid color.
---
---@param r integer
---@param g integer
---@param b integer
---@param a? integer # Default: `255`
function gfx.FillColor(r, g, b, a) end

---
---Sets the current fill style to a paint.
---
---@param paint paint
function gfx.FillPaint(paint) end

---
---Sets the font face for the current text style.
---
---@param font string
function gfx.FontFace(font) end

---
---Sets the font size for the current text style.
---
---@param size integer
function gfx.FontSize(size) end

---
---Forces the current render queue to be processed.  
---Any "fast" elements such as `FastRect`, `FastText` or `labels` will be rendered immediately rather than at the end of the render queue.
---
function gfx.ForceRender() end

---
---Gets the named shared texture ID of the shared texture created with `gfx.LoadSharedTexture`.
---
---@param name string
---@return integer ID # Usage is the same as images generated by `gfx.CreateImage`.
function gfx.GetSharedTexture(name) end

---
---Sets the global alpha value for all proceeding elements.  
---Elements that have their alpha set will be adjusted relative to the given value.
---
---@param alpha number
function gfx.GlobalAlpha(alpha) end

---
---Sets the composite operation with custom pixel arithmetic.  
---
---@param srcFactor integer # Refer to `gfx.BLEND_*` for options.
---@param dstFactor integer # Refer to `gfx.BLEND_*` for options.
function gfx.GlobalCompositeBlendFunc(srcFactor, dstFactor) end

---
---Sets the composite operation with custom pixel arithmetic for RGB and alpha components separately.
---
---@param srcRGB integer # Refer to `gfx.BLEND_*` for options.
---@param dstRGB integer # Refer to `gfx.BLEND_*` for options.
---@param srcAlpha integer # Refer to `gfx.BLEND_*` for options.
---@param dstAlpha integer # Refer to `gfx.BLEND_*` for options.
function gfx.GlobalCompositeBlendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha) end

---
---Sets the global composite operation.
---
---@param op integer # Refer to `gfx.BLEND_*` for options.
function gfx.GlobalCompositeOperation(op) end

---
---Sets the inner (i) and outer (o) colors for a gradient.
---
---@param ri integer
---@param gi integer
---@param bi integer
---@param ai integer
---@param ro integer
---@param go integer
---@param bo integer
---@param ao integer
function gfx.GradientColors(ri, gi, bi, ai, ro, bo, go, ao) end

---
---Creates an image pattern that can be used by `gfx.FillPaint` or `gfx.StrokePaint`.  
---The top-left location of the pattern is `(x, y)`.  
---The size of one image is `(w, h)`.
---
---@param x number
---@param y number
---@param w number
---@param h number
---@param angle number # The angle in radians.
---@param image image
---@param alpha number # The alpha value in range `[0, 1]`.
function gfx.ImagePattern(x, y, w, h, angle, image, alpha) end

---
---Draws the given `image` in the specified rectangle.
---Images will be stretched to fit if applicable.
---
---@param x number
---@param y number
---@param w number
---@param h number
---@param image image|animation
---@param alpha number # The alpha value in range `[0, 1]`.
---@param angle number # The angle in radians.
function gfx.ImageRect(x, y, w, h, image, alpha, angle) end

---
---Gets the width and height of the given `image`.
---
---@param image image
---@return number w, number h
function gfx.ImageSize(image) end

---
---Intersects the current scissor rectangle with the specified rectangle.
---
---@param x number
---@param y number
---@param w number
---@param h number
function gfx.IntersectScissor(x, y, w, h) end

---
---Gets the width and height of the given label.
---
---@param label label
---@return number w, number h
function gfx.LabelSize(label) end

---
---Creates a linear gradient that can be used by `gfx.FillPaint` or `gfx.StrokePaint`.  
---The starting coordinates are `(sx, sy)`.  
---The ending coordinates are `(ex, ey)`.
---
---@param sx number
---@param sy number
---@param ex number
---@param ey number
function gfx.LinearGradient(sx, sy, ex, ey) end

---
---Sets line ending drawing style.
---
---@param cap integer # Refer to `gfx.LINE_*` for options.
function gfx.LineCap(cap) end

---
---Sets the sharpness of path corners.
---
---@param join integer # Refer to `gfx.LINE_*` for options.
function gfx.LineJoin(join) end

---
---Creates a line segment joining the previous point to the specified point.
---
---@param x number
---@param y number
function gfx.LineTo(x, y) end

---
---Loads all images of the specified folder as frames to be used for an animation.  
---Created animations can be used the same way as images.
---
---@param folderPath string
---@param frameTime number # The amount of time per frame.
---@param loopCount? integer # Default: `0`
---@param compressed boolean #
---If `true`, the animation will be stored in RAM and decoded on-demand.  
---This results in higher CPU usage but lower RAM usage.
function gfx.LoadAnimation(folderPath, frameTime, loopCount, compressed) end

---
---Loads a persistent texture that can be accessed by the `name` in `gfx.GetSharedTexture` and `ShadedMesh:AddSharedTexture`.
---
---@param name string
---@param imagePath string
function gfx.LoadSharedTexture(name, imagePath) end

---
---Loads all images of the specified folder inside the `textures` folder of the current skin to be used for an animation.  
---Created animations can be used the same way as images.
---
---@param folderPath string
---@param frameTime number # The amount of time per frame.
---@param loopCount? integer # Default: `0`
---@param compressed boolean #
---If `true`, the animation will be stored in RAM and decoded on-demand.  
---This results in higher CPU usage but lower RAM usage.
function gfx.LoadSkinAnimation(folderPath, frameTime, loopCount, compressed) end

---
---Loads a persistent texture from the `textures` folder of the current skin that can be accessed by the `name` in `gfx.GetSharedTexture` and `ShadedMesh:AddSharedTexture`.
---
---@param name string
---@param imagePath imagePath
function gfx.LoadSharedSkinTexture(name, imagePath) end

---
---Loads a font to be used for the current text style.
---If the font is already loaded then it is set as the current style.
---
---@param name string
---@param fontPath string
function gfx.LoadFont(name, fontPath) end

---
---Loads an image outside of the main thread to prevent rendering lock-up.  
---Image will be loaded at full size unless `w` and `h` are provided.
---
---@param imagePath imagePath
---@param placeholder image
---@param w? number # Default: `0`
---@param h? number # Default: `0`
---@return any # Returns `placeholder` until the image is loaded.
function gfx.LoadImageJob(imagePath, placeholder, w, h) end

---
---Loads a font from the `fonts` folder of the current skin to be used for the current text style.  
---If the font is already loaded then it is set as the current style.
---
---@param name? string
---@param fontPath string
function gfx.LoadSkinFont(name, fontPath) end

---
---Loads a web image outside of the main thread to prevent rendering lock-up.  
---The image will be loaded at full size unless `w` and `h` are provided.
---
---@param url string # The web URL of image.
---@param placeholder image
---@param w? number # Default: `0`
---@param h? number # Default: `0`
---@return any # Returns `placeholder` until the image is loaded.
function gfx.LoadWebImageJob(url, placeholder, w, h) end

---
---Sets the miter limit for the current stroke style.
---
---@param limit number
function gfx.MiterLimit(limit) end

---
---Starts a sub-path at the specified point.
---
---@param x number
---@param y number
function gfx.MoveTo(x, y) end

---
---Adds a quadratic bezier segment from the previous point to the specified point.  
---The control point is `(cx, cy)`.
---
---@param cx number
---@param cy number
---@param x number
---@param y number
function gfx.QuadTo(cx, cy, x, y) end

---
---Creates a radial gradient that can be used by `gfx.FillPaint` or `gfx.StrokePaint`.  
---
---@param cx number
---@param cy number
---@param innerRadius number
---@param outerRadius number
function gfx.RadialGradient(cx, cy, innerRadius, outerRadius) end

---
---Creates a rectangle shaped sub-path.
---
---@param x number
---@param y number
---@param w number
---@param h number
function gfx.Rect(x, y, w, h) end

---
---Resets the current render state to default values.  
---This does not affect the render state stack.
---
function gfx.Reset() end

---
---Resets and disables scissoring.
---
function gfx.ResetScissor() end

---
---Resets any transforms done by `gfx.Rotate`, `gfx.Scale`, `gfx.Translate`, etc.
---
function gfx.ResetTransform() end

---
---Pops a render state from the render state stack.
---Render states can be pushed onto the stack using `gfx.Save`.
---
function gfx.Restore() end

---
---Rotates the current coordinates.
---
---@param angle number # The angle in radians.
function gfx.Rotate(angle) end

---
---Creates a rounded rectangle shaped sub-path.
---
---@param x number
---@param y number
---@param w number
---@param h number
---@param r number
function gfx.RoundedRect(x, y, w, h, r) end

---
---Creates a rounded rectangle shaped sub-path with varying radii for each corner.  
---The first corner radius is `r1` and continues clockwise.
---
---@param x number
---@param y number
---@param w number
---@param h number
---@param r1 number
---@param r2 number
---@param r3 number
---@param r4 number
function gfx.RoundedRectVarying(x, y, w, h, r1, r2, r3, r4) end

---
---Pushes the current render state onto the render state stack.  
---The render state can be popped from the stack using `gfx.Restore`.
---
function gfx.Save() end

---
---Scales the current coordinates.
---
---@param x number
---@param y number
function gfx.Scale(x, y) end

---
---Sets the current scissor rectangle.  
---Scissoring clips any rendering into a rectangle and is affected by the current transform.
---
---@param x number
---@param y number
---@param w number
---@param h number
function gfx.Scissor(x, y, w, h) end

---
---Multiplies all incoming image colors with the specified color.
---
---@param r integer
---@param g integer
---@param b integer
function gfx.SetImageTint(r, g, b) end

---
---Skews the current coordinates along the x-axis.
---
---@param angle number # The angle in radians.
function gfx.SkewX(angle) end

---
---Skews the current coordinates along the y-axis.
---
---@param angle number # The angle in radians.
function gfx.skewY(angle) end

---
---Strokes the current path with the current stroke style.
---
function gfx.Stroke() end

---
---Sets the current stroke style to a solid color.
---
---@param r integer
---@param g integer
---@param b integer
---@param a? integer # Default: `255`
function gfx.StrokeColor(r, g, b, a) end

---
---Sets the current stroke style to a paint.
---
---@param paint paint
function gfx.StrokePaint(paint) end

---
---Sets the width for the current stroke style.
---
---@param size number
function gfx.StrokeWidth(size) end

---
---Draws the given text at the specified location.
---
---@param text string
---@param x number
---@param y number
function gfx.Text(text, x, y) end

---
---Sets the text alignment for the current text style.
---
---@param alignment integer # Refer to `gfx.TEXT_ALIGN_*` for options.
function gfx.TextAlign(alignment) end

---
---Gets the bounding rectangle coordinates for the given text.
---
---@param x number
---@param y number
---@param text string
---@return number x1, number y1, number x2, number y2
function gfx.TextBounds(x, y, text) end

---
---Progresses the given animation.
---
---@param animation animation
---@param deltaTime deltaTime
function gfx.TickAnimation(animation, deltaTime) end

---
---Translates the current coordinates.
---
---@param x number
---@param y number
function gfx.Translate(x, y) end

---
---Updates the properties of a pattern.  
---The top-left location of the pattern is `(x, y)`.  
---The size of one image is `(w, h)`.
---
---@param pattern any # A pattern created by `gfx.ImagePattern`.
---@param x number
---@param y number
---@param w number
---@param h number
---@param angle number # The angle in radians.
---@param alpha number # The alpha in range `[0, 1]`.
function gfx.UpdateImagePattern(pattern, x, y, w, h, angle, alpha) end

---
---Updates the properties of a label.
---
---@param label label
---@param newText? string
---@param newSize? integer
function gfx.UpdateLabel(label, newText, newSize) end
