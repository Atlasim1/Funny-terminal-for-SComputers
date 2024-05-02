-- AtlasOS v1.0
-- Made to run with scripatble computers
--[[
Notes
- External programs get ran as functions with all of the globals in this file being available.


]]
local newFile = [[
    ---@diagnostic disable: deprecated
    -- File Related Commands Plugin
    
    local function starts_with(str, start)
        return str:sub(1, #start) == start
    end
    
    CurrentDisk = "Disk1"
    -- Define New Commands
    local newCommands = {
        test = function (CON_INPUT)
            CON_OUTPUT("It Works!")
        end,
        selectdisk = function (CON_INPUT)
            local args = string.gsub(CON_INPUT, "selectdisk ","")
            if _G[args] then
                loadstring("CurrentDisk = \""..args.."\"")()
                CON_OUTPUT("Current Disk is now "..args)
            else
                CON_OUTPUT(COLORS.RED..args.." Is not an available Disk or does not exist")
            end
        end,
        listdisks = function (CON_INPUT)
            for k,v in pairs(_G) do
                if starts_with(k,"Disk") then
                    CON_OUTPUT(k)
                end
            end
        end,
        cd = function (CON_INPUT)
            local args = string.gsub(CON_INPUT, "cd ","")
            if _G[CurrentDisk].hasFolder(args) then
                _G[CurrentDisk].openFolder(args)
            else
                CON_OUTPUT(COLORS.RED..args.." Is not a Directory.")
            end
        end,
        dir = function (CON_INPUT)
            local folderlist = _G[CurrentDisk].getFolderList(_G[CurrentDisk].getCurrentPath())
            CON_OUTPUT(COLORS.BLUE..table.concat(folderlist, ", "))
            local filelist = _G[CurrentDisk].getFileList(_G[CurrentDisk].getCurrentPath())
            CON_OUTPUT(table.concat(filelist, ", "))
        end,
        mkdir = function (CON_INPUT)
            local args = string.gsub(CON_INPUT, "mkdir ","")
            _G[CurrentDisk].createFolder(args)
        end,
        pwd = function (CON_INPUT)
            local args = string.gsub(CON_INPUT, "pwd ","")
            CON_OUTPUT(_G[CurrentDisk].getCurrentPath())
        end
    }
    
    -- Append new commands
    for k,v in pairs(newCommands) do
        CON_COMMANDS[k] = v
    end
    CON_OUTPUT("Appended New Commands")
]]
---@diagnostic disable: deprecated, unused-function -- ignore this
--- UTILS : 
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

-- FUCTIONS, GLOBALS & INIT:

Terminal = getComponents("terminal")[1]
local consoleEcho = true

function CON_OUTPUT(data)
    Terminal.write("#ffffff"..data..LINE_END)
end
-----------------------------------
-- when a command is input into the terminal, the program runs the corresponding function from this table
-- Since this is a global, you can expand the table from external programs
CON_COMMANDS = {
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
        --local maindisk = getComponents("disk")[1]
        --local filedata = maindisk.readFile("main.lua")
        loadstring(newFile)()
    end,
    any = function (CON_INPUT)
        CON_OUTPUT(COLORS.RED.."Bad Command Or File Name")
    end
}
-----------------------------------
function callback_error(err)
    onError(err)
end

---@diagnostic disable-next-line: lowercase-global
function onError(err)
    if err == "NO_AVAILABLE_DISK" then
        Terminal.write(COLORS.RED.."FATAL : No bootable medium found\nYou can fix this by connecting a bootable storage medium\nError Code : "..err..LINE_END)
    end
    Terminal.write(COLORS.ORANGE.."Lua Error : "..err..LINE_END)
    return
end
-----------------------------------
function LoadDisks()
    local disks = getComponents("disk")
    DISK_COUNT = #disks
    for k,_ in pairs(disks) do
        loadstring("Disk"..k.."= getComponents(\"disk\")["..k.."]")() -- God forgive me, for i have sinned.
    end
end
-----------------------------------
local function parseCommand(CON_INPUT)
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
-----------------------------------
LoadDisks()
local display = getComponents("display")[1]
-----------------------------------
-- Main Loop
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

