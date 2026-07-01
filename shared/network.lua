local Network = {}

-- Simple in-memory cache for fetched resources
Network._cache = {}

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

-- Try to read a local vendor file as a fallback when network fetch fails.
local function readVendor(resourcePath)
    local vendorPath = "vendor/" .. resourcePath
    local ok, f = pcall(function() return io.open(vendorPath, "r") end)
    if not ok or not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

function Network.Fetch(url, opts)
    opts = opts or {}
    if Network._cache[url] and not opts.force then
        return Network._cache[url]
    end

    local getter = getHttpGetter()
    if not getter then
        -- No network getter available; try vendor
        local fallback = readVendor(opts.resourcePath or "")
        if fallback then
            Network._cache[url] = fallback
            return fallback
        end
        error("HttpGet/HttpGetAsync unavailable")
    end

    local success, result = pcall(function()
        return getter(url)
    end)

    if not success or type(result) ~= "string" then
        -- Try local vendor fallback before failing
        local fallback = readVendor(opts.resourcePath or "")
        if fallback then
            Network._cache[url] = fallback
            return fallback
        end
        error("Failed to fetch URL: " .. tostring(url) .. " (" .. tostring(result) .. ")")
    end

    local normalized = result:gsub("^%s+", "")
    if normalized:find("^<") or normalized:find("404: Not Found") or normalized:find("403: Forbidden") or normalized:find("Bad Request") then
        local fallback = readVendor(opts.resourcePath or "")
        if fallback then
            Network._cache[url] = fallback
            return fallback
        end
        error("Invalid fetch response from " .. tostring(url))
    end

    Network._cache[url] = result
    return result
end

function Network.SafeLoadString(source, name)
    local fn, err = loadstring(source)
    if not fn then
        error("Failed to compile " .. tostring(name) .. ": " .. tostring(err))
    end
    return fn
end

function Network.Load(url, opts)
    local source = Network.Fetch(url, opts)
    local fn = Network.SafeLoadString(source, url)
    return fn()
end

function Network.LoadRelative(baseUrl, resourcePath)
    local url = baseUrl .. resourcePath
    return Network.Load(url, { resourcePath = resourcePath })
end

return Network
