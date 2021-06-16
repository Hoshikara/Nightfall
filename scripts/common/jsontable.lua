local JSON = require('lib/json');

-- Gets the path to the JSON file
---@param fileName string
---@return string
local getPath = function(fileName)
	return path.Absolute(('skins/%s/JSON/%s.json'):format(game.GetSkin(), fileName));
end

---@class JSONTableClass
local JSONTable = {
	-- JSONTable constructor
	---@param this JSONTableClass
	---@param fileName string
	---@return JSONTable
	new = function(this, fileName)
		---@class JSONTable : JSONTableClass
		local t = {};
		local path = getPath(fileName);
		local data = io.open(path, 'r');
		local decoded = {};

		if (data) then
			local raw = data:read('*all');

			if (raw == '') then
				data:write(JSON.encode(decoded));
			else
				decoded = JSON.decode(raw);
			end

			data:close();
		else
			error(('Error loading JSON: File does not exist: %s'):format(path));
		end

		t.data = decoded;
		t.path = path;

		setmetatable(t, this);
		this.__index = this;

		return t;
	end,

	-- Refetch JSON data to reflect any new changes
	---@param this JSONTable
	refetch = function(this)
		local data = io.open(this.path, 'r');
		local decoded = {};

		if (data) then
			local raw = data:read('*all');

			if (raw == '') then
				data:write(JSON.encode(decoded));
			else
				decoded = JSON.decode(raw);
			end

			data:close();
		end

		this.data = decoded;
	end,

	-- Overwrite all contents of the table
	---@param this JSONTable
	---@param t table
	overwrite = function(this, t)
		local data = io.open(this.path, 'w');

		data:write(JSON.encode(t));

		data:close();
	end,

	-- Assign a new item to the table by key/value pair
	---@param this JSONTable
	---@param k string
	---@param v any
	set = function(this, k, v)
		local data = io.open(this.path, 'w');
		
		this.data[k] = v;

		data:write(JSON.encode(this.data));

		data:close();
	end,

	-- Get an item or the whole table
	---@param this JSONTable
	---@param k? string
	---@param refetch? boolean
	---@return any
	get = function(this, refetch, k)
		if (refetch) then this:refetch(); end

		if (k) then return this.data[k]; end

		return this.data;
	end,
};

return JSONTable;