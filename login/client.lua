require "common"
util.add_path("./client/?.lua")
--util.add_path("./login/protocol/?.lua")
util.add_path("./game/protocol/?.lua")
local skynet = require "skynet"

-- require "config.config_mgr"
-- g_configMgr:loadAll()

--逻辑
require "oper"
require "player"


skynet.start(function()
	-- 
	skynet.dispatch("lua", function(session, source, command, ...)
		print("command", command)
		local f = g_player[command]
		assert(type(f) == "function")
		skynet.retpack(f(g_player, ...))
	end)

end)

