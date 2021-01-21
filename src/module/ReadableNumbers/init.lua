-- @Author: VerdommeMan, see https://github.com/VerdommeMan/convert-to-human-readable-numbers for more information 
-- @Version: 1.0.2

local Formatter = {}
Formatter.default = {precision = 3, removeTrailingZeros = true, delimiter = " ",  scale = "SI", unit = ""}
Formatter.scales = {
    SI = {"K", "M", "G", "T", "P", "E", "Z", "Y", [0] = "", [-1] = "m", [-2] = "μ", [-3] = "n", [-4] = "p", [-5] = "f", [-6] = "a", [-7] = "z", [-8] = "y"},
    shortScale = {"thousand", "million", "billion", "trillion", "quadrillion", "quintillion", "sextillion", "septillion", [0] = "", [-1] = "thousandth", [-2] = "millionth", [-3] = "billionth", [-4] = "trillionth", [-5] = "quadrillionth", [-6] = "quintillionth", [-7] = "sextillionth", [-8] = "septillionth"},
    longScale = {"thousand", "million", "milliard", "billion", "billiard", "trillion", "trilliard", "quadrillion", [0] = "", [-1] = "thousandth", [-2] = "millionth", [-3] = "milliardth", [-4] = "billionth", [-5] = "billiardth", [-6] = "trillionth", [-7] = "trilliardth", [-8] = "quadrillionth"}
}

local instance = {}
instance.__index = Formatter
local mt = {__index = instance}

local function isNaN(arg)
    return arg ~= arg
end

local function isInf(arg)
   return arg == -math.huge or arg == math.huge
end

-- these are modified to allow string-number coersion
local function isNumber(arg)
    return tonumber(arg)
end

local function isInt(arg)
    return tonumber(arg) and tonumber(arg) == math.floor(arg)
end

local function isString(arg)
    return type(arg) == "string" or type(arg) == "number"
end

local function isStrings(...)
    for _, str in ipairs({...}) do
        if not isString(str) then
            return false
        end
    end
    return true
end

local function formatExceptions(number)
    if isInf(number) then
        return "∞"
    elseif isNaN(number) then
        return "NaN"
    else
        return string.format("%g", number)
    end
end

local function format(number, precision, removeTrailingZeros, delimiter, scale, unit) -- no type checking and defaulting
    assert(isNumber(number), "Wrong argument given for number, expected number but instead received " .. typeof(number))

    local index = math.floor(math.log(math.abs(number), 1000))
    local prefix = Formatter.scales[scale][index] 
    local formattedNumber 

    if prefix then
        formattedNumber = string.format("%".. (removeTrailingZeros and "#" or "") .. "." .. precision .. "f",  number / 10 ^ (index * 3))
        if removeTrailingZeros then
            formattedNumber = string.gsub(formattedNumber, "%.?0*$", "")
        end
    else -- defaults to standard behaviour, incase when number is bigger or smaller than 1e-+24 or is zero
        prefix = ""
        formattedNumber = formatExceptions(number)
    end

    return formattedNumber .. delimiter .. prefix .. unit
end

function instance:format(...)
    local args = {...}
    local n = select("#", ...)
    local returns = table.create(n)
    
    for i = 1, n do
        returns[i] = format(args[i], self.precision, self.removeTrailingZeros, self.delimiter, self.scale, self.unit)
    end

    return unpack(returns)
end

function Formatter.new(precision, removeTrailingZeros, delimiter, scale, unit)
    -- set defaults
    precision = precision or Formatter.default.precision
    removeTrailingZeros = removeTrailingZeros == nil and Formatter.default.removeTrailingZeros or removeTrailingZeros
    delimiter = delimiter or Formatter.default.delimiter
    scale = scale or Formatter.default.scale
    unit = unit or Formatter.default.unit
    -- type checking
    assert(isInt(precision), "Wrong argument given for precision, expected integer but received " .. typeof(precision))
    assert(Formatter.scales[scale], "wrong argument given for scale, expected a string (SI, shortScale, longScale or a custom scale)!")
    assert(isStrings(delimiter, unit), "Wrong argument give for scale/unit, expected string but received " .. typeof(delimiter) .. " and " .. typeof(unit))

    return setmetatable({
        precision = precision,
        removeTrailingZeros = removeTrailingZeros,
        delimiter = delimiter,
        scale = scale,
        unit = unit
    }, mt)
end

function Formatter.format(number, ...)
    return Formatter.new(...):format(number)
end

return Formatter