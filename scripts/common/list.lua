local getCurrentPage = function(params)
  local current = get(params, 'current');
  local limit = get(params, 'limit');
  local total = get(params, 'total');

  if ((not current) or (not limit) or (not total)) then
    return 1;
  end

  local minimum = 1;
  local maximum = ((total < limit) and total) or limit;
  local pages = {};
  local pageCount = math.ceil(total / limit);

  for i = 1, pageCount do
    pages[i] = { lower = minimum, upper = maximum };

    minimum = maximum + 1;
    maximum = (((maximum + limit) < total) and (maximum + limit))
      or total;
  end

  for page, bounds in ipairs(pages) do
    if ((current >= bounds.lower) and (current <= bounds.upper)) then
      return page;
    end
  end

  return 1;
end

return { getCurrentPage = getCurrentPage };