if (_G["CodeNoScreen"]) then
    return _G["CodeNoScreen"]
end

local Room = require "objects.rooms.Room"

local CodeNoScreen = Room:extend()

local HParser = require "objects.api.HParser"
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

function CodeNoScreen:new(_camera, opts)
    opts = opts or {zeroIndex = true}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "CodeNoScreen",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        --input = opts.input or Input(),
        imgFondoPath = opts.imgFondoPath
    }
    CodeNoScreen.super.new(self, true, pars) -- current, opts
    self._type = "CodeNoScreen"
    self.type = "CodeNoScreen"

    self.paused = false
    self.visible = false

    if (type(opts.zeroIndex) == "boolean") then
        self.zeroIndex = opts.zeroIndex
    else
        self.zeroIndex = true
    end

    -- control a través de tiempo.
    -- Si se especifica "max_time" se pasa a limitar la partida a un máximo de tiempo
    self.max_time = 300 --30, nil

    self:toASMNames(opts.asmName)
    if(asmFileName:len() > 0)then
        print("ASM-NAME:" .. self.asmName)
        local asmLines = self:loadASM() -- después de esto "self.asmName" puede ser nulo (nil)
        if(self.asmName)then
            self:toParser(table.concat(asmLines, "\n"))
            self:saveClean()
            self:saveCleanVars()
            self:saveHackBin()
            local hackLines = self:loadHACK()
            local result = self:compareHackBin(hackLines)
            self:saveLog()
            self:saveCSV()
            self:toMsg("HACK, LOG and CSV Saved !")
        end
    else
        print("NOT ASM-NAME VALID ! .. FINISHING ..")
    end

    -- elimina la pantalla al completar los cálculos
    self:finish()
end

function CodeNoScreen:toASMNames(asmName)
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

function CodeNoScreen:loadASM()
    local asmLines = {""}
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
    return asmLines
end

function CodeNoScreen:loadHACK()
    local hackLines = {""}
    local info = love.filesystem.getInfo(dirSaved .. hackCompareFileName .. "." .. hackExt, "file")
    local hackExists = (info.size and info.size > 0) --love.filesystem.exists(hackCompareFileName)
    if (not asmFileName or (asmFileName:len() == 0) or not hackExists) then
        self:toMsg("NOT HACK-COMPARE !")
    else
        hackLines = _loadFileLines(dirSaved .. hackCompareFileName .. "." .. hackExt)
        self:toMsg("HACK-Compare '" .. dirSaved .. hackCompareFileName .. "." .. hackExt .. "' loaded !")
        table.insert(self.hp1.summary.compare, "NumLines=" .. #hackLines)
    end
    return hackLines
end

function CodeNoScreen:toParser(text)
    self.areas = {}
    self.hp1 = HParser(text, {zeroIndex = self.zeroIndex})
    self:toMsg("Parsed Lines")
    -- AREA-ASM: self.hp1.strIn
    -- AREA-ASM-CLEAN+VARS: self.hp1.strClean
    -- AREA-ASM-CLEAN: self.hp1.linesIn
    -- AREA-HACK: self.hp1.strOut
    -- AREA-HACK-COMPARE: arg[2]
end

--[[ guardar ASM-CLEAN ]]
function CodeNoScreen:saveClean()
    if (asmFileName:len() > 0) then
        _writeFile(dirSaved, asmFileName .. "_clean." .. asmExt, table.concat(self.hp1.linesIn, "\n"))
        self:toMsg("CLEAN Saved !")
    else
        self:toMsg("CLEAN NOT Saved !")
    end
end
--[[ guardar ASM-CLEAN+VARS ]]
function CodeNoScreen:saveCleanVars()
    if (asmFileName:len() > 0) then
        _writeFile(dirSaved, asmFileName .. "_clean_vars." .. asmExt, self.hp1.strClean)
        self:toMsg("CLEAN+VARS Saved !")
    else
        self:toMsg("CLEAN+VARS NOT Saved !")
    end
end
--[[ guardar LOG ]]
function CodeNoScreen:saveLog()
    -- SAVE LOG
    if (asmFileName:len() > 0) then
        _writeFile(dirSaved, logFileName .. "." .. logExt, utils.dump(self.hp1.summary))
        self:toMsg("LOG Saved !")
    else
        self:toMsg("LOG NOT Saved !")
    end
end

--[[ guardar CSV ]]
function CodeNoScreen:saveCSV()
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
function CodeNoScreen:saveHackBin()
    -- SAVE HACK
    if(asmFileName:len() > 0)then
        _writeFile(dirSaved, hackFileName .. "." .. hackExt, self.hp1.strOut)
        self:toMsg("HACK Saved !")
    else
        self:toMsg("HACK NOT Saved !")
    end
end

function CodeNoScreen:compareHackBin(hackLines)
    table.insert(self.hp1.summary.compare, "NumLines=" .. #hackLines)
    local result = (#hackLines == #self.hp1.linesOut)
    if(result)then
        self:toMsg("Equality in number of lines")
        table.insert(self.hp1.summary.compare, "Equality in number of lines")
        for index, value in ipairs(hackLines) do
            result = result and (self.hp1.linesOut[index] .. "" == (value .. ""))
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
    end
    return result
end

function CodeNoScreen:toMsg(text)
    if(self.hp1)then table.insert(self.hp1.summary.info, text) end
end

function CodeNoScreen:destroy()
    self.hp1.destroy()
    self.hp1 = nil
    CodeNoScreen.super.destroy(self)
end

function CodeNoScreen:update(dt)
    return false
end

function CodeNoScreen:draw()
    return false
end

return CodeNoScreen