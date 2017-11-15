-- 常用的库
util = require "util"
oo = require "oo"

local math = math
local c = require "skynet.core"
local bson = require "bson"
local json = require "cjson"

-- 全局函数

local function pr( obj )
	if obj == nil then
		reutrn "nil    "
	elseif type(obj) == "table" then
		print_r(obj)
	else
		return tostring(obj) .. "    "
	end
end

function p( ... )
	local t = table.pack(...)
	local str = ""

	for i = 1, t.n do
		local t = pr(t[i])
		if t then
			str = str .. t
		end
	end

	print(str)
end

function print_r(obj)
	print( util.table_dump( obj ) )
end

function print_for( obj )
	for k, v in pairs(obj) do
		print("---->", k, v)
	end
end

-- 根据配置显示输出函数
local serverId = tonumber(skynet.getenv("server_id") or 0) -- 0 用于client

function print_t(id, ...)
	if id == serverId then
		print(...)
	end
end

function print_r_t(id, ...)
	if id == serverId then
		print_r(...)
	end
end

function print_for_t(id, ...)
	if id == serverId then
		print_for(...)
	end
end

function traceback( msg )  
    print("----------------------------------------")  
    logError("LUA ERROR: " .. tostring(msg) .. "\n")  
    logError(debug.traceback())  
    print("----------------------------------------")  
end

function dump_string(s)
	local b = false
	local str = ""
	for i=1,#s do
		if b then
			str = str .. ","
		else
			b = true
		end
		local c = string.byte(s, i)
		str = str .. c
	end
	print(str)
end

math.randomseed(os.time())
function random(min, max)
	return math.random(min, max)
end

--日志输出
function logImp( ... )
	local t = {...}
	for i=1,#t do
		t[i] = tostring(t[i])
	end
	return c.error(table.concat(t, " "))
end

function log( ... )
	if _roleId then
		logImp(_roleId, ...)
	else
		logImp(...)
	end
end

function logError( ... )
	if _roleId then
		logImp(_roleId, "error", ...)
	else
		logImp("error", ...)
	end
end

function logWarning( ... )
	if _roleId then
		logImp(_roleId, "warning", ...)
	else
		logImp("warning", ...)
	end
end

function deepCopy( object )
	local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        --return setmetatable(new_table, getmetatable(object))
        return new_table
    end
    return _copy(object)
end

--压缩奖励
function collapse(info)
	local collapse = {}

	for i,v in ipairs(info) do
		if collapse[v[1]] then
			if not collapse[v[1]][v[2]] then
				collapse[v[1]][v[2]] = 0
			end
			collapse[v[1]][v[2]] = collapse[v[1]][v[2]] + v[3]
		else
			collapse[v[1]] = {}	
			collapse[v[1]][v[2]] = v[3]
		end
	end

	local ret = {}
	for type, v in pairs(collapse) do
		for code, num in pairs(v) do
			table.insert(ret, {type, code, num})
		end
	end

	return ret
end

function getClientAttr( attr )
	local clientAttr = {}
	for k,v in pairs(attr) do

		if v == 0 then
			table.insert(clientAttr, {k, v})
		end
		
		if v // 100000 > 0 then
			table.insert(clientAttr, {k, v // 100000 * 100000})
		end
		if v % 100000 > 0 then
			table.insert(clientAttr, {k, v % 100000})
		end
	end
	return clientAttr
end

--获取随机奖励
function getRandomReward(id)
	local config = g_configMgr:getConfig("random_reward").randomReward[id]
	if not config then
		return
	end

	local reward = {}
	if config.type == 1 then
		local pool = {}
		for _,v in ipairs(config.reward) do
			if v[1] == -1 then
				table.insert(reward, {v[2], v[3], v[4]})
			else
				table.insert(pool, v)
			end
		end

		for i=1,config.number do
			local randomNum = g_arithUtil:myRandom(1, 10000)
			local cur = 0
			for i,v in ipairs(pool) do
				cur = cur + v[1]
				if cur >= randomNum then
					table.insert(reward, {v[2], v[3], v[4]})
					break
				end
			end
		end
	elseif config.type == 2 then
		for _,v in ipairs(config.reward) do
			if v[1] == -1 then
				table.insert(reward, {v[2], v[3], v[4]})
			elseif g_arithUtil:myRandom(1, 10000) <= v[1] then
				table.insert(reward, {v[2], v[3], v[4]})
			end
		end
	else
		return
	end

	return reward
end

function makeCenterCmd( module, oper )
	assert(type(module) == "string" and type(oper) == "string")
	return module .. "." .. oper
end

function makeWorldCmd( module, oper )
	assert(type(module) == "string" and type(oper) == "string")
	return module .. "." .. oper
end

function makePushCmd( module, oper )
	assert(type(module) == "string" and type(oper) == "string")
	return module.."."..oper
end

function appendRewards( appRewards, rewards)
	for i,v in ipairs(rewards) do
		table.insert(appRewards, {v[1],v[2],v[3]})
	end
end

function changeTable( value )
	if value == nil or value == "" then
		return {}
	end
	return json.decode(value)
end

--拆分属性值
function spiltAttrValue( value )
	local fixed, percent = value // 100000, value % 100000
	if percent ~= 0 and percent > 50000 then
		return fixed, 50000 - percent
	end
	return fixed, percent
end

--属性累加
function AttrAdditive( left, right )
	local leftF, leftP = spiltAttrValue(left)
	local rightF, rightP = spiltAttrValue(right)
	local sumF = leftF + rightF
	local sumP = leftP + rightP
	if sumP < 0 then
		sumP = 0 - sumP + 50000
	end
	return sumF * 100000 + sumP
end

function BattleAttr( value )
	local fixed, percent = spiltAttrValue(value)
	if fixed == 0 then
		return value
	end
	return math.floor(fixed * (1 + percent / 1000)) * 100000
end

--生成uuid
function genUUID()
	local _, uuid = bson.type(bson.objectid())
	return uuid
end

-- 重载os.time
local curTime = os.time
local timeOffset = 0
os.time = function(t)
	--返回指定时间的时间戳
	if t then
		return curTime(t)
	end
	-- print("os.time = "..(curTime() + timeOffset).." offset = "..timeOffset)
	return curTime(t) + timeOffset
end

function setTimeOffset( offset )
	if offset == nil --[[or offset <= timeOffset]] then
		return false
	end
	timeOffset = offset
	return true
end

function getActualTime( )
	return curTime()
end

--查询功能是否解锁
--返回值，0未解锁， 1已解锁
function checkModuleUnlock( id )
    if id == nil then
        return 0
    end
    local config = g_configMgr:getConfig("unlock")
    local module = config[id]
    if module == nil then
        return 0
    end

    if module.condition[1] == 0 then   --玩家等级
        local level = g_player:getPlayerLevel()
        if level >= module.condition[2] then
            return 1
        else
            return 0
        end 
    end 

    return 0
end

--获取功能解锁等级
function getUnlockLevel( id )
	if not id then
		return 0
	end
    local config = g_configMgr:getConfig("unlock")
    local module = config[id]
    if module == nil then
        return 0
    end

    if module.condition[1] == 0 then   --玩家等级
        return module.condition[2]
    end 

    return 0

end

--获取当天开始时间戳
function nowDayTimeStart(now_time)
	local tab = os.date("*t" , now_time)
	tab.hour = 0
	tab.min = 0 
	tab.sec = 0
	local result = os.time(tab)
	return result
end