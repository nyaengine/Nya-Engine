-- engine/network/http_client.lua

local socket = require("socket")

local HttpClient = {}
HttpClient.__index = HttpClient

-- Helper function to split a string by a delimiter
local function split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Helper function to parse HTTP headers
local function parseHeaders(response)
    local headers = {}
    local headerLines = split(response, "\r\n")
    for _, line in ipairs(headerLines) do
        local key, value = line:match("^(.-):%s*(.*)$")
        if key and value then
            headers[key:lower()] = value
        end
    end
    return headers
end

-- Helper function to parse HTTP response
local function parseResponse(rawResponse)
    local headerEnd = rawResponse:find("\r\n\r\n")
    if not headerEnd then return nil, "Malformed response" end

    local headers = rawResponse:sub(1, headerEnd - 1)
    local body = rawResponse:sub(headerEnd + 4)

    local statusLine, restHeaders = headers:match("([^\r\n]+)\r\n(.+)")
    local statusCode = tonumber(statusLine:match("%s(%d%d%d)%s"))

    local parsedHeaders = parseHeaders(restHeaders or "")
    return {
        statusCode = statusCode,
        headers = parsedHeaders,
        body = body
    }
end

-- Sends an HTTP request to the specified host and port
function HttpClient:sendRequest(method, host, port, path, headers, body)
    local client = assert(socket.tcp())
    client:settimeout(5)

    -- Connect to the server
    local success, err = client:connect(host, port or 80)
    if not success then
        return nil, "Connection error: " .. (err or "unknown")
    end

    -- Format the HTTP request
    local request = string.format("%s %s HTTP/1.1\r\nHost: %s\r\n", method, path, host)
    for k, v in pairs(headers or {}) do
        request = request .. string.format("%s: %s\r\n", k, v)
    end
    request = request .. "Content-Length: " .. (#body or 0) .. "\r\n\r\n" .. (body or "")

    -- Send the request
    client:send(request)

    -- Receive the response
    local response, receiveErr = client:receive("*a")
    client:close()

    if not response then
        return nil, "Receive error: " .. (receiveErr or "unknown")
    end

    -- Parse the response
    local parsedResponse, parseErr = parseResponse(response)
    if not parsedResponse then
        return nil, parseErr
    end

    return parsedResponse
end

-- Makes an HTTP GET request
function HttpClient:get(url)
    local host, path = url:match("http://([^/]+)(/.*)")
    if not host then
        return nil, "Invalid URL"
    end
    return self:sendRequest("GET", host, 80, path or "/", {["Connection"] = "close"})
end

-- Makes an HTTP POST request
function HttpClient:post(url, body, contentType)
    local host, path = url:match("http://([^/]+)(/.*)")
    if not host then
        return nil, "Invalid URL"
    end
    return self:sendRequest("POST", host, 80, path or "/", {
        ["Connection"] = "close",
        ["Content-Type"] = contentType or "application/x-www-form-urlencoded"
    }, body)
end

return setmetatable({}, HttpClient)
