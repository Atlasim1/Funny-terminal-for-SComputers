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

CON_OUTPUT("Added Command")