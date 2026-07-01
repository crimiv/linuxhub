Linux Hub
=========

A lightweight Roblox script hub for multiple games with a shared safe loader and WindUI front-end.

Quick start
-----------
- Use an executor that provides `HttpGet`/`HttpGetAsync` and `loadstring`.
- Run the loader in your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/crimiv/linuxhub/main/main.lua"))()
```

Development
-----------
- Code is written in Lua. CI runs `luacheck` and `luac -p` on PRs and pushes.
- To iterate locally, create a feature branch, push, and open a PR — CI will run automatically.

Files of interest
- `main.lua` — entrypoint loader
- `shared/network.lua` — centralized safe fetch/load helper
- `shared/windui.lua` — WindUI integration and theme
- `games/*` — per-game modules

Contributing
------------
See `CONTRIBUTING.md` for contribution and PR guidelines.

License
-------
This repository has no license file; add one if you want to change sharing terms.