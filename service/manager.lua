local skynet = require "skynet"
local service = require "service"
local log = require "log"

local manager = {}
local users = {}

local function new_agent()
	return skynet.newservice "agent"
end

local function free_agent(agent)
	skynet.kill(agent)
end

function manager.assign(fd, userid)
	local agent
	repeat
		agent = users[userid]
		if not agent then
			agent = new_agent
			if not users[userid] then
				users[userid] = agent
			else
				free_agent(agent)
				agent = users[userid]
			end
		end
	until skynet.call(agent, "lua", "assign", fd, userid)
	log("assign %d to %s [%s]", fd, userid, agent)
end

function manager.exit(userid)
	users[userid] = nil
end

service.init {
	command = manager,
	info = users,
}