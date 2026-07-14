-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
--!strict

local Power = {}

-- Returns a value to the power of a degree. Yay, last comment.
function Power.Evaluate(value: number, degree: number): number
	-- Fast paths for linear, quadratic, cubic and quadric.
	if degree == 1 then
		return value
	elseif degree == 2 then
		return value * value
	elseif degree == 3 then
		return value * value * value
	elseif degree == 4 then
		return value * value * value * value
	end
	
	return value ^ degree
end

return Power
