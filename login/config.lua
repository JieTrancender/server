DEBUG = true	--开发版
project_name = "client"
thread = 2
logservice = "mylogger"
--logger = "./log/client"
logger = nil
harbor = 0
start = "main"
luaservice = "./service/?.lua;./"..project_name.."/?.lua;"
lualoader = "lualib/loader.lua"
cpath = "./cservice/?.so"
lua_path = "./lualib/?.lua;./lualib/?/init.lua;./"..project_name.."/?.lua;./game/protocol/?.lua;"
snax = "./service/?.lua;"
debug_console = 6112
client_passwd = "o~p%e#r"
code_version = "1.0.0.0"

--daemon = "./skynet.pid"


--登陆服的ip,port
-- server_ip = "192.168.2.250"
-- server_port = 7200
-- area = 2
-- --
-- robot_name = "robot"
-- robot_number = 100

root = "$ROOT/"
DEBUG = true
project_name = "login"
thread = 2
logservice = "mylogger"
logger = nil
harbor = 0
start = "main"
bootstrap = "snlua bootstrap"
luaservice = root .. "service/?lua;" .. root .. project_name .. "/?.lua;"
lualoader = root .. project_name .. "/lualib/loader.lua"
cpath = root .. "cservice/?.so"
lua_path = root .. project_name .. "/lualib/?.lua;" .. root .. project_name .. "/lualib/?/init.lua;" .. root .. project_name .. "/?.lua"
snax = root .. "service/?.lua;"

client_passwd = "o~p%e#r"
code_version = "1.0.0.0"

-- 平台跟区
server_id = 4

-- 数据库
mongo_ip = "127.0.0.1"
mongo_user = "root"
mongo_passwd = nil
mongo_db = "pkm_"..server_id

mysql_ip = "127.0.0.1"
mysql_user = "root"
mysql_passwd = "root"
mysql_db = "pkm_log_"..server_id


-- 监听客户端的ip, port
client_ip = "0.0.0.0"
client_port = "31"..(server_id - 1).."11"


-- 监听web端的ip, port
web_ip = "0.0.0.0"
web_port = "32"..(server_id - 1).."12"

-- 监听游戏服的ip, port
server_ip = "0.0.0.0"
server_port = "31"..(server_id - 1).."10"
