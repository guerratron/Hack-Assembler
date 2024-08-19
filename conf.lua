--local bitser = require '_LIBS_.bitser.bitser'

gw = 480    -- ancho original windows
gh = 270    -- alto original windows
sx = 1      -- escala del ancho (a utilizar en el dibujado de algunas pantallas, gameobjects, ..)
sy = 1      -- escala del alto (a utilizar en el dibujado de algunas pantallas, gameobjects, ..)
minZoom, maxZoom = 1, 4

language = "ES"

default_color = { 0.9, 0.9, 0.9, 1 }
background_color = { 0.1, 0.1, 0.1, 1 }
impact_color = { 1, 1, 1, 1 }
ammo_color = { 0.5, 0.8, 0.7, 1 }
boost_color = { 0.3, 0.8, 0.9, 1 }
boost_up_color = { 0.3, 0.8, 0.9, 1 }
boost_down_color = { 0.8, 0.3, 0.3, 1 }
hp_color = { 1, 0.4, 0.2, 1 }
sp_color = { 1, 1, 0.2, 1 }
skill_point_color = { 1, 0.8, 0.4, 1 }
invincible_color = { 0.6, 0.6, 0, 1 }
title_color = boost_color
resalt_color = hp_color

bullet_color = { 1, 0.3, 0.3, 1 }
shooter_color = { 0.8, 0.2, 0.2, 1 }
seeker_color = { 0.7, 0.3, 0.3, 1 }

rapid_color = { 0.9, 0.9, 0.1, 1 }
double_color = { 0.1, 0.1, 0.5, 1 }
double_back_color = { 0.1, 0.1, 0.9, 1 }
triple_color = { 0.1, 0.5, 0.1, 1 }
triple_back_color = { 0.1, 0.9, 0.1, 1 }
side_color = { 0.5, 1, 1, 1 }
spread_color = { 0.6, 0, 0.6, 1 }
homing_color = { 0.9, 0.2, 0.9, 1 }
blast_color = { 0.6, 0.6, 0.9, 1 }
spin_color = { 0.9, 0.6, 0.6, 1 }
bounce_color = { 0.6, 0.9, 0.6, 1 }
ray_color = { 1, 0.6, 0.2, 1 }

default_colors = { default_color, hp_color, ammo_color, boost_color, skill_point_color }
negative_colors = {
    { 1 - default_color[1],     1 - default_color[2],     1 - default_color[3] },
    { 1 - hp_color[1],          1 - hp_color[2],          1 - hp_color[3] },
    { 1 - ammo_color[1],        1 - ammo_color[2],        1 - ammo_color[3] },
    { 1 - boost_color[1],       1 - boost_color[2],       1 - boost_color[3] },
    { 1 - skill_point_color[1], 1 - skill_point_color[2], 1 - skill_point_color[3] }
}

--[[ Tabla de Destinos:
    * referencia en binario a los destinos posibles en lógica "HACK" ]]
tDest = {
    --d1 d2 d3 Mnemonic Destination (where to store the computed value)
    --0 0 0 null The value is not stored anywhere
    M= "001",   -- Memory[A] (memory register addressed by A)
    D= "010",   -- D register
    MD= "011",  -- Memory[A] and D register
    A= "100",   -- A register
    AM= "101",  -- A register and Memory[A] 
    AD= "110",  -- A register and D register
    AMD= "111", -- A register, Memory[A], and D register
};
--[[ Tabla de Cálculos:
    * referencia en binario a las posibles operaciones de la ALU en lógica "HACK" ]]
tComp = {
    ["0"]=    "0101010", -- a=0
    ["1"]=    "0111111", -- a=0
    ["-1"]=   "0111010", -- a=0
    D=      "0001100", -- a=0
    A=      "0110000", -- a=0
    M=      "1110000", -- a=1
    ["!D"]=   "0001101", -- a=0
    ["!A"]=   "0110001", -- a=0
    ["!M"]=   "1110001", -- a=1
    ["-D"]=   "0001111", -- a=0
    ["-A"]=   "0110011", -- a=0
    ["-M"]=   "1110011", -- a=1
    ["D+1"]= "0011111", -- a=0
    ["A+1"]= "0110111", -- a=0
    ["M+1"]= "1110111", -- a=1
    ["D-1"]= "0001110", -- a=0
    ["A-1"]= "0110010", -- a=0
    ["M-1"]= "1110010", -- a=1
    ["D+A"]= "0000010", -- a=0
    ["D+M"]= "1000010", -- a=1
    ["D-A"]= "0010011", -- a=0
    ["D-M"]= "1010011", -- a=1
    ["A-D"]= "0000111", -- a=0
    ["M-D"]= "1000111", -- a=1
    ["D&A"]= "0000000", -- a=0
    ["D&M"]= "1000000", -- a=1
    ["D|A"]= "0010101", -- a=0
    ["D|M"]= "1010101", -- a=1
};
--[[ Tabla de Saltos:
    * referencia en binario a los saltos posibles en lógica "HACK" ]]
tJump = {
    --   j1        j2       j3
    --(out < 0) (out ¼ 0) (out > 0) Mnemonic Effect
    --0 0 0                         null    not jump
    JGT= "001", -- If out > 0 jump
    JEQ= "010", -- If out = 0 jump
    JGE= "011", -- If out >= 0 jump
    JLT= "100", -- If out < 0 jump
    JNE= "101", -- If out != 0 jump
    JLE= "110", -- If out <= 0 jump
    JMP= "111", -- Jump
};

--[[ Tabla de Símbolos: (puede incrementarse a lo largo del programa)
    * nuevos símbolos o variables a partir de la 16 (máximo hasta la 16383 [16369 en total]) ]]
tSymbols = {
    R0= 0,
    R1= 1,
    R2= 2,
    R3= 3,
    R4= 4,
    R5= 5,
    R6= 6,
    R7= 7,
    R8= 8,
    R9= 9,
    R10= 10,
    R11= 11,
    R12= 12,
    R13= 13,
    R14= 14,
    R15= 15,
    SP= 0,
    LCL= 1,
    ARG= 2,
    THIS= 3,
    THAT= 4,
    SCREEN= 16384, --8k -> 24575
    KBD= 24576
};

--[[ Reinicia a su estado original (variables por defecto) la tabla anterior. */ ]]
function _resetTSymbols()
    tSymbols = {
        R0= 0,
        R1= 1,
        R2= 2,
        R3= 3,
        R4= 4,
        R5= 5,
        R6= 6,
        R7= 7,
        R8= 8,
        R9= 9,
        R10= 10,
        R11= 11,
        R12= 12,
        R13= 13,
        R14= 14,
        R15= 15,
        SP= 0,
        LCL= 1,
        ARG= 2,
        THIS= 3,
        THAT= 4,
        SCREEN= 16384, --8k -> 24575
        KBD= 24576,
    };
end

function love.conf(t)
    --t.identity = nil                    -- The name of the save directory (string)
    t.appendidentity = true               -- Search files in source directory before save directory (boolean)
    t.version = "11.4"                    -- The LÖVE version this game was made for (string)
    --t.console = false                   -- Attach a console (boolean, Windows only)
    t.accelerometerjoystick = false       -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.externalstorage = true              -- True to save files (and read from the save directory) in external storage on Android (boolean)
    --t.gammacorrect = false              -- Enable gamma-correct rendering, when supported by the system (boolean)

    t.audio.mic = false                   -- Request and use microphone capabilities in Android (boolean)
    t.audio.mixwithsystem = false         -- Keep background music playing when opening LOVE (boolean, iOS and Android only)

    t.window.title = "HackAssembler - v1.0"  -- The window title (string)
    t.window.icon = "favicon.png"            -- Filepath to an image to use as the window's icon (string)
    t.window.width = gw                   -- The window width (number)
    t.window.height = gh                  -- The window height (number)
    --t.window.borderless = false         -- Remove all border visuals from the window (boolean)
    t.window.resizable = true             -- Let the window be user-resizable (boolean)
    --t.window.minwidth = 1               -- Minimum window width if the window is resizable (number)
    --t.window.minheight = 1              -- Minimum window height if the window is resizable (number)
    --t.window.fullscreen = false         -- Enable fullscreen (boolean)
    --t.window.fullscreentype = "desktop" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
    t.window.vsync = true                 -- Vertical sync mode (number)
    --t.window.fsaa = 0                   -- The number of samples to use with multi-sampled antialiasing (number)
    --t.window.msaa = 0                   -- The number of samples to use with multi-sampled antialiasing (number)
    --t.window.depth = nil                -- The number of bits per sample in the depth buffer
    --t.window.stencil = nil              -- The number of bits per sample in the stencil buffer
    --t.window.display = 1                -- Index of the monitor to show the window in (number)
    --t.window.highdpi = false            -- Enable high-dpi mode for the window on a Retina display (boolean)
    --t.window.usedpiscale = true         -- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
    --t.window.srgb = false               -- Enable sRGB gamma correction when drawing to the screen (boolean)
    --t.window.x = nil                    -- The x-coordinate of the window's position in the specified display (number)
    --t.window.y = nil                    -- The y-coordinate of the window's position in the specified display (number)

    t.modules.audio = true    -- Enable the audio module (boolean)
    t.modules.data = true     -- Enable the data module (boolean)
    t.modules.event = true    -- Enable the event module (boolean)
    t.modules.font = true     -- Enable the font module (boolean)
    t.modules.graphics = true -- Enable the graphics module (boolean)
    t.modules.image = true    -- Enable the image module (boolean)
    t.modules.joystick = true -- Enable the joystick module (boolean)
    t.modules.keyboard = true -- Enable the keyboard module (boolean)
    t.modules.math = true     -- Enable the math module (boolean)
    t.modules.mouse = true    -- Enable the mouse module (boolean)
    t.modules.physics = false -- Enable the physics module (boolean)
    t.modules.sound = true    -- Enable the sound module (boolean)
    t.modules.system = true   -- Enable the system module (boolean)
    t.modules.thread = true   -- Enable the thread module (boolean)
    t.modules.timer = true    -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = true    -- Enable the touch module (boolean)
    t.modules.video = false   -- Enable the video module (boolean)
    t.modules.window = true   -- Enable the window module (boolean)
end

--[[function treeToPlayer(_tree, player, bought_node_indexes)
    for _, index in ipairs(bought_node_indexes) do
        local stats = _tree[index].stats
        for i = 1, #stats, 3 do
            local attribute, value = stats[i + 1], stats[i + 2]
            player[attribute] = player[attribute] + value
        end
    end
end]]--


input = nil
rooms = nil
camera = nil
fonts = {}
slow_amount = 1    -- ralentización del tiempo de update
flash_frames = nil -- relampaguear la pantalla n segundos
first_run_ever = false
with_borders = false

function resize(s)
    love.window.setMode(s * gw, s * gh)
    sx, sy = s, s -- en conf.lua
end

-- ralentiza el tiempo, para efectos llamados de forma global desde gameobjects
function slow(timer, amount, duration)
    slow_amount = amount
    -- Timer:tween(delay, subject, target, method, after, tag, ...)
    -- timer:tween('slow', duration, _G, { slow_amount = 1 }, 'in-out-cubic')
    timer:tween(duration, _G, { slow_amount = 1 }, 'in-out-cubic', nil, 'slow')
end

-- la pantalla relampaguea durante n segundos
function flash(frames)
    flash_frames = frames
end

Sounds = nil

--[=[
-- cargar un archivo "asm"
-- cargar datos de C:\Users\user\AppData\Roaming\[GAME_NAME]\[FILE_NAME]
function _loadFile(nameFile)
    print("loading file .. '" .. nameFile .. "' ")
    local info = love.filesystem.getInfo(nameFile, "file")
    local loaded_data = nil
    --if love.filesystem.exists('save') then
    if info and info.size > 0 then
        --loaded_data = bitser.loadLoveFile(nameFile)
        loaded_data = bitser.loadData(nameFile)
        if (loaded_data) then
            print("OK cargado")
        else
            print("NO cargado")
        end
    else
        first_run_ever = true
        print("Not file [" .. nameFile .. "]")
    end
    --print("LOAD: ship_selected", loaded_data.ship_selected)
    return loaded_data
end
Parsea un archivo tipo "*.csv" y retorna una tabla (de filas) donde cada 
línea es otra tabla con valores (celdas) parseados a su tipo correcto (number, boolean, string)

Admite como segundo parámetro opcional un separador (por defecto en Europa=';', England=',')
```lua
--cool.csv: Foo,Bar,true,false,11.8
local csv = loadCSV("cool.csv")
for row, values in ipairs(csv) do
	print("row="..row.." count="..#values.." values=", unpack(values))
end
```
]=]
function _loadCSV(nameFile, sep)
    sep = sep or ";" -- ; ,
    local function _splitCsvLine(line)
        local values = {}
        if(line)then
            for value in line:gmatch("[^" .. sep .. "+") do -- Note: We won't match empty values.
                -- Convert the value string to other Lua types in a "smart" way.
                if     tonumber(value)  then  table.insert(values, tonumber(value)) -- Number.
                elseif value == "true"  then  table.insert(values, true)            -- Boolean.
                elseif value == "false" then  table.insert(values, false)           -- Boolean.
                else                          table.insert(values, value)           -- String.
                end
            end
        end
        return values
    end

    local function _loadCsvFile(filename)
        local csv = {}
        print("CSV .. '" .. nameFile .. "' ")
        local info = love.filesystem.getInfo(nameFile, "file")
        if info and info.size > 0 then
            for line in love.filesystem.lines(filename) do
                table.insert(csv, _splitCsvLine(line))
            end
        end
        return csv
    end
    return _loadCsvFile(nameFile);
end
--[=[
Crea un archivo tipo "*.csv" y retorna una cadena como representación de la tabla entregada. 
Esta tabla debe ser asociativa sencilla del tipo 'tSymbols' con claves y valores que se 
convertirán en una cadena de dos filas: una de claves y otra de valores separadas por el 
separador aportado.

Admite como segundo parámetro opcional un separador (por defecto en Europa=';', England=',')

Retorna la cadena y como segundo retorno el éxito de escritura en el archivo.

```lua
--cool.csv: Foo,Bar,true,false,11.8
local csv = saveCSV(tsymbs, "saves/", "cool.csv", ",")
print(csv)
```
]=]
function _saveCSV(t, dir, nameFile, sep)
    sep = sep or ";" -- ; ,
    local data = ""

    local nl = "\n"
    local i = 0
    local _sep = ""
    -- línea cabecera de claves (1 línea)
    for key, _ in pairs(t) do
        if(i > 0)then _sep = sep end
        data = data .. _sep .. key
        i = i + 1
    end
    -- línea de valores (1 línea)
    if(data:len() > 0)then data = data .. nl end
    i = 0
    _sep = ""
    for _, val in pairs(t) do
        if (i > 0) then _sep = sep end
        if val == true  then  val = "true"      -- Boolean.
        elseif val == false then  val = "false" -- Boolean.
        else
            val = tostring(val)
        end
        data = data .. _sep .. val
        i = i + 1
    end
    --print("save CSV-Data: ", data)
    return data, _writeFile(dir, nameFile, data);
end

--[[ carga un archivo y retorna una tabla con sus líneas.  
 * Si existe lo busca en la ruta actual, sinó en la ruta de guardado ]]
function _loadFileLines(filename)
    print("loading file lines .. '" .. filename .. "' ")
    local loaded_data = {}
    local info = love.filesystem.getInfo(filename, "file")
    local fileExists = (info and info.size and info.size > 0)
    if(fileExists)then
        local _iter = love.filesystem.lines(filename)
        if(_iter)then
            for line in _iter do
                table.insert(loaded_data, line)
            end
        end
    end
    --print("LOAD: ship_selected", loaded_data.ship_selected)
    return loaded_data
end
--[[ el archivo sólo se guarda en el directorio de guardado del programa según su "identity" ]]
function _writeFile(dir, filename, data)
    -- se necesita primero crear el directorio
    local successDir = love.filesystem.createDirectory(dir)
    if(successDir)then
        print("Directory '" .. dir .. "' created")
    end
    local success, message = love.filesystem.write(dir .. filename, data)
    if success then
        print("file '" .. dir .. filename .. "' saved")
    else
        print('file not saved: ' .. message)
    end
    return success
end
-- fin cargar archivo "asm"


loadedData = {}

-- borra todos los logros (achievements, skills, ships, ..)
-- CUIDADO ! También se pierden todos los puntos gastados.
--[[function _delData()
    print("deleting data ..")
    local globalsData = { "slow_amount", "gw", "gh", "sx", "sy", "minZoom", "maxZoom", "ship_selected", "ship_cost",
        "with_borders" }
    local save_data = {}
    -- resetea y guarda achievements
    for key, _ in pairs(achievements) do
        --print("SAVE-ACHIEVEMENTS", key, achievements[key])
        achievements[key] = false
        save_data[key] = achievements[key] --value
    end
    -- resetea algunas globales y las guarda
    ships = {
        Fighter = true,
        Master = false,
        Medium = false,
        Tulip = false,
        Crusader = false
    }
    ship_selected = "Fighter"
    bought_node_indexes = {1}
    save_data["bought_node_indexes"] = bought_node_indexes
    for i = 1, #globalsData do
        local key = globalsData[i]
        save_data[key] = _G[key]
        --print("SAVE3: ", key, save_data[key])
    end
    loadedData = save_data
    bitser.dumpLoveFile('save', save_data)
end

-- guardar datos en la global "loadedData"
function saveData(data)
    if (data) then
        --[=[print(#data)
        for i = 1, #data do
            print(data[i])
        end]=]
        for key, value in pairs(data) do
            --print(key, value)
            loadedData[key] = data[key] --value
        end
    end
end
-- guardar datos en C:\Users\user\AppData\Roaming\[GAME_NAME]  
-- al mismo tiempo guarda variables globales, o todas (nil), o las indicadas
function save(data, globalsData)
    print("saving data ..")
    if(globalsData == nil)then
        globalsData = { "slow_amount", "gw", "gh", "sx", "sy", "minZoom", "maxZoom", "ship_selected", "ship_cost",
            "with_borders" }
    end
    local save_data = {}
    -- Set all save data here: 
    if (data == nil) then
        data = loadedData
    end
    -- guarda el resto de variables pasadas (de forma estructurada por claves y valores)
    --[=[print(#data)
    for i = 1, #data do
        print(data[i])
    end]=]
    -- además guarda las pasadas por parámetro (puede sobreescibir "achievements")
    for key, _ in pairs(data) do
        --print(key, value)
        save_data[key] = data[key] --value
        --print("SAVE2: ", key, save_data[key])
    end
    -- guarda achievements
    for key, _ in pairs(achievements) do
        --print("SAVE-ACHIEVEMENTS", key, achievements[key])
        save_data[key] = achievements[key] --value
    end
    -- guarda las globales (puede sobreescibir algunas como "ship_selected")
    for i = 1, #globalsData do
        local key = globalsData[i]
        save_data[key] = _G[key]
        --print("SAVE3: ", key, save_data[key])
    end
    --print("SAVE: ship_selected", save_data.ship_selected, data.ship_selected, ship_selected)
    --print("SAVE:achievements[_10k]", achievements["_10k"])
    --print("SAVE:save_data[_10k]", save_data["_10k"])
    --print(utils.dump(save_data))
    bitser.dumpLoveFile('save', save_data)
end
-- cargar datos de C:\Users\user\AppData\Roaming\[GAME_NAME]\save  
-- al mismo tiempo puede actualizar variables globales con los valores guardados.
function load(globalsData)
    print("loading data ..")
    local info = love.filesystem.getInfo("save", "file")
    local loaded_data = nil
    --if love.filesystem.exists('save') then
    if info.size > 0 then
        loaded_data = bitser.loadLoveFile('save')
        if(loaded_data)then
            -- Load all saved data here
            -- skill_points = save_data.skill_points
            --slow_amount = loaded_data.slow_amount
            -- da valor a las globales
            if(globalsData)then
                for i = 1, #globalsData do
                    local key = globalsData[i]
                    -- si existe en las globales y en las guardadas
                    if ((_G[key] or (_G[key] == false)) and (loaded_data[key] or (loaded_data[key] == false))) then
                        _G[key] = loaded_data[key]
                    end
                end
            end
            -- También actualiza la global "achievements"
            for key, _ in pairs(achievements) do
                --print("LOAD-ACHIEVEMENTS-1", key, value)
                -- si existe la clave en "loadedData" la copia a "achievements"
                if (loaded_data[key] or (loaded_data[key] == false)) then
                    --print("LOAD-ACHIEVEMENTS-2", key, loaded_data[key])
                    achievements[key] = loaded_data[key] --value
                end
            end

            if(loaded_data["ships"])then
                ships = loaded_data["ships"]
            end
            --print("LOAD:achievements[_10k]", achievements["_10k"])
        end
    else
        first_run_ever = true
    end
    --print("LOAD: ship_selected", loaded_data.ship_selected)
    return loaded_data
end]]

-- lee las variables almacenadas y actualiza las globales guardadas (también "achievements")
-- loadedData = load({ "slow_amount", "gw", "gh", "sx", "sy", "minZoom", "maxZoom", "ship_selected", "ship_cost",
--    "with_borders" })

--print(utils.dump(loadedData))

--shoot_sound = nil
--sounds = nil