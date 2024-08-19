if (_G["HParser"]) then
    return _G["HParser"]
end

--[[
 Parseador para archivos "asm" de tipo "Hack". (Es símplemente "computacional", no tiene ninguna "UI")  

 Interpreta código máquina "ASM-HACK" permitiendo analizarlo y convertirlo a código máquina binario "hack" 
 para que pueda utilizarse en ordenadores virtuales "HACK-COMPUTER" (nand2tetris.org)

 Trabaja identificando línea a línea qué tipo de instrucción es (L, A, C) y asignando espacio en el mapa de memoria (tabla de símbolos) con las variables y etiquetas encontradas, posteriormente traduce todo esto a líneas binarias tipo "hack" donde se codifican los distintos campos (dest, comp, jump, ..) con ceros y unos (0, 1). La salida se encuentra optimizada y preparada para su ejecución en la "CPU" de un "HACK-COMPUTER".

 La cadena de entrada al constructor se espera como leída de un archivo máquina "*.asm" (tipo Hack); también hay que tener en cuenta que admite comentarios genéricos de tipo 'C++' (tanto monolínea como multilíneas), también se ocupa en la sección de limpieza de eliminar espacios en blanco y saltos de línea inservibles.

 Como opciones admite un 'id', un 'name' y una 'desc' por si se utilizan varios objetos de este tipo conjúntamente y se desea su identificación.

 La información la guarda en tablas de utilidad (self.linesIn y self.linesOut) aunque también tiene un campo 
 informativo (self.summary) a modo de resúmen de las labores realizadas, con conteo de líneas y su tipo (L, A, C), limpieza 
 de comentarios, asignación en memoria de etiquetas y variables, ...

 Trabaja con tablas globales definidas en "conf.lua" (tDest, tComp, tJump y tSymbols), de hecho 
 MODIFICA la tabla tSymbols con nuevas etiquetas y variables (de eso se trata)
]]
HParser = Object:extend()

--local HReg = require "objects.api.HReg"
local Utils = require "tools.utils"

-- También resetea la "Tabla de Símbolos" del mapa de memoria.
function HParser:new(_strIn, _opts)
    self.id = "1"
    self.name = "bit1"
    self.desc = ""
    self.summary = {}
    self:reset()
    self.opts = _opts or {} --optionsSanitize(_opts);
    self.id = self.opts.id or self.id
    self.name = self.opts.name or self.name
    self.desc = self.opts.desc or self.desc

    -- puede construirse todo ahora o postponerlo hasta ejecutar el método "setStrIn(..)"
    if(_strIn)then
        self:setStrIn(_strIn);
    end
end

function HParser:reset()
    self.strIn = "" --hack-asm
    self.strClean = "" --hack-asm clean
    self.strOut = "" --hack-binary
    self.linesIn = {} --array hack-asm clean
    self.linesOut = {} --array hack-binary clean
    --self.regsOut = {} --array de registros hack-binary
    self.nextSymbolDir = 16;
    self.summary = { L = 0, A = 0, C = 0, comments = { multi = 0, mono = 0, sp = 0, win = 0, nl = 0, ini = 0, fin = 0 }, info = {}, compare = {} }

    _resetTSymbols();
end


function HParser:destroy()
    self:reset()
end

--[[ Punto de entrada principal para analizar una cadena, limpieza y obtener el código producido. 
  * Atención: Resetea entradas anteriores. ]]
function HParser:setStrIn(strIn)
    if(not strIn)then return; end
    self:reset();
    self.strIn = strIn;
    self:cleanIn();
    --self:update();
    self:parseLines()
end

--[[ limpia la cadena de entrada y la guarda en "strClean", además, desde
  * ésta, crea el array de lineas de entrada "linesIn" (limpias). ]]
function HParser:cleanIn()
    self.strClean, self.summary.comments = Utils.codeClean(self.strIn)
    --self.linesIn = self.strClean:split("\n")
    self.linesIn = Utils.gsplitTable(self.strClean, "\n")
    print("strIn->nlines: " .. #self.linesIn)
end

--[[ actualiza parseando las líneas de entrada
function HParser:update()
    --self:parseLines()
end ]]

--detectMnemonics(line: string) {}

--[[ comprueba si existe una dirección asignada a alguna variable en la tabla de símbolos "tSymbols" ]]
function HParser:exitsSymbolDir(dir)
    local result = false;
    for el in tSymbols do
        if (dir == tSymbols[el]) then
            result = true;
            break;
        end
    end
    return result;
end
--[[ obtiene la siguiente dirección no asignada libre para variables en la tabla de símbolos
    * (por encima de 16 y por debajo de 16385)
    * Retornará -1 si no se encuentran huecos libres (TOTALMENTE IMPROBABLE) ]]
function HParser:getNextSymbolDir()
    local index = -1; --sólo por encima de 16 y por debajo de 16385
    for i = 16, tSymbols["SCREEN"] do
        if (not self:exitsSymbolDir(i)) then
            -- libre por encima de 16
            index = i;
            break;
        end
    end
    return index;
end

--[[ busca en la tabla de símbolos "tSymbols" y retorna el valor de su dirección.
    * Si no lo encuentra lo añade y retorna su dirección añadida.
    * Si es un número, diréctamente lo retorna como tal.
    * PUEDE MODIFICAR LA TABLA DE SÍMBOLOS (de echo, de eso se trata)
    *
    * ATENCIÓN: LANZARÁ ERROR SI NO QUEDAN HUECOS LIBRES EN LA MEMORIA PARA VARIABLES
    * (esto no sucederá a no ser que se definan unas 16369 variables y etiquetas, BESTIAL!)
    ]]
function HParser:toSymbol(symbol)
    local _debug = false
    -- si es un número positivo lo retorna, sinó n=NaN
    local n = tonumber(symbol) --(/@[0-9]+/); //comprueba si el símbolo es numérico
    if(_debug)then print("A: ", symbol, n) end
    if (n and n >= 0) then
        -- si n=NaN no pasa la prueba
        return n;
    end
    -- si no es un número
    local s = tSymbols[symbol]
    --print("A: ", symbol, n, tSymbols[symbol])
    if (s == nil) then
        --[[
        self:nextSymbolDir = self:getNextSymbolDir();
        if (self:nextSymbolDir == -1) {
            throw new Error("REPLETE SYMBOLS TABLE!");
        }
        ]]
        tSymbols[symbol] = self.nextSymbolDir;
        self.nextSymbolDir = self.nextSymbolDir + 1;
    end
    --print("A: ", symbol, n, tSymbols[symbol])
    --utiliza su valor numérico
    return tSymbols[symbol];
end

--[[
    * Para instrucciones tipo "C"
    * Retorna el dest-comp-jump (si existe) codificado en binario según las tablas "tDest, tComp y tJump".  
    * Codifica cada mnemónico a su correspondiente representación binaria.
    * Si no existe se retorna "000" que es "null"; osea, que el valor no se almacena, ni se calcula, ni se salta.
    ]]
function HParser:codifyDestCompJump(line)
    local _debug = false
    local p = {
        dest = "000", -- 000 = null (NO SE ALMACENA EN NINGÚN SITIO)
        comp = "00101010", -- no realiza ninguna operación (0) ??
        jump = "000", -- no salta
    };
    if(_debug)then print("C: ", line) end
    --local parts = line:split("=");
    local parts = Utils.gsplitTable(line, "=");
    if (#parts == 1) then
        --NO DEST .. 0;JUMP
        --local parts2 = parts[0].split(";");
        local parts2 = Utils.gsplitTable(parts[1], ";");
        p.comp = tComp[parts2[1]];
        if(_debug)then print(parts2[1], p.comp) end
        if (#parts2 > 1) then
            --JUMP
            p.jump = tJump[parts2[2]];
            if(_debug)then print(parts2[2], p.jump) end
        end
    elseif (#parts > 1) then
        --DEST: M=D .. M=D;JUMP
        p.dest = tDest[parts[1]];
        if(_debug)then print(parts[1], p.dest) end
        --local parts2 = parts[1].split(";");
        local parts2 = Utils.gsplitTable(parts[2], ";");
        p.comp = tComp[parts2[1]];
        if(_debug)then print(parts2[1], p.comp) end
        if (#parts2 > 1) then
            --JUMP
            p.jump = tJump[parts2[2]];
            if(_debug)then print(parts2[2], p.jump) end
        end
    end
    return p;
end

--[[ Analizador de código "HACK-ASM" hacia "HACK-BINARY".
    * Parsea la entrada "linesIn" con código máquina simbólico (HACK) y guarda la 
    * salida "linesOut" con código máquina (HACK).  
    * La entrada se supone que es código válido en formato "HACK-ASM", los pasos que realiza son:
    * - 1./ Busca todas las etiquetas (LABEL) "L" y las guarda como símbolos almacenando su  número de línea.  
    *   Si el programa tiene más de una etiqueta con el mismo nombre, el resultado es impredecible.
    * - 2./ Ahora busca resultados de símbolos existentes en "tSymbols" o asigna nuevas variables a la tabla de símbolos. 
    *   Con las direcciones retornadas se crea una línea de salida binaria. 
    * - 3./ Se identifican tipos de instrucciones ("A", "L" ó "C") y se traducen a su correspondencia binaria.  
    * 
    * Con cada línea obtenida a la salida puede construirse perféctamente un "HRegister" para la interfaz gráfica.
    ]]
function HParser:parseLines()
    -- 1.
    -- primero busca todas las etiquetas (LABEL) "L" y las guarda como símbolos almacenando su
    -- número de línea. También las marca para anularlas posteriormente.  
    -- Si el programa tiene más de una etiqueta con el mismo nombre, el resultado es impredecible
    local numLabels = 1; -- lua trabaja con tablas de índice 1, en otros lenguages poner "0"
    local arrNils = {}
    for index, line in ipairs(self.linesIn) do
        if(not line or line == "\n") then
        else
            local t = Utils.instructionType(line); --obtiene el tipo de comando
            --print(line, t)
            if (t == "L") then
                --let s:number = self:toSymbol(line.replace("(", "").replace(")", "")); //eliminamos "(" y ")"
                --hay que restarle el número de etiquetas creadas porque son líneas que se van a eliminar
                local n = index - numLabels;
                tSymbols[line:gsub("%(", ""):gsub("%)", "")] = n;
                --print(Utils.dump(tSymbols))
                table.insert(arrNils, index); --marca la línea para anularla
                numLabels = numLabels + 1;
                self.summary.L = self.summary.L + 1
            end
        end
    end
    -- 2.
    -- limpia las marcadas para anular
    --print(Utils.dump(self.linesIn))
    --for index, value in ipairs(arrNils) do
    for i = #arrNils, 1, -1 do -- tiene que ser del final al inicio
        table.remove(self.linesIn, arrNils[i])
    end
    --print(Utils.dump(self.linesIn))
    -- 3.
    -- ahora busca resultados de símbolos existentes en "tSymbols" o asigna nuevas variables
    -- a la tabla de símbolos.
    -- con las direcciones retornadas se crea una línea de salida binaria
    for index, line in ipairs(self.linesIn) do
        if(not line or line == "\n") then
        else
            local t = Utils.instructionType(line); --obtiene el tipo de comando
            -- no debería quedar ninguna etiqueta "L", ya se ha trabajado con ellas asignándoles memoria
            if (t == "L") then
            elseif (t == "A") then
                -- retornamos el valor decimal de la dirección del símbolo
                --let s = self:toSymbol(line.substring(1)); --eliminamos @
                local s = self:toSymbol(line:gsub("@", "")); --eliminamos @
                --console.log(s, "@" + s, _pad(s, 16, 2));
                line = "@" .. s;
                --_self:linesIn[index] = "@" + s;
                self.linesIn[index] = line     -- actualiza el array original "linesIn"
            --print("A. ", s, Utils.pad(s, 16, 2), Utils.pad(Utils.toBinary(s), 16, 2))
                table.insert(self.linesOut, Utils.toBin(s, 16)) --Utils.pad(s, 16, 2)
                self.summary.A = self.summary.A + 1
            elseif (t == "C") then
                --dest=comp;jump
                local p = self:codifyDestCompJump(line);
                if(p and p.dest and p.comp and p.jump)then
                    local n = "111" .. p.comp .. p.dest .. p.jump
                    --self.linesOut.push(Utils.pad(tonumber(n, 2) .. "", 16, 2));
                    --print("C. ", n)--, Utils.pad(tonumber(n, 2)))
                    table.insert(self.linesOut, n) --Utils.toBin(n, 16)) --Utils.pad(n, 16, 2)
                    self.summary.C = self.summary.C + 1
                end
            end
        end
    end

    self.strOut = table.concat(self.linesOut, "\n");
    --[[for index, value in ipairs(self.linesOut) do
        table.insert(self.regsOut, HReg(value, { id = index, x = 40, y = 40 + (index * 10), color = hp_color }))
    end]]
local _, nLinesOr = self.strIn:gsub("\n", "")
--local _, nLinesClean = self.strClean:gsub("\n", "")
table.insert(self.summary.info, string.format("INSTRUCTIONS (type): L=%d, A=%d, C=%d\nLINES: in=%d, clean:%d, hack:%d, %s", self.summary.L, self.summary.A, self.summary.C, nLinesOr, #self.linesIn, #self.linesOut, Utils.tablePairsTostring(self.summary.comments, ", ")))
--Utils.dump(self.summary.comments))
    --print(self.summary.info)
end

function HParser:toString()
    return self.strClean;
end


return HParser
