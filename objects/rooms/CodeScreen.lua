if (_G["CodeScreen"]) then
    return _G["CodeScreen"]
end

local Room = require "objects.rooms.Room"

local CodeScreen = Room:extend()

--local Timer = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
local Input = require("_LIBS_.boipushy.Input")
--local Camera = require("_LIBS_.hump.camera")
--local Camera = require("_LIBS_.camera.Camera") -- problemas con smooth
--local Camera = require("_LIBS_.camera.Camera") -- problemas con smooth
local HParser = require "objects.api.HParser"
local AreaLines = require "objects.basics.AreaLines"
local InputlineActiveModule = require "objects.modules.InputlineActiveModule"
local utils= require "tools.utils"

--local LinkerEdgge = require "tools.LinkerEdgge"

local dirSaved = "samples/"
local asmExt = "asm"
local asmFileName = "ej_2"
local hackExt = "hack"
local hackFileName = asmFileName
local hackCompareFileName = asmFileName .. "_compare"
local logExt = "log"
local logFileName = asmFileName
local csvExt = "csv"
local csvFileName = asmFileName .. "_tsymb"

function CodeScreen:new(_camera, opts)
    opts = opts or {zeroIndex = true}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "CodeScreen",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        input = opts.input or Input(),
        imgFondoPath = opts.imgFondoPath
    }
    CodeScreen.super.new(self, true, pars) -- current, opts
    self._type = "CodeScreen"
    self.type = "CodeScreen"
    self.input = self.input or opts.input or Input()
    self.camera = _camera
    self.camera.x = gw / 2
    self.camera.y = gh / 2
    self.imgFondoPath = opts.imgFondoPath -- aqui no se utiliza pero en otras rooms si
    --self.timer = opts.timer or Timer()
    --self.timer = opts.timer
    --self.current_room = nil
    -- se reutiliza pars para el siguiente elemento

    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.font = fonts.m5x7_16
    self.fontMsg = love.graphics.newFont(8)
    self.fondo_img_chances = utils.chanceList(
        { 'none', 2 },
        { 'assets/universe.png', 3 },
        { 'assets/matrix.png', 4 },
        { 'assets/matrix2.png', 5 }
    )
    local imgPath = self.fondo_img_chances:next()
    self.imgFondo = nil
    if(imgPath == "none")then
    else
        self.imgFondo = love.graphics.newImage(imgPath)
    end
    self.zoom = minZoom
    self.fondoZoom = 0     -- -1 = zoom-out, 0 = zoom-none, +1 = zoom-in
    self.paused = false
    self.visible = true
    self.varsVisible = true
    self.numlines = true
    if (type(opts.zeroIndex) == "boolean") then
        self.zeroIndex = opts.zeroIndex
    else
        self.zeroIndex = true
    end

    -- control a través de tiempo.
    -- Si se especifica "max_time" se pasa a limitar la partida a un máximo de tiempo
    self.max_time = nil --30

    self.msg = ""

    -- ADMITE COMENTARIOS MONOLÍNEA Y MULTILÍNEA: "//...", "/*...*/"
    --[[local text = [=[

//@A (A -> constant)
A=1
@300
(LOOP)
/*@B (B -> constant)*/
@unO
A=M /*@C (C -> constant)*/ + 1
@LOOP // OR 4
/*@D (D ->

@400
constant)*/
D;JLT
(END)

]=]

    self:makeAreas(text)]]

    -- Intenta cargar un posible archivo almacenado en opts.asmName
    -- Sinó muestra los Text-Areas vacíos.
    local asmTxt = ""
    self:toASMNames(opts.asmName)
    --if(asmFileName:len() > 0)then
        local asmLines = self:loadASM() -- después de esto "self.asmName" puede ser nulo (nil)
        asmTxt = table.concat(asmLines, "\n")
    --end
    self.inputTxt = nil
    --self:makeInput(asmTxt)
    self:makeInput(dirSaved .. asmFileName .. "." .. asmExt)


    self:makeButtons()

    --[[ f4 elimina area completa
    self.input:bind('f4', function()
        if(self.areas)then
            for i = #self.areas, 1, -1 do
                local ar = self.areas[i]
                ar:destroy()
                table.remove(self.areas, i)
            end
        end
        self.areas = nil
        self:finish()
    end)]]

end

function CodeScreen:makeInput(txt)
    txt = txt or ""
    local width = 100
    local len = txt:len()
    local ty = ((len > width) and 0.12) or ((len < width) and 0.13)
    if(not self.inputTxt)then
        local cmOpts = {
            name = "num_line",
            delay = 0.2,
            width = width,
            maxWidth = width,
            align = 'left',
            font = self.font,
            color = { 0.8, 0.8, 0.9 }, --default_color,
            bgcolor = { 0.3, 0.5, 0.3, 0.6 },
            border = true,
            cursor = true,
            resalt = true,
            camera = self.camera,
            action = function(_txt)
                print("INPUT: ", _txt)
                self:toASMNames(_txt)
            end
        }
        -- utils.tableMerge(cmOpts,{})
        -- INPUT
        self.inputTxt = InputlineActiveModule(txt, gw * 0.02, gh * ty, cmOpts)
    else
        --self.inputTxt.y = gh * ty
        --self.inputTxt.text = txt
        self.inputTxt.setText(txt)
    end
end

function CodeScreen:toASMNames(asmName)
    asmFileName = asmName or "" -- or (dirSaved .. asmFileName .. "." .. asmExt)
    if (asmName) then
        self.asmName = asmName
        asmFileName = asmFileName:gsub("%\\", "/")
        local parts = utils.gsplitTable(asmFileName, "/")
        asmFileName = parts[#parts]
        dirSaved = table.concat(parts, "/"):gsub(asmFileName, "")
        local parts2 = utils.gsplitTable(asmFileName, "%.")
        asmExt = parts2[#parts2]
        asmFileName = table.concat(parts2, "."):gsub("." .. asmExt, "")
    end
    hackFileName = asmFileName
    hackCompareFileName = asmFileName .. "_compare"
    logFileName = asmFileName
    csvFileName = asmFileName .. "_tsymb"
    print(dirSaved, asmFileName, asmExt)
end

function CodeScreen:loadASM()
    local asmLines = {""}
    --[[if(asmFileName:len() > 0)then
        asmLines = _loadFileLines(dirSaved .. asmFileName .. "." .. asmExt)
        self:toMsg("ASM '" .. dirSaved .. asmFileName .. "." .. asmExt .. "' loaded !")
    else
        self:toMsg("NOT ASM !")
    end
    self:makeAreas(table.concat(asmLines, "\n"))]]

    local info = love.filesystem.getInfo(dirSaved .. asmFileName .. "." .. asmExt, "file")
    local asmExists = (info and info.size and info.size > 0) --love.filesystem.exists(asmFileName)
    -- love.filesystem.getInfo
    if (not asmFileName or (asmFileName:len() == 0) or not asmExists) then
        self.asmName = nil
        self:toMsg("NOT ASM !")
        print("ASM-NAME: nil or not exists")
    else
        self.asmName = asmFileName
        asmLines = _loadFileLines(dirSaved .. asmFileName .. "." .. asmExt)
        self:toMsg("ASM '" .. dirSaved .. asmFileName .. "." .. asmExt .. "' loaded !")
    end
    self:makeAreas(table.concat(asmLines, "\n"))
    return asmLines
end

--[[function CodeScreen:reParse()
    self:loadASM()
end]]

--[[ Crea un Text-Area no-editable para líneas de texto pasado.  
  Admite como parámetros la posición, el tamaño y otras como colores, padding, visualizar números de línea, ...  
  Pero sobre todo necesita que se le pase una cámara y un timer. ]]
function CodeScreen:makeAreaLine(text, pars)
    pars.text = text
    self:add(AreaLines(self, true, pars))
end

function CodeScreen:makeAreas(text)
    if (self.areas) then
        for _, a in ipairs(self.areas) do
            if (a.destroy) then a:destroy() end
        end
    end
    self.areas = {}
    if (self.hp1 and self.hp1.destroy) then self.hp1:destroy() end
    self.hp1 = HParser(text, {zeroIndex = self.zeroIndex})
    self.msg = "Parsed Lines"
    local marginAreas = 2 -- margin entre text-areas
    local pars = {}
    pars._id = utils.UUID()
    pars._type = "AreaLines"
    pars.timer = self.timer
    pars.camera = self.camera
        --input = opts.input or Input(),
    pars.imgFondoPath = self.imgFondoPath
    pars.timer = self.timer --nil --Timer()-- su propio timer ??
    pars.x, pars.y = 10, 50
    pars.w, pars.h = 110, 180
    pars.paddX, pars.paddY = 2, 2 -- padding intro text-areas
    pars.color = { 0.9, 0.8, 0.8, 1 } --negative_colors[1]
    pars.numlines = self.numlines
    pars.visible = true
    pars.zeroIndex = self.zeroIndex
    --[[pars.text = "<<En un lugar \nde la Mancha, \nde cuyo nombre \nno quiero acordarme, \n"
    pars.text = pars.text .. "no ha mucho que \nvivía un hidalgo \nde los de lanza \nen astillero, \nadarga antígüa, \n"
    pars.text = pars.text .. "rocín flaco y \ngalgo corredor>>"
    ]]
    -- AREA-ASM
    pars.name = "ASM"
    self:makeAreaLine(self.hp1.strIn, pars)
    -- AREA-ASM-CLEAN+VARS
    --[[]]
    pars._id = utils.UUID()
    pars.name = "ASM-CLEAN+VARS"
    pars.x, pars.y = pars.x + marginAreas + pars.w, pars.y
    pars.color = { 0.1, 0.8, 0.4, 1 }
    pars.visible = self.varsVisible
    self:makeAreaLine(self.hp1.strClean, pars)
    -- AREA-ASM-CLEAN
    pars._id = utils.UUID()
    pars.name = "ASM-CLEAN"
    --pars.x, pars.y = pars.x + marginAreas + pars.w, pars.y
    pars.color = { 0.1, 0.8, 0.1, 1 }
    pars.visible = not self.varsVisible
    self:makeAreaLine(table.concat(self.hp1.linesIn, "\n"), pars)
    -- AREA-HACK
    pars._id = utils.UUID()
    pars.name = "HACK"
    pars.x, pars.y = pars.x + marginAreas + pars.w, pars.y
    pars.w = 120
    pars.color = { 0.1, 0.6, 0.8, 1 } --negative_colors[5]
    pars.visible = true
    self:makeAreaLine(self.hp1.strOut, pars)
    -- AREA-HACK-COMPARE
    pars._id = utils.UUID()
    pars.name = "HACK-COMPARE"
    pars.x, pars.y = pars.x + marginAreas + pars.w, pars.y
    --pars.w = 120
    self:makeAreaLine("", pars)
end

function CodeScreen:makeButtons()
    self.buttons = {
        Button(1, gw * 0.10, gh * 0.05, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.2, 0.8, 0.4 },
            text = "load",
            w = 30,
            --shape = "circle",
            --subtype = "positive",
            clickMultiple = true,
            title = ".. load ASM",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text) --, btn.type)
                -- LOAD ASM
                self:loadASM()
            end
        }),
        Button(2, gw * 0.30, gh * 0.13, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.2, 0.8, 0.8 },
            text = "N.Lines",
            w = 25,
            --shape = "circle",
            --subtype = "positive",
            clickMultiple = true,
            title = "show/hide number lines ?",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text) --, btn.type)
                self:toggleNumLines()
            end
        }),
        Button(3, gw * 0.40, gh * 0.13, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.2, 0.8, 0.8 },
            text = "+Vars",
            w = 25,
            --shape = "circle",
            --subtype = "positive",
            clickMultiple = true,
            title = "show/hide vars and labels ?",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text) --, btn.type)
                self:toggleVars()
            end
        }),
        Button(4, gw * 0.50, gh * 0.13, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.2, 0.8, 0.8 },
            text = "Z.Index",
            w = 25,
            --shape = "circle",
            --subtype = "positive",
            clickMultiple = true,
            title = "numlines from 'zero-one' index",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text) --, btn.type)
                self:toggleZeroIndex()
            end
        }),
        Button(5, gw * 0.60, gh * 0.13, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.8, 0.2, 0.8 },
            text = "save",
            w = 30,
            --shape = "rectangle",
            subtype = "negative",
            clickMultiple = true,
            title = ".. save HACK-BINARY",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text) --, btn.type)
                -- SAVE HACK
                if(asmFileName:len() > 0)then
                    --[[_writeFile(dirSaved, hackFileName .. "." .. hackExt, self.hp1.strOut)
                    _writeFile(dirSaved, logFileName .. "." .. logExt, utils.dump(self.hp1.summary))
                    _saveCSV(tSymbols, dirSaved, csvFileName .. "." .. csvExt, ";")]]
                    self:saveClean()
                    self:saveCleanVars()
                    self:saveHackBin()
                    self:saveLog()
                    self:saveCSV()
                    self:toMsg("ASM, HACK, LOG and CSV Saved !")
                else
                    self:toMsg("EMPTY-NAME, NOT Saved !")
                end
            end
        }),
        Button(6, gw * 0.85, gh * 0.13, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.1, 0.6, 0.9 },
            text = "compare",
            w = 30,
            --shape = "circle",
            --subtype = "positive",
            clickMultiple = true,
            title = ".. compare HACK",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text) --, btn.type)
                self.areas[5].background_color = background_color
                if(asmFileName:len() == 0)then
                    self:toMsg("EMPTY-NAME, NOT Compare !")
                    return false
                end
                -- LOAD HACK-COMPARE
                local hackLines = _loadFileLines(dirSaved .. hackCompareFileName .. "." .. hackExt)
                self:toMsg("Compare loaded !")
                table.insert(self.hp1.summary.compare, "NumLines=" .. #hackLines)
                self.areas[5]:toLines(table.concat(hackLines, "\n"))
                local result = (#hackLines == #self.hp1.linesOut)
                if(result)then
                    self:toMsg("Equality in number of lines")
                    table.insert(self.hp1.summary.compare, "Equality in number of lines")
                    for index, value in ipairs(hackLines) do
                        result = result and ((self.hp1.linesOut[index] .. "") == (value .. ""))
                        if(not result)then
                            -- info de error en num. de bit
                            local errBit, len = "", value:len()
                            for i = 0, len do
                                if ((self.hp1.linesOut[index] .. ""):sub(len - i, len - i + 1) == (value .. ""):sub(len - i, len - i + 1)) then
                                else
                                    errBit = ", err. bit '" .. i .. "'"
                                    break
                                end
                            end
                            local pseudoIndex = index
                            if(self.zeroIndex)then pseudoIndex = index - 1 end
                            table.insert(self.hp1.summary.compare,
                                "Dif on line '" ..
                                pseudoIndex .. "' [" .. self.hp1.linesOut[index] .. "] -> [" .. value .. "]" .. errBit)
                            self:toMsg(
                                "Compare ... Dif on line '" ..
                                pseudoIndex .. "' [" .. self.hp1.linesOut[index] .. "] -> [" .. value .. "]" .. errBit)
                            break;
                        end
                    end
                else
                    self:toMsg("Different number of lines")
                    table.insert(self.hp1.summary.compare, "Different number of lines")
                end
                if (result) then
                    self:toMsg("Equality in number of lines and bits")
                    self.areas[5].background_color = sp_color
                else
                    self.areas[5].background_color = hp_color
                end
            end
        })
    }
end

--[[ guardar ASM-CLEAN ]]
function CodeScreen:saveClean()
    if (asmFileName:len() > 0) then
        _writeFile(dirSaved, asmFileName .. "_clean." .. asmExt, table.concat(self.hp1.linesIn, "\n"))
        self:toMsg("CLEAN Saved !")
    else
        self:toMsg("CLEAN NOT Saved !")
    end
end

--[[ guardar ASM-CLEAN+VARS ]]
function CodeScreen:saveCleanVars()
    if (asmFileName:len() > 0) then
        _writeFile(dirSaved, asmFileName .. "_clean_vars." .. asmExt, self.hp1.strClean)
        self:toMsg("CLEAN+VARS Saved !")
    else
        self:toMsg("CLEAN+VARS NOT Saved !")
    end
end

--[[ guardar LOG ]]
function CodeScreen:saveLog()
    -- SAVE LOG
    if (asmFileName:len() > 0) then
        _writeFile(dirSaved, logFileName .. "." .. logExt, utils.dump(self.hp1.summary))
        self:toMsg("LOG Saved !")
    else
        self:toMsg("LOG NOT Saved !")
    end
end

--[[ guardar CSV ]]
function CodeScreen:saveCSV()
    -- SAVE LOG
    if (asmFileName:len() > 0) then
        local csv, result = _saveCSV(tSymbols, dirSaved, csvFileName .. "." .. csvExt, ";")
        if (result) then
            self:toMsg("CSV Saved !")
            --print(csv)
        else
            self:toMsg("Error in CSV-File !")
        end
    else
        self:toMsg("LOG NOT Saved !")
    end
end

--[[ guardar HACK-BINARY ]]
function CodeScreen:saveHackBin()
    -- SAVE HACK
    if (asmFileName:len() > 0) then
        _writeFile(dirSaved, hackFileName .. "." .. hackExt, self.hp1.strOut)
        self:toMsg("HACK Saved !")
    else
        self:toMsg("HACK NOT Saved !")
    end
end

function CodeScreen:toMsg(text)
    if(self.hp1)then table.insert(self.hp1.summary.info, text) end
    self.msg = text
end
function CodeScreen:toggleZeroIndex()
    self.zeroIndex = not self.zeroIndex
    for index, area in ipairs(self.areas) do
        area.zeroIndex = self.zeroIndex
    end
end
function CodeScreen:toggleNumLines()
    self.numlines = not self.numlines
    for index, area in ipairs(self.areas) do
        area.numlines = self.numlines
    end
end

function CodeScreen:toggleVars()
    self.varsVisible = not self.varsVisible
    self.areas[2].visible = self.varsVisible
    self.areas[3].visible = not self.varsVisible
end


-- pausa o reanuda definitivamente la room en función del parámetro "yesNo", en caso de 
-- segundo parámetro se temporizará esta acción.  
-- EL PROBLEMA DE ESTO ES QUE TENDRÍA QUE DES-PAUSARSE DESDE UN NIVEL SUPERIOR DEL JUEGO, ya que tanto el 
-- "update()" como el "draw()" se detendrán y ningún hijo avanzará de estado (ni áreas, ni player, ni director, ni ná).
function CodeScreen:pause(yesNo, msg)
    if(yesNo == nil)then yesNo = true end
    if(msg)then
        self.timer:after(msg, function()
            self.paused = yesNo
        end)
    else
        self.paused = yesNo
    end
end
-- pausa o reanuda TEMPORÁLMENTE la room en función del parámetro "yesNo", a partir de los milisegundos del segundo
-- parámetro se reanudará el estado anterior.
-- NO HAY PROBLEMA, en caso de pausa ningún hijo avanzará de estado (ni áreas, ni player, ni efectos, ni ná) durante
-- los milisegundos estipulados, luego todo volverá a fluir.
function CodeScreen:pauseTemp(yesNo, msg)
    local p = self.paused
    if (yesNo == nil) then yesNo = true end
    if (not msg) then msg = 10 end
    self.paused = yesNo
    self.timer:after(msg, function()
        self.paused = p
    end)
end


function CodeScreen:destroy()
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
    if (self.imgFondo) then
        self.imgFondo = nil
    end
    self.fondo_img_chances = nil
    if (self.buttons) then
        for _, b in ipairs(self.buttons) do
            if (b.destroy) then b:destroy() end
        end
        self.buttons = {}
    end
    self.buttons = nil
    if(self.inputTxt and self.inputTxt.destroy)then self.inputTxt:destroy() end
    self.inputTxt = nil
    CodeScreen.super.destroy(self)
end


-- NO PUEDE LLAMARSE drawUI() porque provoca PROBLEMAS con alguna librería "AI Lib" extraños.
function CodeScreen:drawUI2()
    -- Score
    -- CodeScreen-NAME
    love.graphics.setColor(hp_color)
    love.graphics.print(
        "HackAssembler v1.0", --self.type,
        gw * 0.5,
        10 + self.font:getHeight(),
        0,
        2, 2,
        math.floor(self.font:getWidth(self.type) / 2),
        self.font:getHeight()
    )
    if(self.inputTxt and self.inputTxt.draw)then self.inputTxt:draw() end
end

function CodeScreen:drawFondoImg()
    self.zoom = self.zoom + self.fondoZoom / 10
    self.fondoZoom = 0 -- restaura el zoom
    if (self.zoom > maxZoom) then self.zoom = maxZoom end
    if (self.zoom < minZoom) then self.zoom = minZoom end
    if (self.imgFondo) then
        --love.graphics.draw(self.imgFondo, 0, 0, 0, sx * self.zoom, sy * self.zoom)
        love.graphics.draw(self.imgFondo, 0, 0, 0, self.zoom, self.zoom)
    end
end

function CodeScreen:update(dt)
    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    --if (self.director.finished) then return false end
    -- al actualizar AQUÍ la clase padre, se DOBLA LA VELOCIDAD DE JUEGO
    -- PUEDE OMITIRSE COMENTANDO LAS SIGUIENTES DOS LÍNEAS:
    local result = CodeScreen.super.update(self, dt)
    if not result then return false end

    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    if self.dead or not self.areas then return false end
    --if (not self.camera) then return false end
    --self.camera.smoother = Camera.smooth.damped(5)
    --self.camera:lockPosition(gw / 2, gh / 2)

    --[[
    -- CRONÓMETRO MORTAL
    if(self.max_time)then
        --if (self.total_time > self.max_time) then self.director:destroy() end
        if (self.total_time > self.max_time) then
            self.director.finished = true
            self.total_time = 0
        else
            --self.director.finished = false
        end
    end]]

    for _, area in ipairs(self.areas) do
        area:update(dt)
    end

    for i = 1, #self.buttons do
        self.buttons[i]:update(dt)
    end

    if(self.inputTxt and self.inputTxt.update)then self.inputTxt:update(dt) end

    return true
end

-- dibuja el marco o borde de la pantalla ÚTIL
function CodeScreen:drawBorderScreen()
    if(not with_borders)then return false end
    -- BORDER-UTIL
    local x, y, width, height = 4, 3, gw * 0.98, gh * 0.97
    local opts = {
        maxLinesX = nil,
        maxLinesY = nil,
        line_width = width * 0.05,
        line_height = height * 0.05,
        paddX = width * 0.05,
        paddY = height * 0.05,
        scaleX = sx,
        scaleY = sy,
        color = { 0.6, 0.6, 0.6, 0.6 }
    }
    for _, line in ipairs(utils.borderLinesRect(x, y, width, height, opts)) do
        love.graphics.line(line[1], line[2], line[3], line[4])
    end
end

function CodeScreen:drawMsg()
    love.graphics.setColor(sp_color)
    --print("COMMENTS: ", self.hp1.summary.info)
    love.graphics.print(
        self.msg,
        gw * 0.10,
        gh * 0.85
    )
    love.graphics.setColor(ray_color)
    love.graphics.setFont(self.fontMsg)
    love.graphics.print(
        table.concat(self.hp1.summary.info, "\n"),
        gw * 0.05,
        gh * 0.90
    )
end

--[[function CodeScreen:drawUI()
    love.graphics.draw(self.imgFondo, 0, 0)
    love.graphics.circle('line', gw / 2, gh / 2, 50)
end]]

function CodeScreen:draw()
    --if (self.paused or not self.visible) then return false end
    if (not self.visible) then return false end
    local result = CodeScreen.super.draw(self)
    if (not result) then return false end
    if (not self.camera or not self.areas) then return false end
    -- inner-canvas
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        self.camera:attach(0, 0, gw, gh)
            self:drawFondoImg()
            --self:drawUI()
            self:drawBorderScreen()
            for _, area in ipairs(self.areas) do
                area:draw()
            end
            -- BUTTONS
            for i = 1, #self.buttons do
                self.buttons[i]:draw()
            end
            --print(utils.dump(self.hp1.regsOut))
            --[[for _, reg in ipairs(self.hp1.regsOut) do
                reg:draw()
            end]]
            self:drawMsg()
        self.camera:detach()
        love.graphics.setFont(self.font)
        self:drawUI2()
        --love.graphics.setFont(self.font)
    love.graphics.setCanvas()

    -- outer-canvas
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
    -- mark
    --self:mark(50, 50)
    return true
end

-- Events
function CodeScreen:textinput(t)
    --print('main.lua', t)
    if (t == "escape") then
        self:finish()
    end

    if(self.inputTxt and self.inputTxt.textinput)then self.inputTxt:textinput(t) end

    CodeScreen.super.textinput(self, t)
end

return CodeScreen