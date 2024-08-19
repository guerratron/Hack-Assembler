if (_G["HReg"]) then
    return _G["HReg"]
end

--[[
 Registro de bits tipo "Hack".
 Creado en principio para utilizarse conjúntamente con "HParser.lua", aunque finalmente se desechó;  
 
 Puede utilizarse independientemente.
]]
HReg = Object:extend()

local utils = require "tools.utils"

function _getBits(bitsTxt)
    local bits = {}
    --for str in string.gmatch(bitsTxt, "(.+)") do
    for str in utils.gsplit(bitsTxt, "") do
        table.insert(bits, tonumber(str))
    end
    return bits
end

function HReg:new(bitsTxt, opts)
    self.type = "HReg"
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.opts = opts
    self.font = opts.font or love.graphics.getFont()
    self.bitsTxt = bitsTxt
    self.bits = _getBits(bitsTxt) or {}
    --print(bitsTxt .. ", " .. #self.bits .. " : \n " .. utils.dump(self.bits))
    self.color = self.color or default_color
    self.originalColor = self.color
    self.active = false
    self.resalt = false
end

function HReg:destroy()
    --if self.room and self.room.input then self.room.input:unbind("left_click2") end
    --self.input:unbindAll()
    --Line.super.destroy(self)
    self.bits, self.opts  = nil, nil
end

function HReg:update(dt)

end

local function _txt(txt, _x, _y, font)
    love.graphics.print(txt,
        _x, _y,
        0, 1, 1,
        math.floor(font:getWidth(txt) / 2),
        math.floor(font:getHeight() / 2)
    )
end

function HReg:draw()
    local r, g, b = unpack(self.color)
    if self.active then
        if self.resalt then
            love.graphics.setColor(r + 0.2, g + 0.2, b + 0.2, 1)
        else
            love.graphics.setColor(r, g, b, 1)
        end
    else
        love.graphics.setColor(r, g, b, 0.3)
    end
    love.graphics.setColor(r, g, b, 0.8)
    love.graphics.line(self.x, self.y, self.x + 90, self.y)
    for index, value in ipairs(self.bits) do
        --local txt = love.graphics.newText(self.font, value .. "")
        --love.graphics.draw(txt, 50, 50)
        _txt(value .. "", self.x + index * 7, self.y + 5, self.font)
    end
    love.graphics.line(self.x, self.y + 10, self.x + 90, self.y + 10)
    love.graphics.setColor(r, g, b, 1)
end

return HReg
