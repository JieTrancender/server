
--shencyx@qq.com
--

--module("util", package.seeall) 5.3不再支持module
local tbl = {}

function tbl.add_path(path)
	package.path = package.path.. ";"..path
end

function tbl.table_dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

function tbl.tablePrint(value,fmt,tabnum)
    local num = tabnum or 1
    local fmt = fmt or '\t'
    if type(value) =="table" then
        local left = fmt .. '{'
        local right = fmt .. '}' ..','
        local newfmt = fmt .. '\t'
        if num<= 1 then
            left = '{'
            right = '}'
            newfmt = fmt
        end

        print (left)
        for k,v in pairs(value) do
            if type(v) == "table" then
                print(newfmt..k.. " = ")
                tbl.tablePrint(v,newfmt,num+1)
            else
                if type(k) == "string" then
                    print(newfmt..'"'..k..'"'.." = " .. v .. ',')
                else
                    print(newfmt..k.." = " .. v .. ',')
                end
            end
        end
        print(right)
    end
end

--设置位
function tbl.setIntBit(num, bitPos, bBit)
    if bBit then
        num = num | (0x1 << bitPos)
    else
        num = num & ~(0x1 << bitPos)
    end
    return num
end

--获取位
function tbl.getIntBit(num, bitPos)
    return (num >> bitPos) & 0x1
end

--设置字节
function tbl.setIntByte(num, bytePos, byteValue)
    if bytePos == 0 then
        return (num & 0xffffff00) | byteValue
    elseif bytePos == 1 then
        return (num & 0xffff00ff) | (byteValue << 8)
    elseif bytePos == 2 then
        return (num & 0xff00ffff) | (byteValue << 16)
    elseif bytePos == 3 then
        return (num & 0x00ffffff) | (byteValue << 24)
    end
end

--获取字节
function tbl.getIntByte(num, bytePos)
    if bytePos == 0 then
        return (num & 0x000000ff)
    elseif bytePos == 1 then
        return (num & 0x0000ff00) >> 8
    elseif bytePos == 2 then
        return (num & 0x00ff0000) >> 16
    elseif bytePos == 3 then
        return (num & 0xff000000) >> 24
    end
end

--      权重列表随机
--
--      list = {[1]={key=1000},
--              [2]={key=2000},
--              ... 
--              }
--      key为字段名字字符串
--      按照权重概率随机,返回随机出来的index
function tbl.randomOne( list, key )
    local sum = 0

    for _,t in pairs(list) do
        sum = sum + t[key]
    end

    local rand = random(1,sum)

    for k,t in pairs(list) do
        rand = rand - t[key]
        if rand <= 0 then
            return k
        end
    end
    -- body
end

return tbl