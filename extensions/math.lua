function math:atan2(y, x)
  local angle
  if x > 0 then
    angle = math.atan(y/x)
  elseif y >= 0 and x < 0 then
    angle = math.atan(y/x) + math.pi
  elseif y < 0 and x < 0 then
    angle = math.atan(y/x) - math.pi
  elseif y > 0 and x == 0 then
    angle = math.pi / 2
  elseif y < 0 and x == 0 then
    angle = -math.pi / 2
  else
    -- x == 0 and y == 0
    -- Not defined, you can return whatever you want.
    -- It's best to return an error or something that indicates that the input is invalid.
    angle = nil
  end
  return angle
end
