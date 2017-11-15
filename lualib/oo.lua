local tbl = {}

local classList = {}  -- 类列表
local classBase = {}  -- 基类

-- default construnctor
function classBase:__init( obj )
end

-- isa operator
function classBase:isa( clazz )
	local c = classof(self)
	while c and c ~= classBase do
		if c == clazz then return true end
		c = superclassof(c)
	end

	return false
end

local function new(clz, ...)
	local obj = {}
	local mt = rawget(clz, "_mt_")
	if not mt then
		mt = {
			__index = clz,
			__tostring = clz.__tostring,
			__gc = clz.__gc,
		}

		rawset(clz, "_mt_", mt)
	end

	setmetatable(obj, mt)
	obj:__init(...)

	return obj
end

function tbl.class( super, name )
	local clz = {}
	if type(name) == "string" then
		local class_name = name .. '__'
		if classList[class_name] ~= nil then
			print(">>>>>>>>>>>>>>>>>oo.class repeat, is hot update ? class: ", name)
			clz = classList[class_name]
			for k, v in pairs(clz) do
				clz[k] = nil
			end
		else
			classList[class_name] = clz
		end
	else
		error("Error:class name is error!")
	end

	super = super or classBase
	rawset(clz, "__super", super)
	setmetatable(clz, {__index = super, __call = new})

	return clz
end

function tbl.superclassof( clz )
	return rawget(clz, "__super")
end

function tbl.classof( obj )
	return getmetatable(obj).__index
end

function tbl.instanceof( obj, clz )
	return ((obj.isa and obj:isa(clz)) == true)
end

return tbl











