-- Plugin that adds the ability to upload files to the computer using the keyboard

CON_COMMANDS.keyinput = function (CON_INPUT)
    local keyboard = getComponent("keyboard")
    local args = string.gsub(CON_INPUT, "keyinput ","")
    if not _G[CurrentDisk].hasFile(args) then
        local data = keyboard.read()
        _G[CurrentDisk].createFile(args)
        _G[CurrentDisk].writeFile(args, data)
        CON_OUTPUT("File Downloaded")
    else
        CON_OUTPUT(COLORS.RED"Bad Usage")
    end
end

CON_COMMANDS.keyinputinstall = function (CON_INPUT)
    setData(getData()..'Data.AUTOEXEC.keyinputplugin = function () local maindisk = getComponents("disk")[1] local filedata = maindisk.readFile("keyinputplugin.lua") loadstring(filedata)() end')
end

CON_OUTPUT("Added Command")