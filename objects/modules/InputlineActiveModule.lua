if (_G["InputlineActiveModule"]) then
    return _G["InputlineActiveModule"]
end

local InputlineModule = require "objects.modules.InputlineModule"

local utils = require "tools.utils"

--[[
InputlineActiveModule
====
Igual que "InputlineActiveModule" pero añadiendole la capacidad de interceptar clicks 
del ratón para poder reescribir el texto (necesita el objeto cámara)

EXAMPLE
=======
```lua
local InputlineActiveModule = require('InputlineActiveModule')
local m = nil
function love.load()
    {
        name = "il_1",
        cursor_delay = 0.3,
        width = 40,
        align = 'left', -- 'center'
        font = love.graphics.newFont(30),
        color = { 255, 127, 255 },
        cursor = true,
        camera = self.camera
    }
    m = InputlineActiveModule(nil, 20, 50, commondOpts)
end
function love.update(dt)
    if(m)then m:update(dt) end
end
function love.draw()
    if(m)then m:draw() end
end
function love.textinput(t)
    if(m and m.textinput)then m:textinput(t) end
end
```
]]
local InputlineActiveModule = InputlineModule:extend()

--local Input = require("_LIBS_.boipushy.Input")
--local utils = require "utils"

function InputlineActiveModule:new(text, x, y, opts)
    InputlineActiveModule.super.new(self, text, x, y, opts)
    self.type = "InputlineActiveModule"
    self.text = text or ''
    self.resalt = true
    self.camera = opts.camera
    self.font = opts.font or fonts.m5x7_16
    self.w, self.h = math.floor(self.font:getWidth(text)), self.font:getHeight()
    self.wMin = 5
    self.char_width = self.font:getWidth('w') * 0.65
    self.border = opts.border
    --print(self.w, self.h)
    self.color = self.color or default_color
    self.originalColor = self.color
    self.bgcolor = opts.bgcolor
    self.originalW = self.maxWidth
    self.originalY = self.y
    self.twoLines = self.font:getHeight()
    self.numLines = 1
    self.clicked = false -- clickado
    self.hot = false     -- indica si el ratón se encuentra en los límites del botón
    self.inner = false   -- indica si se entra o sale de los límites del ratón (está relacionada con "hot")
    self.handlerCopy = opts.action
    --[[]]
    input:bind('mouse1', function()
        local mx, my = utils.getMouseXY(self.camera)
        mx, my = -mx, -my
        local over = self:isOver(mx, my)
        self.hot = over[1]
        --local _x, _y = love.mouse.getPosition() -- get the position of the mouse
        --print(self.type, self.hot, x, over.x, y, over.y)
        self.finish = not self.hot
        --self.start = not self.start
        -- necesita volver a asignar el "action"
        if(not self.finish)then
            self.handler = self.handlerCopy
        end
    end)
end

function InputlineActiveModule:setText(txt)
    self.text = txt
    local width = math.floor(self.font:getWidth(self.text))
    self.w = width * 0.8
    local len = txt:len() * self.char_width
    if(len > self.originalW)then
        self.y = self.originalY - self.twoLines
        self.numLines = 2
    --print(len, self.w, self.originalW)
    else
        self.y = self.originalY
        self.numLines = 1
    end
    --[[]]
end

function InputlineActiveModule:isOver(x, y)
    local result, subX, subY = false, x, y
    local xLU, yLU = self.camera:toCameraCoords(self.x - self.w - self.wMin, self.y - self.h)
    xLU, yLU = xLU - gw / 2, yLU - gh / 2 + self.numLines * 5
    local xRD, yRD = self.camera:toCameraCoords(self.x + self.w + self.wMin, self.y + self.h)
    xRD, yRD = xRD - gw / 2, yRD - gh / 2 + self.numLines * 5
    if x >= xLU and x <= xRD and y >= yLU and y <= yRD then
        --print(self.hot, self.camera.scale)
        subX = x + self.camera.x * self.camera.scale
        subY = y + self.camera.y * self.camera.scale
        result = true
    end
    return {
        result,
        {
            x = subX,
            y = subY
        }
    }
end

--[[function InputlineActiveModule:destroy()
    InputlineActiveModule.super.destroy(self)
end
]]
function InputlineActiveModule:update(dt)
    local res = InputlineActiveModule.super.update(self, dt)
    if (not res) then return false end
    --[[local mx, my = utils.getMouseXY(self.camera)
    mx, my = -mx, -my
    local over = self:isOver(mx, my)
    self.hot = over[1] ]]
    return true
end

--[[
]]
function InputlineActiveModule:drawBorder()
    if (not self.border) then return false end
    love.graphics.setColor(self.bgcolor)
    --local char_width = self.font:getWidth('w') * 0.75
    local padding = 2
    local _x1, _x2 = self.x - self.wMin - padding, self.x + self.wMin + (self.w / self.numLines) + padding
    local _w = self.wMin * 2 + (self.w / self.numLines) + padding * 2
    local _y1, _y2 = self.y - padding, self.y + self.font:getHeight() * self.numLines + padding
    local _h = self.font:getHeight() * self.numLines + padding * 2
    --love.graphics.line(_x1, _y1, _x2, _y2)
    love.graphics.rectangle("fill", _x1, _y1, _w, _h, 0) --rx, ry, segments)
    return true
end
function InputlineActiveModule:drawCursor()
    if(not self.cursor_show)then return false end
    love.graphics.setColor(default_color)
    --local char_width = self.font:getWidth('w') * 0.75
    local _x = self.x + (self.char_width * self.text:len()/self.numLines)
    love.graphics.line(_x, self.y, _x, self.y + self.font:getHeight())
    return true
end
function InputlineActiveModule:draw()
    --local res = InputlineActiveModule.super.draw(self)
    --if (not res) then return false end

    if (self.start) then
        if (self.border) then self:drawBorder() end
        if (self.resalt and not self.finish) then
            --local char_width = self.font:getWidth('w') * 0.75
            local w = (self.char_width * self.text:len() / self.numLines)
            --local bk_color = { 0.05, 0.05, 0.05, 0.6 }
            love.graphics.setColor(self.bgcolor or { 0.05, 0.05, 0.05, 0.6 })
            --[[if(self.hot)then
                love.graphics.setColor({1, 0, 0, 1})
            else
                love.graphics.setColor({ 0, 1, 0, 1 })
            end]]
            love.graphics.rectangle("fill", self.x, self.y, w, self.font:getHeight() * self.numLines)
        end
        if (self.cursor and not self.finish) then self:drawCursor() end
        love.graphics.setColor(self.color)
        love.graphics.setFont(self.font)
        love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
        --print(self.type, self.x, self.y, self.width)
    end
    return true
end

function InputlineActiveModule:textinput(t)
    if (self.finish) then return false end
    -- plantilla de caracteres admitidos (no puede incluirse %)
    --[[local str = ' abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWYXZ0123456789.:,;/-_*()[]{}"\'$&=?¿!¡ºª€+<>%'
    local i, j = nil, nil
    if (t == "%") then
        i, j = 83, 83
    else
        i, j = utils.split(str, t) --str:find(t) --string.find(str, t) --str:find(t)
    end
    print(self.type, t, j, i)]]
    
    if (t == "escape") or (t == "scape") then
        -- LO IGNORA
    elseif (t == "enter") or (t == "intro") or (t == "return") then
        self.finish = true
        self.cursor = false
    elseif (t == "backspace") then
        if(self.text:len() > 0)then
            self.text = self.text:sub(1, self.text:len() - 1)
            self:setText(self.text)
        end
    --elseif ((i and j) and (i > 0) and (i == j)) then
    else
        --self.text = self.text .. t --tostring(t)
        self:setText(self.text .. t)
    --else
        --print("??", t)
    end
    return true
end

return InputlineActiveModule
