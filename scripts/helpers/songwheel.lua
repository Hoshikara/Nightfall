local getPosition = function(index)
  local column = math.floor((index - 1) / 3) % 3;
  local row = math.floor((index - 1) % 3);
  
  return column, row;
end

return { getPosition = getPosition };