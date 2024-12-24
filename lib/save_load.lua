-- save_load.lua
local SaveLoad = {}

-- Save data to a file
function SaveLoad.save(filename, data)
    local success, serialized = pcall(function()
        return love.data.compress("string", "zlib", love.data.pack("string", "data", data))
    end)
    if not success then
        print("Error serializing data:", serialized)
        return false
    end

    local success, message = love.filesystem.write(filename, serialized)
    if not success then
        print("Error saving file:", message)
        return false
    end
    return true
end

-- Load data from a file
function SaveLoad.load(filename)
    if love.filesystem.getInfo(filename) then
        local compressedData, size = love.filesystem.read(filename)
        local success, decompressed = pcall(function()
            return love.data.decompress("string", "zlib", compressedData)
        end)
        if not success then
            print("Error decompressing data:", decompressed)
            return nil
        end

        local success, unpacked = pcall(function()
            return love.data.unpack("string", decompressed)
        end)
        if not success then
            print("Error unpacking data:", unpacked)
            return nil
        end

        return unpacked
    else
        print("File not found:", filename)
        return nil
    end
end

return SaveLoad
