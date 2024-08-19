if (_G["Rooms"]) then
    return _G["Rooms"]
end
-- Rooms: Un array de rooms [Room], que contienen áreas [Area] y estas hijos [any].  
-- Contiene hijos a través de las áreas de sus rooms.
-- Sólo se actualizan y dibujan todas sus rooms si se encuentran marcadas como current.
local Rooms = Object:extend()

local Timer = require("_LIBS_.chrono.Timer")
local Console = require("objects.rooms.Console")
--local Stage = require("objects.rooms.Stage")
local CodeScreen = require("objects.rooms.CodeScreen")
local CodeNoScreen = require("objects.rooms.CodeNoScreen")
--local HelpScreen = require("objects.rooms.HelpScreen")
--local ReadmeScreen = require("objects.rooms.ReadmeScreen")
local TextsScreen = require("objects.rooms.TextsScreen")
local SplashScreen = require("objects.rooms.SplashScreen")

local utils = require("tools.utils")

function Rooms:new(opts)
    self._rooms = {}
    self.current_room = nil
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.score = 0
    --self.shift = nil
    self.innerTimer = false
    self.timer = opts.timer
    if (not self.timer) then
        self.timer = Timer()
        self.innerTimer = true
    end
end
-- añade una room al array de rooms
function Rooms:add(room)
    for i, r in ipairs(self._rooms) do
        --room:destroy()
        --room.current = false
        --self._rooms[i].current = false
        r.current = false
    end
    self._rooms = {}
    table.insert(self._rooms, room)
    room.current = true
    room.index = #self._rooms
    self.current_room = room
end
-- elimina la referencia a la room hija en el array de rooms
function Rooms:remove(index)
    table.remove(self._rooms, index)
end
-- limpia (vacía) el array de todas las rooms
function Rooms:clear()
    --table.clear(self._rooms)
    --self._rooms = {}
end

function Rooms:toConsoleRoom(_camera, ...)
    --print("toConsoleRoom")
    --[[local cr = self.current_room
    self.timer:after(0.2, function()
        if (cr and cr.destroy) then
            cr:destroy()
            --self:remove(cr.index)
        end
        collectgarbage()
    end, "hey_" .. (cr.index + 1))]]
    --[[if (cr and cr.destroy) then cr:destroy() end
    collectgarbage()]]

    print(".. to Console ..")
    --local current_room = self.current_room
    --self._rooms = {}
    self:add(Console(_camera or camera, ...)) -- opts))
    --print("toConsoleRoom()", current_room, current_room.ship)
    --if(current_room)then
        --current_room:destroy()
        --if(current_room.ship)then current_room.ship:kill() end
    --end
    collectgarbage()
end
function Rooms:toNewRoom(type, camera, ...)
    --print("toNewRoom")
    if(not self.timer)then return false end
    --[[local cr = self.current_room
    self.timer:after(0.2, function()
        if (cr and cr.destroy) then
            cr:destroy()
            --self:remove(cr.index)
        end
        collectgarbage()
    end, "hey_" .. (cr.index + 1))]]
    --[[if (cr and cr.destroy) then cr:destroy() end
    collectgarbage()]]

    --[[local opts = ...
        opts.imgFondoPath = cr.imgFondoPath
        print("'Level1': new Room 'Stage'", opts.imgFondoPath)]]
    --self._rooms = {}
    local extra = {}
    local CLS = utils.tableRandom({ SplashScreen }) --TextsScreen --Stage
    --[[if (type == "Stage") then
        CLS = Console
    else]]if ((type == "CodeScreen") or (type == "CodeNoScreen")) then
        CLS = Console
    elseif (type == "HelpScreen") then
        CLS = Console
    elseif (type == "ReadmeScreen") then
        CLS = Console
    elseif (type == "SplashScreen") then
        CLS = Console
    --elseif (type == "Console:Splash") then
    --    CLS = SplashScreen
    elseif (type == "Console:Code") then
        CLS = CodeScreen
    elseif (type == "Console:CodeNo") then
        CLS = CodeNoScreen
    elseif (type == "Console:Help") then
        --CLS = HelpScreen
        CLS = TextsScreen
        extra = { title = "HELP", textType = "HELP", language = "EN", logo = 'assets/logo_micro.png' }
    elseif (type == "Console:Readme") then
        --CLS = ReadmeScreen
        CLS = TextsScreen
        extra = {textType = "README", language = "EN"}
    --[[elseif (type == "Console:Room" or type == "Console:Start") then
        --CLS = utils.tableRandom({ Stage, Level1 })
        CLS = Stage]]
    end
    local c = CLS(camera, utils.tableMerge(..., extra))
    print(".. " .. c.type .. " ..")
    --self.current_room:destroy()
    --self._rooms = {}
    self:add(c)     -- opts))
    collectgarbage()
end

function Rooms:destroy()
    if (self.innerTimer and self.timer) then
        if self.timer.destroy then self.timer:destroy() end
    end
    self.timer = nil
    for i = #self._rooms, 1, -1 do
        local rs = self._rooms[i]
        if(rs)then rs:destroy() end
        table.remove(self._rooms, i)
    end
    self._rooms = nil
    self.current_room = nil
    -- remate, anula TODO
    for k, _ in pairs(self) do self[k] = nil end
end

--------------
-- actualiza todas sus rooms (y sus áreas) sólo si son 'current'
function Rooms:update(dt)
    --for i, room in ipairs(self._rooms) do
    for i = #self._rooms, 1, -1 do
        local room = self._rooms[i]
        room:update(dt)
        if room.dead then
        -- intenta cambiar de room (siguiente o anterior)
            if(self.current_room == room)then
                self.current_room = self:nextRoom()
                if (not self.current_room) then
                    self.current_room = self:prevRoom()
                end
            end
            table.remove(self._rooms, i)
        end
    end
    if(self.timer and self.innerTimer)then
        self.timer:update(dt)
    end
    --[[for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)
        if game_object.dead then table.remove(self.game_objects, i) end
    end]]
end
-- dibuja todas sus rooms (y sus áreas) sólo si son 'current'
function Rooms:draw()
    for _, room in ipairs(self._rooms) do
        room:draw()
    end
end

function Rooms:textinput(t)
    --print('Rooms.lua', t)
    --[[for _, room in ipairs(self._rooms) do
        if (room.textinput) then room:textinput(t) end
    end]]
    if (self.current_room and self.current_room.textinput) then self.current_room:textinput(t) end
end

return Rooms