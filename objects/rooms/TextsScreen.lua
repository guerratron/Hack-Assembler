if (_G["TextsScreen"]) then
    return _G["TextsScreen"]
end

local Room = require "objects.rooms.Room"

local TextsScreen = Room:extend()

local Input = require("_LIBS_.boipushy.Input")
local Timer        = require("_LIBS_.chrono.Timer")
local Texts        = require "tools.texts"
local utils       = require "tools.utils"



-- retorna una tabla con la cantidad de líneas en "txts"
local function _countLines(txts)
    local count = {titles = 0, lines = 0, total = 0}
    for _, txt in ipairs(txts) do
        count.titles = count.titles + 1
        for _, line in ipairs(txt.lines) do
            count.lines = count.lines + 1
        end
    end
    count.total = count.titles + count.lines
    return count
end

function TextsScreen:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index = 1,
        _id = utils.UUID(),
        _type = "TextsScreen",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        --input = Input()
    }
    TextsScreen.super.new(self, true, pars)

    self._type = "TextsScreen"
    self.type = "TextsScreen"
    self.font = fonts.m5x7_16
    self.fontTitle = love.graphics.newFont(16)
    self.fontLines = love.graphics.newFont(12)
    self.input = self.input or opts.input or Input()
    self.textType = opts.textType or "README"
    self.language = opts.language or "ES"
    self.title = opts.title or self.textType
    self.logo = love.graphics.newImage(opts.logo or 'assets/logo_micro.png')
    print(self.textType, self.language, opts.logo)

    -- arrastrar la cámara
    self.input:bind('mouse1', 'left_click')
    self.camera:setBounds(-gw / 2, -gh / 2, gw / 2, gh / 2)
    self.lastX, self.lastY = 0, 0
    self.relX, self.relY = 0, 0
    self.min_cam_x, self.min_cam_y = -gw / 2, -gh / 2
    self.max_cam_x, self.max_cam_y = gw / 2, gh / 2
    -- cámara zoom
    self.incr = 0.2
    self.input:bind('+', 'zoom_in')
    self.input:bind('-', 'zoom_out')

    -- temporizadores para el desplazamiento automático del texto
    --self.complete_the_readme = false
    self.handler1 = nil
    self.txts = (Texts[self.textType])[self.language]
    self.max_slideY = _countLines(self.txts).total * self.font:getHeight() + 175
    self.timer:after(12, function()
        --[[self.handler1 = self.timer:every(2, function()
            self.relY = self.camera.y + self.font:getHeight() / self.camera.scale
            print(self.relY, self.max_slideY)
            if(self.relY > self.max_slideY)then
                self.timer:cancel(self.handler1)
                self.complete_the_readme = true
                --self:finish()
                return
            end
            self.timer:tween(0.2, self.camera, { y = self.relY }, 'in-out-cubic', 'auto-move')
        end)]]
        if(self.dead)then return end
        self.handler1 = self.timer:tween(100, self.camera, { y = self.max_slideY }, 'linear', 'auto-move')
    end)
end

function TextsScreen:destroy()
    if (self.handler1) then self.timer:cancel(self.handler1) end
    if (self.camera) then
        --self.camera.detach()
        self.camera = nil
    end
    if(self.main_canvas)then
        love.graphics.setCanvas() -- por si acaso, regresa al canvas principal
        self.main_canvas = nil
    end
    if (self.font) then
        self.font = nil
    end
    TextsScreen.super.destroy(self)
end

function TextsScreen:update(dt)
    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    --NO SE ACTUALIZA LA ROOM PADRE PORQUE NO TIENE ÁREAS QUE ACTUALIZAR
    -- Arrastrar la cámara
    if self.input:pressed('left_click') then
        self.lastX, self.lastY = utils.getMouseXY(self.camera)
    end
    if self.input:released('left_click') then
        --[[local condX1 = self.camera.x > self.min_cam_x
        local condX2 = self.camera.x < self.max_cam_x
        local condY1 = self.camera.y > self.min_cam_y
        local condY2 = self.camera.y < self.max_cam_y
        if(condX1 and condX2 and condY1 and condY2)then]]
        local lim = false
        if (self.camera.x < self.min_cam_x) then
            self.camera.x = self.min_cam_x; lim = true
        end
        if (self.camera.y < self.min_cam_y) then
            self.camera.y = self.min_cam_y; lim = true
        end
        if (self.camera.x > self.max_cam_x) then
            self.camera.x = self.max_cam_x; lim = true
        end
        if (self.camera.y > self.max_cam_y) then
            self.camera.y = self.max_cam_y; lim = true
        end
        if (not lim) then
            local lX, lY = self.lastX, self.lastY --self.camera.x, self.camera.y
            self.lastX, self.lastY = utils.getMouseXY(self.camera)
            self.relX = self.camera.x + (self.lastX - lX) / self.camera.scale
            self.relY = self.camera.y + (self.lastY - lY) / self.camera.scale
            --print(lX, lY, self.lastX, self.lastY)
            --self.camera:move((self.lastX - lX) / self.camera.scale, (self.lastY - lY) / self.camera.scale)
            self.timer:tween(0.2, self.camera,
                {
                    x = self.relX,
                    y = self.relY
                },
                'in-out-cubic', 'move'
            )
        end
    end
    -- zoom de la cámara
    if self.input:pressed('zoom_in') then
        self.timer:tween(0.2, self.camera, { scale = self.camera.scale + self.incr }, 'in-out-cubic', 'zoom')
    end
    if self.input:pressed('zoom_out') then
        self.timer:tween(0.2, self.camera, { scale = self.camera.scale - self.incr }, 'in-out-cubic', 'zoom')
    end

    -- CRONÓMETRO MORTAL
    if(self.max_time)then
        if (self.max_time) then
            self.total_time = self.total_time + dt
        end
        if (self.total_time > self.max_time) then
            --self.timer:after(1.5, function()
                --"IntroScreen [1] Complete"
                --if (not achievements["IntroScreen [4] Complete"]) then
                --    if (not self.rooms) then return false end
                --    self.rooms:toNewRoom("Splash:Intro", self.camera, { rooms = self.rooms, timer = self.timer })
                --else
                    self:finish()
                --end
            --end)
            self.total_time = 0
            return false
        end
    end

    return true
end

-- dibuja el título de la pantalla
function TextsScreen:drawTitle(txt, x, y)
    -- FONDO
    love.graphics.setColor({0.2, 0.2, 0.2, 0.7})
    love.graphics.rectangle("fill",x - 75, y - self.font:getHeight(), 150, self.font:getHeight() * 2)
    local font = love.graphics.newFont(24) --self.font
    love.graphics.setFont(font)
    love.graphics.setColor(title_color)
    txt = txt or self.type
    -- TITLE
    local w, h = font:getWidth(txt), font:getHeight()
    love.graphics.print(txt, x, y, 0, 1, 1, math.floor(w / 2), math.floor(h / 2))
end

function TextsScreen:drawLogo(x, y)
    love.graphics.draw(self.logo, x, y, 0)--, sx/16, sy/16)
end

function TextsScreen:drawTxts()
    local x, y = 10, 10
    local w, h = 50, self.font:getHeight()
    local sepH, sepV = 1, 1
    --print(self.type, "Achievements->dump(achievements)")
    --print(utils.dump(achievements))
    for _, txt in ipairs(self.txts) do
        w = math.floor(self.font:getWidth(txt.title)) * 2
        y = y + h + sepV
        love.graphics.setColor(hp_color)
        love.graphics.setFont(self.fontTitle)
        love.graphics.print(txt.title, x, y, 0, 1, 1)
        y = y + h*2 + sepV
        for _, line in ipairs(txt.lines) do
            w = math.floor(self.font:getWidth(line)) * 2
            love.graphics.setColor(default_color)
            love.graphics.setFont(self.fontLines)
            love.graphics.print(line, x, y, 0, 1, 1)
            y = y + h + sepV
            --local w, h = font:getWidth(txt), font:getHeight()
            --love.graphics.print(txt, x, y, 0, 1, 1, math.floor(w / 2), math.floor(h / 2))
        end
    end
    --[[if (self.complete_the_readme) then
        love.graphics.setColor(hp_color)
        love.graphics.setFont(self.fontTitle)
        love.graphics.print("README END", gw/2, self.max_slideY + 100, 0, 1, 1)
    end]]
end

function TextsScreen:draw()
    if (not self.camera) then return false end
    --NO SE DIBUJA LA ROOM PADRE PORQUE NO TIENE ÁREAS QUE ACTUALIZAR
    -- inner-canvas
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        self.camera:attach(0, 0, gw, gh)
            self:drawTxts()
        self.camera:detach()
        love.graphics.setFont(self.font)
        self:drawLogo(gw * 0.85, 0)
        self:drawTitle(self.title .. " - HackAssembler v1.0", gw/2, 10)
    love.graphics.setCanvas()

    -- outer-canvas
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
    return true
end

function TextsScreen:textinput(t)
    -- SALTAR LA SPLASH
    if (t == "f5" or t == "return" or t == "escape" or t == "scape" or t == "space" or t == " ") then
        self:finish()
        self:destroy()
    elseif(t == "down")then
        self.relY = self.camera.y + self.font:getHeight() / self.camera.scale
        --print(lX, lY, self.lastX, self.lastY)
        --self.camera:move((self.lastX - lX) / self.camera.scale, (self.lastY - lY) / self.camera.scale)
        self.timer:tween(0.2, self.camera, { y = self.relY }, 'in-out-cubic', 'move')
    elseif (t == "up") then
        self.relY = self.camera.y - self.font:getHeight() / self.camera.scale
        --print(lX, lY, self.lastX, self.lastY)
        --self.camera:move((self.lastX - lX) / self.camera.scale, (self.lastY - lY) / self.camera.scale)
        self.timer:tween(0.2, self.camera, { y = self.relY }, 'in-out-cubic', 'move')
    end
end

return TextsScreen