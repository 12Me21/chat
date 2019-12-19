local Websocket = require "http.websocket"
local Json = require "JSON"
dofile("patch.lua")(Websocket)

local ws

local function start(auth, uid)
	ws = Websocket.new_from_uri "ws://chat.smilebasicsource.com:45695/chatserver"
	assert(ws:connect(), "connection failed")
	assert(ws:send(Json:encode{type = "bind", uid = uid, lessData = true, key = auth}), "bind send failed")
end

local function test()
	for _=1, 5 do
		local data = assert(ws:receive())
		print(data)
	end
end

return {
	start = start,
	test = test,
}

