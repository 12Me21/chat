local Websocket = require "http.websocket"
local Json = require "JSON"

local ws

local function start(auth, uid)
	ws = Websocket.new_from_uri{
		scheme="ws",
		host="chat.smilebasicsource.com",
		port=45695,
		path="/chatserver",
	}
	ws:connect()
	ws:send(Json:encode{
				  type = "bind",
				  uid = uid,
				  lessData = true,
				  key = auth,
	})
end

return {
	start = start,
}

