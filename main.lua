local get_auth = dofile "auth.lua"
local websocket = dofile "websocket.lua"
local curses = require "curses"

local auth, uid = get_auth()

--[[local stdscr = curses.initscr()

curses.cbreak()
curses.echo(false)-- not noecho !
curses.nl(false)-- not nonl !

stdscr:nodelay(true)
stdscr:clear()

stdscr:mvaddstr(15, 20, "HECK!")
	stdscr:refresh()]]--

websocket.start(auth, uid)

local cqueues = require "cqueues"

local cq = cqueues.new()

print("starting!")
--[[cq:wrap(function()
		while 1 do
			--local c = stdscr:getch()
			cqueues.sleep(0.1)
		end
	end)]]--

cq:wrap(function()
		while 1 do
			websocket.run()
		end
end)

assert(cq:loop())



