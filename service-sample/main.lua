local skynet = require "skynet"

skynet.start(function()
	print("======server start======")

	if not skynet.getenv("daemon") then
		local console = skynet.newservice("console")
	end

	skynet.newservice("debug_console", 8001)
	local proto = skynet.uniqueservice "protoloader"
	skynet.call(proto, "lua", "load", {
		"proto.c2s",
		"proto.s2c",
	})

	print("--------")

	local hub = skynet.uniqueservice("hub")
	skynet.call(hub, "lua", "open", "0.0.0.0", 5679)

	skynet.exit()
end)