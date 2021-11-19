---@meta

---
---The global `Http` table.  
---Available for all scripts.  
---[Official Documentation](https://unnamed-sdvx-clone.readthedocs.io/en/latest/http.html)
---
---@class Http
Http = {}

---
---Executes a blocking `GET` request.
---
---@param url string
---@param header header
---@return response response
function Http.Get(url, header) end

---
---Executes a non-blocking `GET` request.
---
---@param url string
---@param header header
---@param callback function # Function called with `response` when the request is complete.
---@return response response
function Http.GetAsync(url, header, callback) end

---
---Executes a blocking `POST` request.
---
---@param url string
---@param content string
---@param header header
---@return response response
function Http.Post(url, content, header) end

---
---Executes a non-blocking `POST` request.
---
---@param url string
---@param header header
---@param callback function # Function called with `response` when the request is complete.
---@return response response
function Http.PostAsync(url, header, callback) end
