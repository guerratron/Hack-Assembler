if (_G["texts"]) then
    return _G["texts"]
end

local texts = {
        README = {
            ES = {
            {
                title = " · INTRO: ",
                lines = {
                    'Ensamblador en lenguage máquina HACK-ASM, tanto de forma mnemónica ',
                    '(simbólica) como binaria, es un Ensamblador de archivos .asm de tipo HACK ',
                    'con una interfaz mini-REPL. ',
                    'Esta app convierte código HACK-ASM a binario HACK-BIN (con formato de ',
                    'texto plano) para poder reproducirse en la máquina virtual “Hack Computer”.',
                    'Digamos que es el contenedor para el ensamblador, ya que además puede ',
                    'realizar otras tareas (y más que se integrarán en futuras versiones) como ',
                    'para considerarse una herramienta con múltiples usos. ',
                    'La app permite parsear un archivo ‘*.asm’ (con mnemónicos Hack) y ',
                    'convertirlo a ‘*.hack’ (binario en texto) de forma visualmente atractiva. ',
                    'También permite la comparación del binario optenido con un segundo archivo ',
                    '‘*.hack’ mostrando los resultados en la zona de mensajes inferior. ',
                    '',
                    'Tiene añadidos como poder obtener un código ASM final mucho más limpio y ',
                    'puro donde se sustituyen valores de variables y labels por sus referencias ',
                    'directas en el mapa de memoria.',
                    "",
                }
            },
            {
                title = " · ANTECEDENTES: ",
                lines = {
                    '📋 HackAssembler: ',
                    'Este es el resultado del completísimo curso NAND2Tetris donde terminas ',
                    'construyendo, de forma ideal, un PC partiendo de los elementos más básicos ',
                    'como son las puertas lógicas Nand hasta elementos más complicados como ',
                    'estructuras de registros y memorias, ALU, … hasta llegar a un mini-VC con ',
                    'todo el hardware simulado mediante software.  ',
                    'Precísamente este ensamblador es la práctica del tema ‘6. Assembler’ donde ',
                    'instan a construir tu propio ensamblador para lenguage máquina ASM-HACK-BIN ',
                    'escrito en un lenguage de tu elección. ',
                    'En este caso he elegido el lenguage LUA (utilizando el framework LÖVE), ',
                    'aunque también he creado otra versión más visual en javascript (pero ',
                    'infinitamente más lenta).  ',
                    'Esta versión se ha basado en otra anterior orientada a navegadores web ',
                    'codificada en javascript "HackAssembler.js v1.0.1".',
                    "",
                }
            },
            {
                title = " · CARACTERÍSTICAS: ",
                lines = {
                    '⌨️ La parte más original de la APP, a mi parecer, es precísamente lo que no ',
                    'es “ensamblador”, quiero decir la forma de llegar al ensamblador a través ',
                    'de una pantalla tipo consola o terminal ⌨️ donde se permiten introducir ',
                    'comandos como asm para la ejecución de este ensamblador, u otros como ',
                    '<< help, dir, cmd, ver, exec, help, … >>.  ',
                    'Así que tenemos una app tipo REPL, con temática retro-futurista, con aspecto ',
                    'de app terminal-8-bits basado en consola tipo MS-Dos, con altas prestaciones ',
                    'y colores neón (casi cyberpunk), … y encima programado en LÖVE (Lua 5.1), …  ',
                    '',
                    '¡ QUE MÁS SE PUEDE PEDIR !, el disfrute está asegurado para todos los que ',
                    'añoren los años 80’s.  ',
                    '',
                    'P.D: La APP sólo se ha podido probar en una máquina potente moderna ',
                    '(i7-64bits, 12Gb RAM, 2 Tb HDD) nada retro-futurista, y consume entre 3 y ',
                    '30 Mb de memoria (dependiendo del tiempo de uso y la cantidad de comandos ',
                    'ejecutados).',
                    "",
                }
            },
            {
                title = " · COMANDOS ",
                lines = {
                    "Los comandos más relevantes son los siguientes: ",
                    "",
                    '  - asm: Pantalla para el Ensamblador donde comprobamos visualmente el ',
                    'código ASM-HACK y podemos realizar comparación con otros archivos Hack.',
                    "  - cmd : muestra el command.com de esta consola.",
                    "  - ver : versión del command.com",
                    "  - vol : el volúmen (ficticio), algo como 'C:>'",
                    "  - hello : algunos créditos",
                    --"  - ? : sorpresa !",
                    "  - pause : pausa la consola hasta pulsar una tecla cualquiera.",
                    "  - del : borrar ..",
                    "  - exit : sale guardando todos los avances.",
                    "  - escape : sale SIN guardar.",
                    "  - cls : borra la consola.",
                    --"  - dir : muestra un listado de archivos de ejemplo.",
                    "  - help : muestra esta ayuda.",
                    "  - readme : visualiza el archivo Readme.md (MUY INTERESANTE)",
                    "  - intro : la ventana de introducción (MUY INTERESANTE)",
                    "  - borders : habilita / deshabilita los bordes en las ventanas.",
                    "  - procss : cuenta los procesadores del sistema",
                    "  - exec : comando MUY POTENTE. Muestra el 'cmd' del S.O.",
                    "  - pwinfo : información de la batería",
                    "  - date : fecha del sistema",
                    "  - os : sistema operativo [S.O.]",
                    "  - clipb : muestra el último texto copiado en el clipboard",
                    "  - google : abre el navegador",
                    "  - nand2tetris : abre la página web www.nand2tetris.org",
                    "  - res : permite cambiar la resolución de la pantalla del juego."
                }
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "",
                lines = { "* Los archivos de la app se guardan en la carpeta de salvado del S.O." }
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "                   'Hack-Assembler'",
                lines = { "", "                 .. by GuerraTron24 <dinertron@gmail.com> .." }
            }
        },
        EN = {
            {
                title = " · INTRO: ",
                lines = {
                    'HACK-ASM machine language assembler, both mnemonic (symbolic) ',
                    'and binary, is a HACK-type .asm file assembler with a ',
                    'mini-REPL interface. ',
                    'This app converts HACK-ASM code to HACK-BIN binary (in plain ',
                    'text format) so it can be played on the “Hack Computer” virtual ',
                    'machine.',
                    'Let\'s say it is the container for the assembler, since it can also perform other tasks (and more that will be integrated in future versions) such as ', 'to be considered a tool with multiple uses. ', 'The app allows you to parse a ‘*.asm’ file (with Hack mnemonics) and ', 'convert it to ‘*.hack’ (binary in text) in a visually attractive way. ',
                    'It also allows the comparison of the obtained binary with a second file ',
                    '‘*.hack’ showing the results in the lower message area. ',
                    '',
                    'It has additions such as being able to obtain a much cleaner and purer final ASM code where variable and label values ​​are replaced by their direct references ',
                    'in the memory map.',
                    "",
                }
            },
            {
                title = " · BACKGROUND: ",
                lines = {
                    '📋 HackAssembler: ',
                    'This is the result of the very complete NAND2Tetris course where you end up ',
                    'building, ideally, a PC starting from the most basic elements ',
                    'such as Nand logic gates to more complicated elements such as ',
                    'register and memory structures, ALU, … until reaching a mini-VC with ',
                    'all the hardware simulated by software. ',
                    'Precisely this assembler is the practice of the topic ‘6. Assembler’ where ',
                    'they urge you to build your own assembler for the ASM-HACK-BIN machine language ',
                    'written in a language of your choice. ',
                    'In this case I have chosen the LUA language (using the LÖVE framework), ',
                    'although I have also created another more visual version in javascript (but ',
                    'infinitely slower). ',
                    'This version is based on a previous version aimed at web browsers.',
                    'coded in javascript "HackAssembler.js v1.0.1".',
                    "",
                }
            },
            {
                title = " · FEATURES: ",
                lines = {
                    '⌨️ The most original part of the APP, in my opinion, is precisely what is not ',
                    'an “assembler”, I mean the way to get to the assembler through ',
                    'a console or terminal type screen ⌨️ where you can enter ',
                    'commands like asm to run this assembler, or others like ',
                    '<< help, dir, cmd, ver, exec, help, … >>. ',
                    'So we have a REPL type app, with a retro-futuristic theme, with the look of ',
                    'an 8-bit terminal app based on an MS-Dos type console, with high performance ',
                    'and neon colors (almost cyberpunk), … and on top of that programmed in LÖVE (Lua 5.1), … ',
                    '',
                    'WHAT MORE COULD YOU ASK FOR! Enjoyment is guaranteed for all those who ',
                    'long for the 80s. ',
                    '',
                    'P.S.: The APP has only been tested on a modern, powerful machine ',
                    '(i7-64bits, 12Gb RAM, 2 Tb HDD) not at all retro-futuristic, and it consumes between 3 and ',
                    '30 Mb of memory (depending on the time of use and the number of commands ',
                    'executed).',
                    "",
                }
            },
            {
                title = " · COMMANDS ",
                lines = {
                    "The most relevant commands are the following: ",
                    "",
                    ' - asm: Screen for the Assembler where we can visually check the ',
                    'ASM-HACK code and we can make a comparison with other Hack files.',
                    " - cmd : shows the command.com of this console.",
                    " - ver : version of the command.com",
                    " - vol : the volume (fictitious), something like 'C:>'",
                    " - hello : some credits",
                    --" - ? : surprise !",
                    " - pause : pauses the console until any key is pressed.",
                    " - del : delete ..",
                    " - exit : exits saving all progress.",
                    " - escape : exits WITHOUT saving.",
                    " - cls : deletes the console.",
                    --" - dir : shows a list of sample files.",
                    " - help : shows this help.",
                    " - readme : displays the Readme.md file (VERY INTERESTING)",
                    " - intro : the introduction window (VERY INTERESTING)",
                    " - intro : the introduction window (VERY INTERESTING)",
                    " - borders : enable/disable borders on windows.",
                    " - procss : count system processors",
                    " - exec : VERY POWERFUL command. Displays the OS 'cmd'",
                    " - pwinfo : battery information",
                    " - date : system date",
                    " - os : operating system [OS]",
                    " - clipb : display the last text copied to the clipboard",
                    " - google : open the browser",
                    " - nand2tetris : open the website www.nand2tetris.org",
                    " - res : allows you to change the game screen resolution."
                }
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "",
                lines = { "* App files are saved in the OS save folder." }
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "                   'Hack-Assembler'",
                lines = { "", "                 .. by GuerraTron24 <dinertron@gmail.com> .." }
            }
        }
    },

    HELP = {
        ES = {
            {
                title = " · INTRO: ",
                lines = {
                    'Ensamblador en lenguage máquina HACK-ASM, tanto de forma mnemónica ',
                    '(simbólica) como binaria, es un Ensamblador de archivos .asm de tipo HACK ',
                    'con una interfaz mini-REPL. ',
                    'La app permite parsear un archivo ‘*.asm’ (con mnemónicos Hack) y ',
                    'convertirlo a ‘*.hack’ (binario en texto) de forma visualmente atractiva. ',
                    'También permite la comparación del binario optenido con un segundo archivo ',
                    '‘*.hack’ mostrando los resultados en la zona de mensajes inferior. ',
                    '',
                    'Tiene añadidos como poder obtener un código ASM final mucho más limpio y ',
                    'puro donde se sustituyen valores de variables y labels por sus referencias ',
                    'directas en el mapa de memoria.',
                    "",
                }
            },
            {
                title = " · USO: ",
                lines = {
                    'La herramienta se ha diseñado para dos formas distintas de utilización: ',
                    'sin Interfaz Gráfica o con UI. ',
                    ' - 1/ ',
                    'La APP puede ejecutarse en la "línea de comandos" pasándole como argumento ',
                    'el archivo "ruta/*.asm" (con su ruta relativa al ejecutable) y la app lanzará ',
                    'el ensamblador de forma transparente, realizando las labores de parseado, ',
                    'comparación y guardado de resultados. ',
                    '',
                    ' - 2/ ',
                    'También puede ejecutarse sin parámetros mostrando una emulación de "terminal", ',
                    'digamos un "mini-REPL", donde admite ciertos comandos de los cuales el más ',
                    'importante es "asm" que permite las mismas operaciones anteriores pero en ',
                    'formato "visual" mucho más atractivo. ',
                    '',
                    'La APP guardará además del binario calculado "*.hack", un registro "*.log" y ',
                    'otros como "*.asm" mejorados donde se reemplazan "variables y etiquetas" ',
                    'por sus valores en el mapa de memoria.',
                    '',
                    ' * IMPORTANTE: ',
                    '   ---------- ',
                    'Todos los archivos se guardarán forzosamente en el directorio de "salvado" ',
                    'que es dependiente del S.O., por ejemplo en Windows puede ser algo como: ',
                    '<<C:\\Users\\my_user_name\\AppData\\Roaming\\LOVE\\HackAssembler\\samples>>',
                    "",
                }
            },
            {
                title = " · COMANDOS ",
                lines = {
                    "Los comandos más relevantes son los siguientes: ",
                    "",
                    '  - asm. Pantalla para el Ensamblador donde comprobamos visualmente el ',
                    'código ASM-HACK y podemos realizar comparación con otros archivos Hack.',
                    "  - cmd : muestra el command.com de esta consola.",
                    "  - ver : versión del command.com",
                    "  - vol : el volúmen (ficticio), algo como 'C:>'",
                    "  - hello : algunos créditos",
                    --"  - ? : sorpresa !",
                    "  - pause : pausa la consola hasta pulsar una tecla cualquiera.",
                    "  - del : borrar ..",
                    "  - exit : sale guardando todos los avances.",
                    "  - escape : sale SIN guardar.",
                    "  - cls : borra la consola.",
                    --"  - dir : muestra un listado de archivos de ejemplo.",
                    "  - help : muestra esta ayuda.",
                    "  - readme : visualiza el archivo Readme.md (MUY INTERESANTE)",
                    "  - intro : la ventana de introducción (MUY INTERESANTE)",
                    "  - borders : habilita / deshabilita los bordes en las ventanas.",
                    "  - procss : cuenta los procesadores del sistema",
                    "  - exec : comando MUY POTENTE. Muestra el 'cmd' del S.O.",
                    "  - pwinfo : información de la batería",
                    "  - date : fecha del sistema",
                    "  - os : sistema operativo [S.O.]",
                    "  - clipb : muestra el último texto copiado en el clipboard",
                    "  - google : abre el navegador",
                    "  - nand2tetris : abre la página web www.nand2tetris.org",
                    "  - res : permite cambiar la resolución de la pantalla del juego."
                }
            },
            {
                title = " · TECLAS ESPECIALES: ",
                lines = {
                    "Aparte de los comandos reconocidos (más de 20), existen ciertas teclas ",
                    "especiales para la interacción con el usuario. Algunas actúan como ",
                    "comandos invisibles, otras como teclas de dirección, ... También el  ",
                    "ratón se permite en ciertas pantallas para seleccionar objetos o pulsar ",
                    "botones.",
                    "Por regla general, las teclas sensibles actúan de la siguiente manera: ",
                    "",
                    "  - F1 = Captura instantánea de consumo de recursos en depuración",
                    "  - F2 = Cierra la Room actual y regresa a la Console (sin guardar ",
                    "avances)",
                    "  - F5 = Aceptar-Exit, Regresa a Console o si ya está en Console sale ",
                    "del juego",
                    "  - escape = Cancelar, Regresa al menú principal Console (botón 'CANCELAR')",
                    "si está en Console SALE SIN GUARDAR.",
                    "  - backspace = borra caracteres en campos de entrada de texto (En ",
                    "Console-InputLineModule)",
                    "  - enter [return] = Acepta texto en campos de entrada (En Console-",
                    "InputLineModule), en otras pantallas es el botón 'ACEPTAR'",
                    "  - [+, -] = Zoom (in-out) en Console, y otras",
                    "  - up-down = Desplazador en los Text-Area (primero hay que situarse encima)",
                    '.. y en algunas pantallas (esta misma)',
                    "  - ... = Otras posibles teclas se transmiten a través de 'love.textinput'"
                }
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "",
                lines = { "* Los archivos de la app se guardan en la carpeta de salvado del S.O." }
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "                   'Hack-Assembler'",
                lines = { "", "                 .. by GuerraTron24 <dinertron@gmail.com> .." }
            }
        },
        EN = {
            {
                title = " · INTRO: ",
                lines = {
                    'HACK-ASM machine language assembler, both mnemonic (symbolic) and ',
                    'binary, is a HACK-type .asm file assembler with a mini-REPL interface. ',
                    'The app allows you to parse a ‘*.asm’ file (with Hack mnemonics) and ',
                    'convert it to a ‘*.hack’ (binary text) in a visually attractive way. ',
                    'It also allows the comparison of the obtained binary with a second ‘*.hack’ ',
                    'file, showing the results in the lower message area. ',
                    '',
                    'It has additions such as being able to obtain a much cleaner and purer ',
                    'final ASM code where variable and label values ​​are replaced by their ',
                    'direct references in the memory map.',
                    "",
                }
            },
            {
                title = " · USE: ",
                lines = {
                    'The tool has been designed for two different ways of use: ',
                    'without a Graphical Interface or with UI. ',
                    ' - 1/ ',
                    'The APP can be executed in the "command line" passing as an argument the ',
                    'file "path/*.asm" (with its path relative to the executable) and the app will ',
                    'launch the assembler transparently, performing the tasks of parsing, ',
                    'comparing and saving results. ',
                    '',
                    ' - 2/ ',
                    'It can also be executed without parameters showing a "terminal" emulation, ',
                    'let\'s say a "mini-REPL", where it admits certain commands of which the most ',
                    'important is "asm" that allows the same previous operations but in a much ',
                    'more attractive "visual" format. ',
                    '',
                    'The APP will save, in addition to the calculated binary "*.hack", a "*.log" ',
                    'log and others such as "*.asm" improved where "variables and labels" are ',
                    'replaced by their values ​​in the memory map.',
                    '',
                    ' * IMPORTANT: ',
                    '   --------- ',
                    'All files will be forcibly saved in the "save" directory ',
                    'which is OS dependent, for example in Windows it can be something like: ',
                    '<<C:\\Users\\my_user_name\\AppData\\Roaming\\LOVE\\HackAssembler\\samples>>',
                    "",
                }
            },
            {
                title = " · COMMANDS ",
                lines = {
                    "The most relevant commands are the following: ",
                    "",
                    ' - asm: Screen for the Assembler where we visually check the ',
                    'ASM-HACK code and we can make a comparison with other Hack files.',
                    " - cmd : shows the command.com of this console.",
                    " - ver : version of the command.com",
                    " - vol : the volume (fictitious), something like 'C:>'",
                    " - hello : some credits",
                    --" - ? : surprise !",
                    " - pause : pauses the console until any key is pressed.",
                    " - del : delete ..",
                    " - exit : exits saving all progress.",
                    " - escape : exits WITHOUT saving.",
                    " - cls : deletes the console.",
                    --" - dir : shows a list of example files.",
                    " - help : shows this help.",
                    " - readme : displays the Readme.md file (VERY INTERESTING)",
                    " - intro : the intro window (VERY INTERESTING)",
                    " - borders : enable/disable borders on windows.",
                    " - procss : count the processors on the system",
                    " - exec : VERY POWERFUL command. Shows the 'cmd' of the OS.",
                    " - pwinfo : battery information",
                    " - date : system date",
                    " - os : operating system [OS]",
                    " - clipb : show the last text copied to the clipboard",
                    " - google : open the browser",
                    " - nand2tetris : open the website www.nand2tetris.org",
                    " - res : allows you to change the game screen resolution."
                }
            },
            {
                title = " · SPECIAL KEYS: ",
                lines = {
                    'Apart from the recognized commands (more than 20), there are certain ',
                    'special keys for user interaction. Some act as invisible commands, others ',
                    'as arrow keys, ... Also the mouse is allowed in certain screens to select ',
                    'objects or press buttons.',
                    "As a rule, the sensitive keys act as follows:",
                    "",
                    "- F1 = Snapshot of resource consumption in debugging",
                    '- F2 = Close the current Room and return to the Console (without saving) ',
                    '       progresses',
                    '- F5 = OK-Exit, Return to Console or if you are already in Console exit ',
                    '       the game',
                    "- escape = Cancel, Return to the main Console menu ('CANCEL' button),",
                    "           if you are in Console EXIT WITHOUT SAVING.",
                    '- backspace = delete characters in text input fields (In Console-',
                    '              InputLineModule)',
                    " - enter [return] = Accepts text in input fields (in Console-",
                    "              InputLineModule), in other screens it is the 'OK' button",
                    " - [+, -] = Zoom (in-out) in Console, and others",
                    " - up-down = Scroller in Text-Areas (you have to stand on it first)",
                    '.. and in some screens (this one)',
                    " - ... = Other possible keys are transmitted through 'love.textinput'"
                }
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "",
                lines = { "* App files are saved in the OS save folder." }
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "",
                lines = {}
            },
            {
                title = "                   'Hack-Assembler'",
                lines = { "", "                 .. by GuerraTron24 <dinertron@gmail.com> .." }
            }
        }
    },

    SAVE_AND_EXIT = {
        ES = {
            {
                title = "guardar y salir",
                lines = {""}
            }
        },
        EN = {
            {
                title = "save and exit",
                lines = { "" }
            }
        }
    }
}

return texts

--[[
return {
    readme = texts.README, -- [LANG]
}]]