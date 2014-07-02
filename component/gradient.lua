-- Vyzor, UI Manager for Mudlet
-- Copyright (c) 2012 Erik Pettis
-- Licensed under the MIT license:
--    http://www.opensource.org/licenses/MIT

local Base = require("vyzor.base")
local GradientMode = require("vyzor.enum.gradient_mode")

--[[
    Class: Gradient
        Defines a Gradient Component.
]]
local Gradient = Base("Component", "Gradient")

--[[
    Constructor: new
        Expected arguments differ depending on mode.

        Linear mode expects a comma-separated list of
        numbers (x1, y1, x2, y2) followed by any number of
        stop, color (number, Color Component) pairs.

        Radial mode expects a comma-separated list of
        numbers (cx, cy, radius, fx, fy) following by any number of
        stop, color (number, Color Component) pairs.

        Conical mode expects a comma-separated list of
        numbers (cx, cy, radius, angle) following by any number of
        stop, color (number, Color Component) pairs.

        All numeric values are expected to between 0.0 and 1.0,
        to be understood as percentage of Frame size.

        I wish Gradients were easier, but there it is. =p

    Parameters:
        _mode - The Gradient's mode. Must be a valid <GradientMode> Enum.
        ... - Gradient data. See description.

    Returns:
        A new Gradient Component.
]]
local function new (_, _mode, ...)
    local arg = { ... }
    assert(GradientMode:IsValid(_mode), "Vyzor: Invalid mode passed to Gradient.")

    --[[
        Structure: New Gradient
            A Component that defines gradient data. Used
            primarily in a <Brush> Component.
    ]]
    local self = {}

    -- Array: gradient_data
    -- Contains the Gradient's data.
    local _gradientData
    do
        local index
        if _mode:match(GradientMode.Linear) then
            _gradientData = {
                x1 = arg[1],
                y1 = arg[2],
                x2 = arg[3],
                y2 = arg[4],
                stops = {},
            }
            index = 5
        elseif _mode:match(GradientMode.Radial) then
            _gradientData = {
                cx = arg[1],
                cy = arg[2],
                radius = arg[3],
                fx = arg[4],
                fy = arg[5],
                stops = {},
            }
            index = 6
        elseif _mode:match(GradientMode.Conical) then
            _gradientData = {
                cx = arg[1],
                cy = arg[2],
                angle = arg[3],
                stops = {},
            }
            index = 4
        end

        local stopIndex = 1
        for i = index, #arg do
            _gradientData.stops[stopIndex] = arg[i]
            stopIndex = stopIndex + 1
        end
    end

    -- String: stylesheet
    -- The Gradient Component's stylesheet. Generated via <updateStylesheet>.
    local _stylesheet

    --[[
        Function: updateStylesheet
            Updates the Gradient's <stylesheet>.
            Output is based on <GradientMode>.
    ]]
    local function updateStylesheet ()
        local styleStops = {}

        for _, stop in ipairs(_gradientData.stops) do
            styleStops[#styleStops +1] = string.format("stop:%s %s",
                stop[1],
                stop[2].Stylesheet:sub(8) or stop.color)
        end

        if _mode:match(GradientMode.Linear) then
            _stylesheet = string.format("qlineargradient(x1:%s, y1:%s, x2:%s, y2:%s, %s)",
                _gradientData.x1,
                _gradientData.y1,
                _gradientData.x2,
                _gradientData.y2,
                table.concat(styleStops, ", "))
        elseif _mode:match(GradientMode.Radial) then
            _stylesheet = string.format("qradialgradient(cx:%s, cy:%s, radius: %s, fx:%s, fy:%s, %s)",
                _gradientData.cx,
                _gradientData.cy,
                _gradientData.radius,
                _gradientData.fx,
                _gradientData.fy,
                table.concat(styleStops, ", "))
        elseif _mode:match(GradientMode.Conical) then
            _stylesheet = string.format("qconicalgradient(cx:%s, cy:%s, angle:%s, %s)",
                _gradientData.cx,
                _gradientData.cy,
                _gradientData.angle,
                table.concat(styleStops, ", "))
        end
    end

    --[[
        Properties: Gradient Properties
            Mode - Returns the Gradient's <GradientMode> Enum.
            Data - Returns a copy of the Gradient's <gradient_data>.
            Stylesheet - Updates and returns the Gradient Component's <stylesheet>.
    ]]
    local properties = {
        Mode = {
            get = function ()
                return _mode
            end,
        },

        Data = {
            get = function ()
                local copy = {}

                for i in pairs(_gradientData) do
                    copy[i] = _gradientData[i]
                end

                return copy
            end
        },

        Stylesheet = {
            get = function ()
                if not _stylesheet then
                    updateStylesheet()
                end

                return _stylesheet
            end,
        },
    }

    setmetatable(self, {
        __index = function (_, key)
            return (properties[key] and properties[key].get()) or Gradient[key]
        end,
        __newindex = function (_, key, value)
            if properties[key] and properties[key].set then
                properties[key].set(value)
            end
        end
    })

    return self
end

setmetatable(Gradient, {
    __index = getmetatable(Gradient).__index,
    __call = new
})

return Gradient
