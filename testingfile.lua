---@diagnostic disable: deprecated
-- File Related Commands Plugin

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

CurrentDisk = "Disk1"
-- Define New Commands
-- TODO : 
-- del
-- rmdir
-- I/O Commands
-- Propreties Commands


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

