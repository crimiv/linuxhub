-- Smoke test for Linux Hub
print("Running smoke tests...")

local ok, Network = pcall(function() return dofile('shared/network.lua') end)
if not ok or not Network then
    print("Failed to load shared/network.lua:", Network)
    os.exit(2)
end

-- Test vendor adonisbypass load via Network.LoadRelative (uses vendor fallback)
local ok, res = pcall(function()
    return Network.LoadRelative("", "adonisbypass.lua")
end)
print(string.format("Network.LoadRelative vendor/adonisbypass.lua -> success=%s" , tostring(ok)))
if not ok then
    print("Error:", res)
    os.exit(3)
end

-- Compile-check all Lua files without running them
local lfs = require and require('lfs')
local function iterate_files()
    local files = {}
    local p = io.popen("find . -name '*.lua' -print")
    if not p then return files end
    for line in p:lines() do
        table.insert(files, line)
    end
    p:close()
    return files
end

local files = iterate_files()
local failures = {}
for _, f in ipairs(files) do
    local ok, chunk = pcall(loadfile, f)
    if not ok or not chunk then
        table.insert(failures, {file=f, err=chunk})
    end
end

if #failures > 0 then
    print('Compilation failures:')
    for _, v in ipairs(failures) do
        print(v.file, tostring(v.err))
    end
    os.exit(4)
end

print('Smoke tests passed')
os.exit(0)
