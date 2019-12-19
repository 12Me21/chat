Tested on Lua 5.2

#### Dependencies:
- `http`
- `json-lua`
- `md5`

(install with luarocks)
(make sure luarocks is using the right version of Lua!)

#### Patching websocket library (REQUIRED):
`http/websocket.lua`, line 282  
(probably located at `/usr/local/share/lua/<version>/http/websocket.lua`)  
change `0` to `1`

If not, you'll get an error when trying to connect:  
`/usr/local/share/lua/<version>/http/websocket.lua:282: read: Connection timed out`  
(If you can't find the library location, you can use this error to get the file path)
