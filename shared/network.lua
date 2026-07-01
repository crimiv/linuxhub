local Network = {}

local function getHttpGetter()
    if game and game.HttpGetAsync then
        return function(url)
            return game:HttpGetAsync(url)
        end
    elseif game and game.HttpGet then
        return function(url)
            return game:HttpGet(url)
        end
    end
    return nil
end

function Network.Fetch(url)
    local getter = getHttpGetter()
    if not getter then
        error("HttpGet/HttpGetAsync unavailable")
    end

    local success, result = pcall(function()
        return getter(url)
    end)

    if not success then
        error("Failed to fetch URL: " .. tostring(url) .. " (" .. tostring(result) .. ")")
    end
    if type(result) ~= "string" then
        error("Fetch result is not a string: " .. tostring(url))
    end

    local normalized = result:gsub("^%s+", "")
    if normalized:find("^<") or normalized:find("404: Not Found") or normalized:find("403: Forbidden") or normalized:find("Bad Request") then
        error("Invalid fetch response from " .. tostring(url))
    end

    return result
end

function Network.SafeLoadString(source, name)
    local fn, err = loadstring(source)
    if not fn then
        error("Failed to compile " .. tostring(name) .. ": " .. tostring(err))
    end
    return fn
end

function Network.Load(url)
    local source = Network.Fetch(url)
    local fn = Network.SafeLoadString(source, url)
    return fn()
end

function Network.LoadRelative(baseUrl, resourcePath)
    return Network.Load(baseUrl .. resourcePath)
end

return Network
