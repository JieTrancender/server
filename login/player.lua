
require "common"
local skynet = require "skynet"
local md5 = require "md5"
local socket = require "socket"
local proto = require "pbc_c_include"

local _loginSock
local _gameSock
local loginLast = ""
local gameLast = ""

local code_version = skynet.getenv("code_version")
local client_passwd = skynet.getenv("client_passwd")

Player = oo.class(nil, "Player")

function Player:__init()
	self._roleId = 0
	self._roleInfo = nil
	self._role = nil
	self._key = nil
	self._username = nil
end

function Player:setInfo( playerId, info)
	for k,v in pairs(info) do
		print(k,v)
	end
	g_player._playerId = playerId
	g_player._roleInfo = info
end

function Player:startLogin( ip, port )
	print("connect ip, port:", ip, port)
	if _loginSock ~= nil then
		socket.close(_loginSock)
		_loginSock = nil
		loginLast = ""
	end
	_loginSock = socket.open(ip, port)
	print("start: ", _loginSock)
	assert(_loginSock)

	local function unpack_f(f)
		local function try_recv(fd, last)
			local result, size
			result, last, size = f(last)
			if result then
				return result, last, size
			end
			local r = socket.read(fd)
			if r == false then
				self:serverClosed()
				return false
			end
			return f(last .. r)
		end

		return function(fd)
			while true do
				local result, size
				result, loginLast, size = try_recv(fd, loginLast)
				if result then
					return result, size
				elseif result == false then
					return nil
				end
			end
		end
	end

	local function unpack_package(text)
		local size = #text
		if size < 2 then
			return nil, text
		end
		local s = text:byte(1) * 256 + text:byte(2)
		if size < s+2 then
			return nil, text
		end

		return text:sub(3,2+s), text:sub(3+s), s
	end

	local readpackage = unpack_f(unpack_package)
	
	skynet.fork(function()
		while _loginSock do
			local msgBuf, sz = readpackage(_loginSock)
			if msgBuf then
				proto.dispatch( msgBuf, sz )
			end
		end
	end)
end

function Player:startGame( ip, port )
	print("connectGame ip, port:", ip, port)
	if _gameSock ~= nil then
		socket.close(_gameSock)
		_gameSock = nil
		gameLast = ""
	end

	if _loginSock ~= nil then
		socket.close(_loginSock)
		_loginSock = nil
		loginLast = ""
	end

	_gameSock = socket.open(ip, port)
	print("start: ", _gameSock)
	assert(_gameSock)

	local function unpack_f(f)
		local function try_recv(fd, last)
			local result, size
			result, last, size = f(last)
			if result then
				return result, last, size
			end
			local r = socket.read(fd)
			if r == false then
				self:serverClosed()
				return false
			end
			return f(last .. r)
		end

		return function(fd)
			while true do
				local result, size
				result, gameLast, size = try_recv(fd, gameLast)
				if result then
					return result, size
				elseif result == false then
					return nil
				end
			end
		end
	end

	local function unpack_package(text)
		local size = #text
		if size < 2 then
			return nil, text
		end
		local s = text:byte(1) * 256 + text:byte(2)
		if size < s+2 then
			return nil, text
		end

		return text:sub(3,2+s), text:sub(3+s), s
	end

	local readpackage = unpack_f(unpack_package)
	
	--
	skynet.fork(function()
		while _gameSock do
			local msgBuf, sz = readpackage(_gameSock)
			if msgBuf then
				proto.dispatch( msgBuf, sz )
			end
		end
	end)
end

function Player:close()
	socket.close(_sock)
	_sock = nil
end

function Player:serverClosed()
	print("--------> server closed!")
	_sock = nil
	self:logout()

end

function Player:sendLogin( msg, id1, id2 )
	local buf, size = proto.pack(msg, id1, id2, 0)
	socket.write(_loginSock, buf)
end

function Player:sendGame( msg, id1, id2 )
	print_r(msg)
	local buf, size = proto.pack(msg, id1, id2, 0)
	socket.write(_gameSock, buf)
end

--注册
function Player:createFirstRole()

	local msg = {
		username = self._username,
		name = self._username,
		platform = "test",
		camp = 1,
		initCode = 510001
	}

	print("-----------createFirstRole msg")
	print_r(msg)
	
	self:sendLogin(msg, "login", "CreateFirstRole")
end

--登陆登陆服
function Player:login(account, area)
	local  username = account or "robot"
	self._username = username
	local msg = {
		username = username,
		token = "",
		clientPasswd = client_passwd,
		platform = "test",
		serverId = area,
		osCode = 3,
		deviceId = "",
		codeVersion = code_version,
		userAgent = "{\"userAgent\":\"\"}",
	}
	print("---------Player:login")
	print_r(msg)
	self:sendLogin(msg, "login", "Login")
end

-- 获取用户名
function Player:getUserName()
	return self._username
end

-- 获取id
function Player:getUserId()
	return self._roleId
end

--获取背包
function Player:GetPlayerItem()
	print("GetPlayerItem")
	self:sendGame({}, "bag", "GetPlayerItem")
	-- body
end

--添加财产
function Player:addMoney(code, num)
	print("addMoney")
	self:sendGame({code = code, num = num}, "test", "addMoney")
end

--添加经验
function Player:addExp( code, num )
	print("addExp")
	self:sendGame({code = code, num = num}, "test", "addExp")
end

--模块调用
function Player:testCall( args, module, operation )
	print(module, operation)
	print_r(args)

	self:sendGame(args, module, operation)
end


--分隔字符串 
--@param #string str 源字符串
--@param #string delim 分隔符
--@return #table还回分隔的字符数组
local function split(str, delim)
	if str == nil then
		print("the string parameter is nil")
		return {}
	elseif str == "" then
		return {}
	end
	str =  str..""
   local delim, fields = delim or ":", {}
	if not str then return fields end
	if delim == "" then
		fields = string.strToArr(str)
		return fields
	end
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
		local pos = string.find (str, delim, start, true) -- plain find
        if not pos then
          break
        end

        table.insert (t, string.sub (str, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (str, start))

    return t
end

function Player:loginGame()

	local gameUrl = split(self._roleInfo.gameUrl, ":")

	self:startGame( gameUrl[1], gameUrl[2] )

	-- local time = os.time()
	local msg = {
		playerId = self._playerId,
		username = self._username,
		name = self._roleInfo.name,
		sessionkey = self._roleInfo.sessionkey,
		deviceId = "",
		codeVersion = code_version
	}
	self:sendGame(msg, "loginGame", "LoginGame")
	-- body
end


--退出游戏
function Player:logout()
	skynet.exit()
end


--创建全局对象
if g_player == nil then
	g_player = Player()
end