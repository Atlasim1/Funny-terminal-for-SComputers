---@diagnostic disable: deprecated, unused-function -- ignore this
-- AtlasOS v1.1
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

local function sleep(ticks)
    local currentTime = 0
    local newTime = getUptime() + ticks
    while currentTime < newTime do
        currentTime = getUptime()
    end
end

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

----- Initialisation -----
Terminal = getComponents("terminal")[1]
local consoleEcho = true
ReadyPrompt = "#ffffffReady."
BootPrompt = "#ffff00AtlasOS v1.1"
Data = {AUTOEXEC = {}, SETTINGS = {}}

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
        CON_OUTPUT(COLORS.RED.."Bad Command")
    end,
    cleardata = function (CON_INPUT)
        setData("")
        CON_OUTPUT("Cleared all userdata")
    end,
    outdata = function (CON_INPUT)
        CON_OUTPUT(getData())
    end,
    setdata = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "setdata ","")
        setData(args)
    end,
    adddata = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "adddata ","")
        setData(getData().."\n"..args.."\n")
    end,
    reboot = function (CON_INPUT)
        reboot()
    end,
    cls = function (CON_INPUT)
        Terminal.clear()
    end,
    help = function (CON_INPUT)
        CON_OUTPUT("List Of Commands")
        for k,_ in pairs(CON_COMMANDS) do
            CON_OUTPUT(k)
        end
    end,
    luarun = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "luarun ","")
        loadstring(args)()
    end
}

function callback_error(err) -- Error Handling
    onError(err)
end
---@diagnostic disable-next-line: lowercase-global
function onError(err) -- Error Handling
    Terminal.write(COLORS.ORANGE.."Lua Error : "..err..LINE_END.."Computer will restart in 15 seconds")
    sleep(600)
    reboot()
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
        if starts_with(CON_INPUT.." ",command.." ") then
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
    elseif maindisk.hasFile("autoexec.lua") then
        local filedata = maindisk.readFile("autoexec.lua")
        loadstring(filedata)()
    end
---@diagnostic disable-next-line: param-type-mismatch
    loadstring(getData())()
    if Data and Data.AUTOEXEC then
        for k,v in pairs(Data.AUTOEXEC) do
            Data.AUTOEXEC[k]()
        end
    end
end

----- MAIN CODE -----

checkBootFile()
-- Initialize Terminal 
Terminal.clear()
Terminal.write(BootPrompt.. LINE_END)
Terminal.write(ReadyPrompt..LINE_END)

function callback_loop()
    CON_INPUT = Terminal.read()
    if CON_INPUT then
        if consoleEcho then
            Terminal.write(COLORS.GREEN.."> "..CON_INPUT..LINE_END)
        end
        parseCommand(CON_INPUT)
        Terminal.write(ReadyPrompt..LINE_END)
    end
    if _endtick then
        Terminal.clear()
    end
end

