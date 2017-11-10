local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"

local auth = {}
local users = {}
local client = client.handler()

local SUCC = {ok = true}
local FAIL = {ok = false}

function client:signup(args)
	log("signup userid = %s", args.userid)
	if users[args.userid] then
		return FAIL
	else
		users[args.userid] = true
		return SUCC
	end
end

function client:signin(args)
	log("signin  userid = %s", args.userid)
	if users[args.userid] then
		self.userid = args.userid
		self.exit = true
		return SUCC
	else
		return FAIL
	end
end

function client:ping()
	log("ping")
end

function auth.shakehand(fd)
	local c = client.dispatch {fd = fd}
	return c.userid
end

service.init {
	command = auth,
	info = users,
	init = client.init "proto",
}