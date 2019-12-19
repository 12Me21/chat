local Websocket = require "http.websocket"
local Json = require "JSON"
dofile("patch.lua")(Websocket)

local ws

local function send_json(data)
	return ws:send(Json:encode(data))
end

local function start(auth, uid)
	ws = Websocket.new_from_uri "ws://chat.smilebasicsource.com:45695/chatserver"
	assert(ws:connect(), "connection failed")
	assert(send_json{type = "bind", uid = uid, lessData = true, key = auth}, "bind send failed")
end

local function test()
	local data = assert(ws:receive())
	print(data)
end

local function handle_response(data)
	if data.from=="bind" then
		if data.result==true then
			print("bind succeeded")
			send_json{type="request", request="messageList"}
		else
			print("bind failed")
		end
	else
		if data.result==false then
			for _, err in ipairs(data.errors) do
				print("Received error response from chat: "..err)
			end
		end
	end
end


local function handle_message(data)
	local type = data.type or ""
	if type=="system" or type=="warning" then
		print(data.message)
	elseif type=="module" then
		print(data.message)
	elseif type=="message" then
		print(data.sender.username..":")
		local encoding=data.encoding
		local text=data.message
		if encoding=="image" then
			print("/img "..text)
		elseif encoding=="code" then
			print("/code "..text)
		elseif encoding=="raw" then
			print("[raw]"..text)
		elseif encoding=="draw" then
			print("[drawing]")
		elseif encoding=="markdown" then
			print(text)
		else
			print(text)
		end
	else

	end
end

local got_ids = {}
local function run()
	local json = assert(ws:receive())
	local data = Json:decode(json)
	if data.type=="response" then
		handle_response(data)
	elseif data.type=="messageList" then
		for _, message in ipairs(data.messages) do
			if not got_ids[message.id] then
				got_ids[message.id] = true
				handle_message(message)
			end
		end
	elseif data.type=="userList" then
		--handle_userlist(data.users)
		--handle_roomlist(data.rooms)
	else
		-- ...
	end
end

return {
	start = start,
	test = test,
	run = run,
}

