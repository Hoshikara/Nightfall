---@class NauticaChart
---@field created_at string # Upload date formatted `YYYY-MM-DD hh:mm:ss`
---@field difficulty integer # Chart difficulty index, from `1` to `4`
---@field effector string # Chart effector
---@field level integer # Chart level
---@field song_id string # Chart UUID
---@field updated_at string # Update date formatted `YYYY-MM-DD hh:mm:ss`
---@field user_id string # Uploader UUID
---@field video_link string # Link to preview video
NauticaChart = {};

---@class NauticaLinks
---@field first string # Link to first songs page
---@field last string # Link to last songs page
---@field next string # Link to next songs page
NauticaLinks = {};

---@class NauticaMeta
---@field current_page integer # Current song page
---@field from integer # Starting song index
---@field last_page integer # Last song page
---@field path string # Base path
---@field per_page integer # Amount of songs per page
---@field to integer # Ending song index
---@field total integer # Song amount
NauticaMeta = {};

---@class NauticaSong
---@field artist string # Song artist
---@field cdn_download_url string # CDN Download URL, contains spaces
---@field charts NauticaChart[]
---@field created_at string # Upload date formatted `YYYY-MM-DD hh:mm:ss`
---@field description string # Uploader description
---@field downloads integer # Number of downloads
---@field has_preview integer # `0 = false`, `1 = true`
---@field hidden integer # `0 = false`, `1 = true`
---@field id string # Song UUID
---@field jacket_filename string # Song jacket file name, contains extension
---@field jacket_url string # CDN URL to song jacket file
---@field mojibake integer # `0 = false`, `1 = true`
---@field preview_url string # CDN URL to song preview file
---@field tags NauticaSongTag[]
---@field title string # Song title
---@field updated_at string # Upload date formatted `YYYY-MM-DD hh:mm:ss`
---@field uploaded_at string # Upload date formatted `YYYY-MM-DD hh:mm:ss`
---@field user NauticaUser
---@field user_id string # Uploader UUID
NauticaSong = {};

---@class NauticaSongTag
---@field created_at string # Upload date formatted `YYYY-MM-DD hh:mm:ss`
---@field id string # Tag UUID
---@field song_id string # Song UUID
---@field updated_at string # Update date formatted `YYYY-MM-DD hh:mm:ss`
---@field value string # Tag text
NauticaSongTag = {};

---@class NauticaUser
---@field created_at string # Account creation date formatted `YYYY-MM-DDThh:mm:ss.sTZD`
---@field id string # User UUID
---@field name string # Username
---@field songCount integer # Amount of songs uploaded
---@field urlRoute string # User endpoint, e.g. `/users/ecf94b48-dfc3-4ad1-b234-e3802ed8b848`
NauticaUser = {};

---@class NauticaResponseBody
---@field links NauticaLinks # Links to first, last, and next song pages
---@field meta NauticaMeta # Nautica metadata
---@field data NauticaSong[]
NauticaResponseBody = {};