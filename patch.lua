-- The SBS chat server doesn't send the correct sec-websocket-accept header field, or this library is broken
-- need to disable the check otherwise it'll reject the connection

local digest = require "openssl.digest"
local basexx = require "basexx"

local function base64_sha1(str)
	return basexx.to_base64(digest.new("sha1"):final(str))
end

local function find_upvalue(func, name)
	local i = 1
	while 1 do
		local n, v = debug.getupvalue(func, i)
		if not n then break end
		if n == name then return v, i end
		i = i + 1
	end
end

return function(Websocket)
	local handle_websocket_response = find_upvalue(Websocket.methods.connect, "handle_websocket_response")
	function Websocket.methods:connect(timeout)
		assert(self.type == "client" and self.readyState == 0)
		local headers, stream, errno = self.request:go(timeout)
		if not headers then
			return nil, stream, errno
		end
		headers:upsert("sec-websocket-accept", base64_sha1(self.key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"))
		return handle_websocket_response(self, headers, stream)
	end
end

		
