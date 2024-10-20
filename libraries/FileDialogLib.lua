--Custom FileDialog Library
-- © by Moonwave Studios
-- MIT License
local FileDialogLib = {}

function FileDialogLib.showFileDialog(title, initialDir, fileFilter)
    -- Create a new file dialog
    local dialog = gui.createDialog(title, initialDir, fileFilter)
    -- Show the dialog
    dialog:show()
end

return FileDialogLib
