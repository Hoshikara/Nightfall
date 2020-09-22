local isNil = function(value)
  return (type(value) == 'nil');
end

local isTable = function(value)
  return (type(value) == 'table');
end

local split = function(str, match)
  local words = {};

  for word in string.gmatch(str, string.format('([^%s]*)', match)) do
    table.insert(words, word);
  end

  return words;
end

local get = function(tbl, path, default)
  local subpaths = split(path, '.');
  local current = tbl;
  local c = 1;

  while (not isNil(subpaths[c])) do
    if (not isTable(current)) then
      return default;
    end

    current = current[subpaths[c]];
    c = c + 1;
  end

  return current or default;
end

return {
  get = get,
};