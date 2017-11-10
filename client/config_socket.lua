package.cpath = "../skynet/luaclib/?.so"
package.path = "../skynet/lualib/?.lua;../client/?.lua;../skynet/lualib/?/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "skynet.socket"

local fd = assert(socket.connect("127.0.0.1", 8888))

socket.send(fd, "hello world")