---@class Grade
---@field grade string
---@field min number
---@field rate number
local grade = {};

---@type Grade[]
local Grades = {
  { min = 9900000, grade = 'S',    rate = 1.05 },
  { min = 9800000, grade = 'AAA+', rate = 1.02 },
  { min = 9700000, grade = 'AAA',  rate = 1.00 },
  { min = 9500000, grade = 'AA+',  rate = 0.97 },
  { min = 9300000, grade = 'AA',   rate = 0.94 },
  { min = 9000000, grade = 'A+',   rate = 0.91 },
  { min = 8700000, grade = 'A',    rate = 0.88 },
  { min = 7500000, grade = 'B',    rate = 0.85 },
  { min = 6500000, grade = 'C',    rate = 0.82 },
  { min = 0,       grade = 'D',    rate = 0.80 },
};

return Grades;