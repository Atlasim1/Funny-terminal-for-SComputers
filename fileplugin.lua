---@diagnostic disable: deprecated
-- File Related Commands Plugin

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

LoadDisks()
CurrentDisk = "Disk1"

local newCommands = {
    installfilecommands = function (CON_INPUT)
        setData(getData().."Data.AUTOEXEC.fileplugin = function () \n BootPrompt = BootPrompt..\" +File v1\" local maindisk = getComponents(\"disk\")[1] local filedata = maindisk.readFile(\"main.lua\") loadstring(filedata)() end"
    )
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
        LoadDisks()
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
        local args = string.gsub(CON_INPUT.." ", "dir ","")
        if args ~= "" and _G[CurrentDisk].hasFolder(args) then
            args = string.gsub(args,"%s+$","") -- Remove Trailing whitespace added by other gsub
            local folderlist = _G[CurrentDisk].getFolderList(args)
            CON_OUTPUT(COLORS.BLUE..table.concat(folderlist, ", "))
            local filelist = _G[CurrentDisk].getFileList(args)
            CON_OUTPUT(table.concat(filelist, ", "))
        elseif  args ~= "" and not _G[CurrentDisk].hasFolder(args) then
            CON_OUTPUT(COLORS.RED..args.." is not a directory or does not exist")
        else
            local folderlist = _G[CurrentDisk].getFolderList(_G[CurrentDisk].getCurrentPath())
            CON_OUTPUT(COLORS.BLUE..table.concat(folderlist, ", "))
            local filelist = _G[CurrentDisk].getFileList(_G[CurrentDisk].getCurrentPath())
            CON_OUTPUT(table.concat(filelist, ", "))
        end
    end,
    mkdir = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "mkdir ","")
        if not _G[CurrentDisk].hasFolder(args) then
            _G[CurrentDisk].createFolder(args)
        else
            CON_OUTPUT(COLORS.RED.."Directory "..args.." Already exists")
        end
    end,
    pwd = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "pwd ","")
        CON_OUTPUT(_G[CurrentDisk].getCurrentPath())
    end,
    del = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "del ","")
        if _G[CurrentDisk].hasFile(args) then
            _G[CurrentDisk].deleteFile(args)
            CON_OUTPUT("Deleted file "..args)
        else
            CON_OUTPUT(COLORS.RED..args.." does not exist or is a directory")
        end
    end,
    rmdir = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "rmdir ","")
        if _G[CurrentDisk].hasFolder(args) then
            _G[CurrentDisk].deleteFolder(args)
            CON_OUTPUT("Deleted Folder "..args)
        else
            CON_OUTPUT(COLORS.RED..args.." does not exist or is not a directory")
        end
    end,
    diskusage = function (CON_INPUT)
        CON_OUTPUT(CurrentDisk.." Used size is : ".._G[CurrentDisk].getUsedSize())
    end,
    filesize = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "rmdir ","")
        if _G[CurrentDisk].hasFile(args) then
            CON_OUTPUT("File "..args.." uses ".._G[CurrentDisk].getFileSize(args))
        end
    end,
    outfile = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "outfile ","")
        if _G[CurrentDisk].hasFile(args) then
            local fileContents = _G[CurrentDisk].readFile(args)
            CON_OUTPUT("#aaaaaaContents of "..args..": ")
            CON_OUTPUT(fileContents.."\n")
        else
            CON_OUTPUT(colors.RED.."Bad File Name")
        end
    end,
    newfile = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "newfile ","")
        if not _G[CurrentDisk].hasFile(args) then
            _G[CurrentDisk].createFile(args)
            CON_OUTPUT("Created File "..args)
        else
            CON_OUTPUT(COLORS.RED.."File already exists")
        end
    end,
    run = function (CON_INPUT)
        local args = string.gsub(CON_INPUT, "run ","")
        if _G[CurrentDisk].hasFile(args) then
            local filedata = _G[CurrentDisk].readFile(args)
            loadstring(filedata)()
        else
            CON_OUTPUT(COLORS.RED.."Bad File Name")
        end
    end,
    helpfile = function (CON_INPUT)
        CON_OUTPUT("File Commands help:\ninstallfilecommands : Makes file commands load by default on your computer\nselectdisk <disk>: Select the disk to do operations on \nlistdisks : Lists all available disks\ncd <dir>: Changes Directory to <dir>\ndir [<dir>]: Lists elements of current directory or of <dir>\nmkdir <dir> : Creates a new directory of name <dir>\npwd : Outputs the current working directory\ndel <file> : Deletes file : <file>\nrmdir <dir> : Deletes directory : <dir>\ndiskusage : Outputs the current disk usage\nfilesize <file> : Outputs the size of <file>\noutfile <file> : Outputs the contents of <file>\nnewfile <filename> : Creates a new file of name <filename>\nrun <file> : Runs <file>\nhelpfile : Shows help for File Commands")
    end
}

-- Append new commands
for k,v in pairs(newCommands) do
    CON_COMMANDS[k] = v
end
CON_OUTPUT("Appended New Commands, Type helpfile for help")