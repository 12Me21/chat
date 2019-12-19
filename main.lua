local get_auth = dofile "auth.lua"
local websocket = dofile "websocket.lua"

local auth, uid = get_auth()
websocket.start(auth, uid)

