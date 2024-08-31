-- Function to perform an HTTP GET request using curl
local function http_get(url)
    local temp_file = "response.txt"
    local command = string.format('curl -s "%s" -o "%s"', url, temp_file)
    
    -- Execute the curl command
    os.execute(command)
    
    -- Read the response from the file
    local file = io.open(temp_file, "r")
    local response = file:read("*a")
    file:close()

    -- Remove the temporary file
    os.remove(temp_file)
    
    return response
end

-- LOVE2D callback for when the game starts
function love.load()
    -- URL to fetch
    local url = "http://www.example.com/"
    
    -- Perform the HTTP GET request
    local response = http_get(url)

    -- Check if the response was successfully received
    if response then
        -- Print the response to the console (or handle it as needed)
        print("HTTP Response:")
        print(response)
    else
        print("Failed to get response.")
    end
end
