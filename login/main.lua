require "common"

util.add_path(root .. "login/?.lua")
util.add_path(root .. "common/?.lua")
util.add_path(root .. "login/protocol/?.lua")
util.add_path(root .. "config/?.lua")

local skynet = require "skyent"
local manager = require "skynet.manager"
local snax = require "snax"

require "config_mgr"

-- 登陆服现有的service: mysqld, mongod, logind
local mongo_ip = skynet.getenv("mongo_ip")
local mongo_user = skynet.getenv("mongo_user")
local mongo_passwd = skynet.getenv("mongo_passwd")
local mongo_db = skynet.getenv("mongo_db")
local mongo_port = skynet.getenv("mongo_port")

local mysql_ip = skynet.getenv("mysql_ip")
local mysql_user = skynet.getenv("mysql_user")
local mysql_passwd = skynet.getenv("mysql_passwd")
local mysql_db = skynet.getenv("mysql_db")

local client_ip = skynet.getenv("client_ip")
local client_port = skynet.getenv("client_port")
local web_ip = skynet.getenv("web_ip")
local web_port = skynet.getenv("web_port")
local server_ip = skynet.getenv("server_ip")
local server_port = skynet.getenv("server_port")

-- local gm_ip = skynet.getenv("gm_ip")
-- local gm_port = skynet.getenv("gm_port")
-- local http_ip = skynet.getenv("http_ip")
-- local http_port = skynet.getenv("http_port")

skynet.start(function()
	g_configMgr:loadAll()

	local mysqld = snax.uniqueservice("mysqld", mysql_ip, mysql_db, mysql_user, mysql_passwd)
	local mongod = snax.uniqueservice("mongod", mongo_ip, mongo_db, mongo_user, mongo_passwd, mongo_port)

	-- 脏字过滤服务
	local regexd = snax.uniqueservice("regexd", require("config_data/t_warn_str"))

	local logind = skynet.uniqueservice("logind")

	skynet.call(logind, "lua", "listenClient", client_ip, client_port)
	skynet.call(logind, "lua", "listenServer", server_ip, server_port)
	skynet.call(logind, "lua", "listenWeb", web_ip, web_port)
	skynet.call(logind, "lua", "start")

	--打开Gm
	--skynet.newservice("gmd", "main", gm_ip, gm_port)
	--打开http
	--skynet.newservice("httpd", "main", http_ip, http_port)

	log("login server start")
	print("login server start")

	skynet.exit()
end)