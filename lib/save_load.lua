local SaveLoad = {}

-- Save data to a file
function SaveLoad.save(filename, data)
    local success, message = pcall(function()
        -- Write the data directly as a string
        love.filesystem.write(filename, data)
    end)
    if not success then
        print("Error saving file:", message)
        return false
    end
    return true
end

-- Load data from a file
function SaveLoad.load(filename)
    if love.filesystem.getInfo(filename) then
        local success, fileContent = pcall(function()
            return love.filesystem.read(filename)
        end)
        if not success then
            print("Error reading file:", fileContent)
            return nil
        end
        return fileContent
    else
        print("File not found:", filename)
        return nil
    end
end

return SaveLoad
