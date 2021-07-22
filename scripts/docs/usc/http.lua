-- Global `Http` table

-- Executes a blocking `GET` request
---@param url string
---@param header table<string, string>
---@return HttpResponse
Get = function(url, header) end

-- Executes a `GET` request and calls `callback` with `HttpResponse` as a parameter
---@param url string
---@param header table<string, string>
---@param callback function
GetAsync = function(url, header, callback) end

-- Executes a blocking `POST` request
---@param url string
---@param content string
---@param header table<string, string>
---@return HttpResponse
Post = function(url, content, header) end

-- Executes a `POST` request and calls `callback` with `HttpResponse` as a parameter
---@param url string
---@param header table<string, string>
---@param callback function
PostAsync = function(url, header, callback) end

---@class HttpResponse
---@field cookies string
---@field double number
---@field header table<string, string>
---@field status integer
---@field error string
---@field text string
---@field url string
HttpResponse = {};

---@class Http
Http = {
  Get = Get,
  GetAsync = GetAsync,
  Post = Post,
  PostAsync = PostAsync,
};