local skynet = require "skynet"
local proto = require "pbc_c_include"
local json = require("cjson")
local packId = require "export.package_id"

-- 为表tbl注册obj中的回调函数
local function registFuncTbl(tbl, obj, ...)
	local args = {...}
	local ch
	if type(obj) == "string" then
		ch = obj:sub(-1, -1)
		for _, v in pairs(args) do
			if ch == v then
				table.insert(tbl, obj)
				break;
			end
		end
	elseif type(obj) == "table" then
		for index, func in pairs(obj) do
			if type(func) == "string" and type(index) == "number" then
				ch = func:sub(-1, -1)
				for _, v in pairs(args) do
					if ch == v then
						table.insert(tbl, func)
						break;
					end
				end
			end
		end
	else
		print("no implement:"..type(obj))
	end
end

-- 设置表obj回调函数的hash映射
local function setOperation(obj, callbackFunc)
	for _, operation in ipairs(callbackFunc) do
		obj[operation] = function(msg)
			print(operation)
			print_r(msg)
		end
	end
end

-- 通过文件名注册对应协议的回调函数
local function registerAllCallBack(fileName)
	print(fileName)

	local protoId = require("export."..fileName.."_id")
	local protocol = {}
	local protocolCallBack = {}

	registFuncTbl(protocolCallBack, protoId, 'P', 'R')
	setOperation(protocol, protocolCallBack)
	proto.registFuncTbl(fileName, protocol)
end

-- include 所有协议文件	[一级消息id]
for k, v in pairs(packId) do
	if type(k) == "string" then
		registerAllCallBack(k)
	end
end

-- login协议操作
local login = {}
local loginCallBack = {}

function login.LoginR(msg)
	--p(msg)
	print("err: ", msg.err)
	print_r(msg.role)
	g_player:setInfo(msg.role.playerId, msg.role)
	--g_player:close()
	if msg.err == 0 then
		print("login success: name", msg.role.name)
		-- skynet.timeout(10, function()
		-- 	g_player:loginGame()
		-- end)
		g_player:loginGame()
	elseif msg.err == 10006 then
		p("login loginR err:", msg.err)
		g_player:createFirstRole()
		--g_player:logout()
	elseif msg.err == 10003 then
		p("login loginR err: 未创建角色")

		local function setUserName()
			print("please input your username to create role:")
			local user_name = io.read()
			if user_name ~= nil and user_name ~= "" then
				g_player._username = user_name
			else
				g_player._username = username
			end
		end

		setUserName()
		print("username = "..g_player:getUserName())
		g_player:createFirstRole()
	else 
		p("login loginR err:", msg.err)
		g_player:logout();
	end

end

function login.CreateFirstRoleR(msg)
	print("err: ", msg.err)
	g_player:login(g_player:getUserName())
	-- g_player:logout()
end

proto.registFuncTbl("login", login)

--game 协议操作
local loginGame = {}
function loginGame.LoginGameR(msg)
	-- body
	print("err: ", msg.err)
	print_r(msg)
	if msg.err == 0 then
		-- g_player:testCall({}, "activity", "GetActivityList")
		-- g_player:testCall({targetAmount = 300}, "activity", "RechargeReward")
		-- g_player:testCall({}, "activity", "GetRechargeRewardInfo")
		-- g_player:testCall({name = "独步地下", avatar = "default.png"}, "guild", "CreateGuild")
		-- g_player:testCall({}, "guild", "GetPlayerGuild")
		-- g_player:testCall({id = 23423}, "test", "addHero")

		-- 公会相关
		-- g_player:testCall({}, "guild", "GetGuildBattleSubwayInfo")
		-- g_player:testCall({}, "guild", "ChallengeGuildBattleSubway")
		-- g_player:testCall({}, "guild", "MopUpGuildBattleSubway")
		
		-- g_player:testCall({rankType = 17}, "ranking", "GetCommonRank")
		-- g_player:testCall({operationType = 6, id = 40002}, "guild", "GuildOperation")
		-- g_player:testCall({operationType = 8, id = 400009}, "guild", "GuildOperation")
		-- g_player:testCall({rankType = 17}, "ranking", "GetCommonRank")

		-- g_player:testCall({pos = 2, uuid = 40000000}, "pokemon", "PutOnPokemon")

		-- test相关
		-- g_player:testCall({num = 5, id = 40103900}, "test", "addPokemon")


		-- g_player:testCall({m_type = 2}, "gashapon", "UserMakeGashapon")
		-- activity
		-- g_player:testCall({}, "activity", "GetFlashCapsuleInfo")
		-- g_player:testCall({id = 1}, "activity", "FlashCapsule")

		-- g_player:testCall({id = 7}, "activity", "CollectPokemon")
		-- g_player:testCall({}, "activity", "GetCollectPokemonInfo")
		g_player:testCall({}, "activity", "GetChampionChallengeInfo")
		-- g_player:testCall({id = 1}, "activity", "ChampionChallenge")
		-- champion
		-- g_player:testCall({}, "champion", "ChampionBattle")
	end
end

proto.registFuncTbl("loginGame", loginGame)

--activity 协议操作

local activity = {}

function activity.GetChampionChallengeInfoR(msg)
	print_r(msg)
end

function activity.ChampionChallengeR(msg)
	print(msg)
end

function activity.RechargeRewardR(msg)
	print("activity err: ", msg.err)
	if msg.err == 0 then
		print_r(msg.info)
		print_r(msg.clientReward)
	end
end

function activity.GetRechargeRewardInfoR(msg)
	if msg.err == 0 then
		print_r(msg.info)
	end
end

function activity.GetFlashCapsuleInfoR(msg)
	print_r(msg)
end

function activity.FlashCapsuleR(msg)
	print_r(msg)
end

proto.registFuncTbl("activity", activity)

local gashapon = {}
function gashapon.UserMakeGashaponR(msg)
	if msg.err == 10023 then
		g_player:testCall({code = 1, num = 50000}, "test", "addMoney")

		g_player:testCall({m_type = 2}, "gashapon", "UserMakeGashapon")
	end
end

proto.registFuncTbl("gashapon", gashapon)


local test = {}
function test.addItemR(msg)
	print("-------addItemR")
	print_r(msg)
end

function test.addPokemonR(msg)
	print("-------addPokemonR")
	print_r(msg)
end

proto.registFuncTbl("test", test)


local guild = {}
function guild.CreateGuildR(msg)
	print_r(msg)
	if msg.err == 10024 then
		g_player:testCall({code = 1, num = 50000}, "test", "addMoney")
	end
end

function guild.GetPlayerGuildR(msg)
	print_r(msg)
	local playerGuildId = msg.playerGuild.guildId

	g_player:testCall({id = playerGuildId, operationType = 5}, "guild", "GuildOperation")
end

function guild.GuildOperationR(msg)
	print_r(msg)
end

function guild.GetGuildBattleSubwayInfoR(msg)
	print_r(msg)
	if msg.err == 10111 then
		g_player:testCall({name = "独步天下", avatar = "default.png"}, "guild", "CreateGuild")
	end
end

function guild.GuildBattleSubwayInfoP(msg)
	print_r(msg)
end

function guild.ChallengeGuildBattleSubwayR(msg)
	print_r(msg)
end

function guild.GuildOperationR(msg)
	print_r(msg)
end

proto.registFuncTbl("guild", guild)


local champion = {}

function champion.ChampionBattleR(msg)
	print_r(msg)
end

proto.registFuncTbl("champion", champion)




-- Activity = 1,
-- SignInInfo = 2,
-- OnlineRewardInfo = 3,
-- GetActivityList = 4,
-- GetActivityListR = 5,
-- GetSignInInfo = 6,
-- GetSignInInfoR = 7,
-- SignIn = 8,
-- SignInR = 9,
-- GetOnlineRewardInfo = 10,
-- GetOnlineRewardInfoR = 11,
-- OnlineReward = 12,
-- OnlineRewardR = 13,
-- PushActivityUpdateP = 14,

