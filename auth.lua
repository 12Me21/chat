local Request = require "http.request"
local Json = require "JSON"
local Md5 = require "md5"

local SESSION_FILE = "session.txt"

local function login2session(username, passwordhash)
	local req = Request.new_from_uri("https://smilebasicsource.com/query/submit/login?session=x&small=1")
	req.headers:upsert(":method","POST")
	req.headers:upsert("content-type","application/x-www-form-urlencoded")
	req:set_body("username="..username.."&password="..passwordhash)
	local headers, stream = assert(req:go())
	local body = assert(stream:get_body_as_string())
	local data = Json:decode(body);
	if data.result then
		return data.result, nil
	else
		print("Failed to log in:")
		for _,err in ipairs(data.errors) do
			print('"'..err..'"')
		end
		return nil, data.errors
	end
end

local function session2auth(session)
	local req = Request.new_from_uri("https://smilebasicsource.com/query/request/chatauth?session="..session)
	req.headers:upsert(":method","GET")
	local headers, stream = assert(req:go())
	local body = assert(stream:get_body_as_string())
	local data = Json:decode(body);
	if data.result then
		return data.result, data.requester.uid
	else
		print("Failed to get chat auth: (probably invalid session)")
		for _,err in ipairs(data.errors) do
			print('"'..err..'"')
		end
		return nil, data.errors
	end
end

local function get_login()
	io.write("username: ")
	local username = io.read()
	io.write("password: ")
	local passwordhash = Md5.sumhexa(io.read())
	return username, passwordhash
end

local function load_session()
	local file = io.open(SESSION_FILE)
	if not file then return end
	local session = file:read()
	file:close()
	return session
end

local function save_session(session)
	local file = io.open(SESSION_FILE, "w")
	if not file then return end
	file:write(session)
	file:close()
	return true
end

local function get_session(force)
	local session
	if not force then
		session = load_session()
	end
	if not session then
		local username, passwordhash = get_login()
		if username and passwordhash then
			session = login2session(username, passwordhash)
		end
	end
	if session then
		save_session(session)
		return session
	else
		print("Failed to get session")
	end
end

local function get_auth()
	local auth, uid = session2auth(get_session())
	if not auth then
		auth, uid = session2auth(get_session(true))
	end
	if not auth then
		print("Failed to get auth")
	end
	return auth, uid
end

return get_auth
