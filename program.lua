---@diagnostic disable: deprecated, unused-function -- ignore this
-- AtlasOS v1.0
-- Made to run with scripatble computers
--[[
Notes
- External programs get run as functions with all of the globals in this file being available.
]]

----- Utils -----
COLORS = {
    ORANGE = "#ff8800",
    RED = "#ff0000",
    BLUE = "#0000ff",
    GREEN = "#00ff00",
}

LINE_END = string.char(13)

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

----- Initialisation -----
Terminal = getComponents("terminal")[1]
local consoleEcho = true

----- Functions / Globals -----
function CON_OUTPUT(data) -- Global to output to terminal
    Terminal.write("#ffffff"..data..LINE_END)
end

-- when a command is input into the terminal, the program runs the corresponding function from this table
-- Since this is a global, you can expand the table from external programs
CON_COMMANDS = { -- List of terminal commands
    echo = function (CON_INPUT)
        if CON_INPUT == "echo on" then
            CON_OUTPUT("Echo is on")
            consoleEcho = true
        elseif CON_INPUT == "echo off" then
            CON_OUTPUT("Echo is off")
            consoleEcho = false
        end
    end,
    lsf = function (CON_INPUT)
        local maindisk = getComponents("disk")[1]
        local filedata = maindisk.readFile("main.lua")
        loadstring(filedata)()
    end,
    any = function (CON_INPUT)
        CON_OUTPUT(COLORS.RED.."Bad Command Or File Name")
    end
}

function callback_error(err) -- Error Handling
    onError(err)
end
---@diagnostic disable-next-line: lowercase-global
function onError(err) -- Error Handling
    if err == "NO_AVAILABLE_DISK" then
        Terminal.write(COLORS.RED.."FATAL : No bootable medium found\nYou can fix this by connecting a bootable storage medium\nError Code : "..err..LINE_END)
    end
    Terminal.write(COLORS.ORANGE.."Lua Error : "..err..LINE_END)
    return
end

function LoadDisks() -- Used to load all disks, can also be used to "refresh" disks
    local disks = getComponents("disk")
    DISK_COUNT = #disks
    for k,_ in pairs(disks) do
        loadstring("Disk"..k.."= getComponents(\"disk\")["..k.."]")() -- God forgive me, for i have sinned.
    end
end

local function parseCommand(CON_INPUT) -- Parse command after it is input
    local ranCommand = false
    for command, commanddata in pairs(CON_COMMANDS) do
        if starts_with(CON_INPUT,command.." ") then
            commanddata(CON_INPUT)
            ranCommand = true
            break
        end
    end
    if ranCommand == false then
        CON_COMMANDS.any(CON_INPUT)
    end
end

local function checkBootFile() -- Check for boot file at boot
    local maindisk = getComponents("disk")[1]
    if maindisk.hasFile("boot.lua") then
        local filedata = maindisk.readFile("boot.lua")
        loadstring(filedata)()
    end
end

----- MAIN CODE -----
checkBootFile()
-- Initialize Terminal 
Terminal.clear()
Terminal.write("#ffff00AtlasOS v1.0".. LINE_END)
Terminal.write("#ffffffReady."..LINE_END)

function callback_loop()
    CON_INPUT = Terminal.read()
    if CON_INPUT then
        if consoleEcho then
            Terminal.write(COLORS.GREEN.."> "..CON_INPUT..LINE_END)
        end
        parseCommand(CON_INPUT)
        Terminal.write("#ffffffReady."..LINE_END)
    end
end

