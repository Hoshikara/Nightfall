return function(filename)
  local JSON = require('lib/JSON');
  local path = path.Absolute(
    string.format('skins/%s/JSON/%s.json', game.GetSkin(), filename)
  );
  local contents = io.open(path, 'r');
  local decoded = {};

  if (contents) then
    local raw = contents:read('*all');

    if (raw == '') then
      contents:write(JSON.encode(decoded));
    else
      decoded = JSON.decode(raw);
    end

    contents:close();
  else
    local throwError = createError('Error loading JSON');

    throwError(string.format('File does not exist: %s', path));
  end

  return {
    contents = decoded,
    JSON = JSON,
    path = path,

    set = function(self, key, value)
      local contents = io.open(self.path, 'w');

      self.contents[key] = value;

      contents:write(self.JSON.encode(self.contents));

      contents:close();
    end,
  };
end