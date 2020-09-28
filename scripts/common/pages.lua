local getPageBounds = function(viewLimit, totalItems, selected)
  local minimum = 1;
  local maximum = ((totalItems < viewLimit) and totalItems) or viewLimit;
  local pages = {};
  local pageCount = math.ceil(totalItems / viewLimit);

  for i = 1, pageCount do
    pages[i] = {
      lower = minimum,
      upper = maximum,
    };

    minimum = maximum + 1;
    maximum = (((maximum + viewLimit) < totalItems) and (maximum + viewLimit))
      or totalItems;
  end

  for _, bounds in ipairs(pages) do
    if ((selected >= bounds.lower) and (selected <= bounds.upper)) then
      return bounds.lower, bounds.upper;
    end
  end
end

return {
  getPageBounds = getPageBounds,
};