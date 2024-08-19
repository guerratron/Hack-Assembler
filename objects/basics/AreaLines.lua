if (_G["AreaLines"]) then
    return _G["AreaLines"]
end

local Area = require "objects.basics.Area"

local AreaLines = Area:extend()

--local HParser = require "objects.api.HParser"
local utils = require "tools.utils"

function AreaLines:new(room, current, opts)
    self.type = "AreaLines"
    self.lines = {}
    self.visualLines = {}
    opts = opts or {}
    --Console.super.new(self, _camera, pars)--Stage.super.new(self, true, pars)
    AreaLines.super.new(self, room, current, opts) -- current, opts
    --if opts then for k, v in pairs(opts) do self[k] = v end end
    self.name = opts.name or self.type
    self.title = opts.title or self.name or ("Text-Area " .. self.id)
    self.x, self.y = opts.x, opts.y
    self.overX, self.overY = 0, 0 -- se utiliza al pasar el mouse sobre este Nodo
    self.w, self.h = opts.w, opts.h
    self.room = room
    --self.w = opts.w or self.r
    --self.h = opts.h or self.w
    self.font = opts.font or fonts.m5x7_16
    --self.w, self.h = math.floor(self.font:getWidth(self.key .. '')), self.font:getHeight()
    self.color = self.color or default_color
    self.originalColor = self.color
    self.clicked = false -- clickado
    self.hot = false     -- indica si el ratón se encuentra en los límites del botón
    self.inner = false   -- indica si se entra o sale de los límites del ratón (está relacionada con "hot")
    -- arrastrar la cámara
    self.camera = opts.camera
    --self.input = opts.input or self.room.input
    self.input = input
    input:bind('mouse1', 'left_click2')

    self.numlines = opts.numlines or false
    self.text = opts.text or ""
    if(type(opts.zeroIndex) == "boolean")then
        self.zeroIndex = opts.zeroIndex
    else
        self.zeroIndex = true
    end
    --print(self.text, opts.text)
    
    self.paddX, self.paddY = opts.paddX or 5, opts.paddY or 5
    self.indexMin = 0
    self.indexMax = self.h / 12 --#self.lines

    self:toLines(self.text)
end

function AreaLines:toLines(txtLines)
    self.text = txtLines
    self.lines = utils.gsplitTable(txtLines, "\n")
    self.visualLines = {}
    --local hp = HParser(self.text)
    --self.lines = hp.linesIn
    --print(utils.dump(hp))
    --if true then return end
    -- las mismas líneas limitadas a un máximo de caracteres
    local wWidth = self.font:getWidth("w") -- ancho base para la limitación de líneas
    --for value in self.lines do
    for index, value in pairs(self.lines) do
        local v1 = value
        --print("--" .. index .. "--" .. value .. "--")
        local len = string.len(value)
        local n = self.w - len * wWidth
        if (n < 0) then
            n = len + (n / wWidth) -- en realidad es una resta
            v1 = string.sub(value, 1, n) .. ".."
        end
        table.insert(self.visualLines, v1)
    end
    --print("INI:", table.concat(self.visualLines, "\n"), ":END")
    return self.lines
end

-- Comprueba y retorna si las coordenadas pasadas se corresponden con las de este nodo, 
-- también retorna estas coordenadas traducidas a la cámara.  
-- Tiene en cuenta la escala de la cámara.  
-- Las coordenadas se esperan con respecto a la cámara, por ejemplo a través de:
--[[
    ```lua
    local mx, my =utils.getMouseXY(self.camera)
    mx, my = -mx, -my -- hay que invertirlas
    local over = self:isOver(mx, my)
    self.hot = over[1]
    if(self.hot)then
        self.overX = over[2].x
        self.overY = over[2].y
    end
    ```
]]
function AreaLines:isOver(x, y)
    local result = false
    --if(AreaLines.super.isOver)then result = AreaLines.super.isOver(self, x, y) end
    if(result and result[1])then return result end

    local subX, subY = x, y
    local xLU, yLU = camera:toCameraCoords(self.x, self.y)
    xLU, yLU = xLU - gw / 2, yLU - gh / 2
    local xRD, yRD = camera:toCameraCoords(self.x + self.w, self.y + self.h)
    xRD, yRD = xRD - gw / 2, yRD - gh / 2
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

function AreaLines:destroy()
    if self.room and self.input then self.input:unbind("left_click2") end
    if (AreaLines.super.destroy) then AreaLines.super.destroy(self) end
    --self.input:unbindAll()
    --AreaLines.super.destroy(self)
    self.lines = nil
    self.visualLines = nil
    self.font = nil
    self.room = nil
end

function AreaLines:update(dt)
    if not self.room or not self.input or not self.visible then return end
    --if (AreaLines.super.update) then AreaLines.super.update(self, dt) end
    --mx, my = mx / sx, my / sy
    local mx, my =utils.getMouseXY(self.camera)
    mx, my = -mx, -my

    local over = self:isOver(mx, my)
    self.hot = over[1]
    if(self.hot)then
        -- retiene las coordenadas
        self.overX = over[2].x
        self.overY = over[2].y
        if (not self.inner) then
            Sounds.play("action5")
        end
        self.inner = true
        -- clickado
        --[[if not self.ach and self.input:down("left_click2") then
        end]]
    else
        if (self.inner) then
            Sounds.play("plop")
            self.inner = false
        end
    end
end

function AreaLines:drawLines()
    local posY, posX = 0, 0
    --local numlinesFont = love.graphics.newFont(14)
    for index, txt in ipairs(self.visualLines) do
        if(self.zeroIndex)then index = index - 1 end
        if ((index >= self.indexMin) and (index <= self.indexMax)) then
            if (self.numlines) then
                posX = 15
                --love.graphics.setFont(numlinesFont)
                love.graphics.setColor(0.9, 0.9, 0.9, 0.9)
                love.graphics.print(index .. '', self.x + self.paddX, self.y + posY + self.paddY)
            end
            --love.graphics.setFont(self.font)
            love.graphics.setColor(self.color)
            love.graphics.print(txt .. '', self.x + posX + self.paddX, self.y + posY + self.paddY)
            posY = posY + 10
        end
    end
end

function AreaLines:draw()
    if not self.room or not self.input then return end
    local result = true
    if (AreaLines.super.draw) then result = AreaLines.super.draw(self) end
    if(not result)then return false; end

    local r, g, b = unpack(self.color)
    love.graphics.setFont(self.font)
    -- BACKGROUND
    local r2, g2, b2 = unpack(self.background_color or background_color)
    love.graphics.setColor({r2, g2, b2, 0.6})
    --love.graphics.setColor(0.5, 0.5, 0.5, 0.6)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    --[[love.graphics.polygon("fill",
        self.x - self.r, self.y - self.r,
        self.x + self.r, self.y - self.r,
        self.x, self.y + self.r
    )]]
    --love.graphics.setColor(self.color)
    -- FRONT
    love.graphics.setColor(r, g, b, 0.9)
    self:drawLines()
    --love.graphics.print(self.name .. '', self.x, self.y)
    --love.graphics.print(self.key .. '', self.x, self.y, 0, 1, 1, self.w / 2, self.h / 2)
    love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
    --[[love.graphics.polygon("line",
        self.x - self.r, self.y - self.r,
        self.x + self.r, self.y - self.r,
        self.x, self.y + self.r
    )]]
    love.graphics.setColor(r, g, b, 1)


    -- Stats rectangle
    if self.hot then
        -- Draw text description
        love.graphics.setColor(default_color)
        --love.graphics.rectangle('line', self.overX + 2, self.overY + 2, rectW - 4, rectH - 4)
        --love.graphics.print(self.key, math.floor(self.overX + 8),
        --        math.floor(self.overY + self.font:getHeight() / 2 + self.font:getHeight()))
        if(self.title)then
            love.graphics.print(self.title, math.floor(self.overX + 8), math.floor(self.overY + self.font:getHeight() * 1.5))
        end
        --love.graphics.setColor(hp_color)
        self.color = hp_color
    else
        self.color = self.originalColor-- ammo_color
    end
    return true
end

-- Events
function AreaLines:textinput(t)
    if(not self.visible)then return false; end
    --print('main.lua', t)
    if(self.hot)then
        if (t == "up") then
            self.indexMin = self.indexMin - 1
            if self.indexMin < 0 then
                self.indexMin = 0
            else
                self.indexMax = self.indexMax - 1
            end
        elseif (t == "down") then
            self.indexMax = self.indexMax + 1
            if self.indexMax > #self.lines then
                self.indexMax = #self.lines
            else
                self.indexMin = self.indexMin + 1
            end
        end
    end
end

return AreaLines