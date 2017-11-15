require "common"

local skynet = require "skynet"
local sharedata = require "sharedata"
local random = random


-- 这些配置不用放在sharedata里面
local no_shared = {
	
}

ConfigMgr = oo.class(nil, "ConfigMgr")

function ConfigMgr:__init( ... )
	self._list = {}  -- {key:filename, value:obj}
end

-- 因为加入了sharedata, 所以不需要每个服务去加载配置，只需要在启动的时候调用就可以了
function ConfigMgr:loadConfig( fileName )
	if no_shared[filename] then return end
	local conf = require(fileName .. "_config")

	sharedata.new(fileName, conf)
end

function ConfigMgr:getConfig( fileName )
	local conf = self._list[fileName]
	if conf == nil then
		if no_shared[fileName] then
			conf = require(fileName .. "_config")
		else
			conf = sharedata.query(fileName)
		end

		self._list[fileName] = conf
	end

	return config
end

function ConfigMgr:loadAll()
	self:loadConfig("enum")
	self:loadConfig("error_code")
	self:loadConfig("const")
end

-- 热更新配置
function ConfigMgr:updateConfig( fileName )
	self:noShared(fileName)
	local mod = fileName .. "_config"
	package.loaded[mod] = nil
	local conf = require(mod)
	sharedata.update(fileName, conf)
	log("updateConf:", fileName)
end

function ConfigMgr:getSource( key )
	local conf = self:getConfig("source")
	if conf[key] then
		return conf[key].desc
	else
		log("warning: t_source do not have source:", key)
		return "未知来源"
	end
end

function ConfigMgr:getBuyCost( type, num )
	local buyCount = self:getConfig("public").buyCost
	if not buyCount[type] then
		log("ConfigMgr:getBuyCost, unknow module type", type)
		return "unknow module type"
	end

	local total = #buyCount[type]
	num = total < num and total or num
	return buyCount[type][num]
end

-- 创建全局对象
if g_configMgr == nil then
	g_configMgr = ConfigMgr()
end
