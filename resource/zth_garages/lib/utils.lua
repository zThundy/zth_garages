
local modules = {}
-- side detection
SERVER = IsDuplicityVersion()
CLIENT = not SERVER

function Debug(msg)
    if ZTH.Config.Debug and ZTH.Config.Debug.enabled then
        print(ZTH.Config.Debug.prefix .. " ^0" .. msg)

        if SERVER then
            -- check if log.txt exists, if not create it
            if not LoadResourceFile(GetCurrentResourceName(), "log.txt") then
                SaveResourceFile(GetCurrentResourceName(), "log.txt", "", -1)
            end
            -- append to log file
            local logFile = LoadResourceFile(GetCurrentResourceName(), "log.txt")
            -- remove ^0 ^1 etc
            msg = msg:gsub("%^(%d)", "")
            SaveResourceFile(GetCurrentResourceName(), "log.txt", logFile .. "[" .. os.date("%Y-%m-%d %H:%M:%S") .. "] " .. msg .. "\n", -1)
        end
    end
end

function Conditional(statement, ifTrue, ifFalse)
    if statement then
        return ifTrue
    else
        return ifFalse
    end
end

function module(rsc, path) -- load a LUA resource file as module
    if path == nil then -- shortcut for vrp, can omit the resource parameter
        path = rsc
        rsc = GetCurrentResourceName()
    end

    local key = rsc..path

    if modules[key] then -- cached module
        return table.unpack(modules[key])
    else
        Debug("Loading module "..rsc.."/"..path)
        local f, err = load(LoadResourceFile(rsc, path..".lua"))
        if f then
            local ar = { pcall(f) }
            if ar[1] then
                table.remove(ar, 1)
                modules[key] = ar
                return table.unpack(ar)
            else
                modules[key] = nil
                Debug("Error loading module "..rsc.."/"..path..":"..ar[2])
            end
        else
            Debug("Error parsing module "..rsc.."/"..path..":"..err)
        end
    end
end

-- generate a task metatable (helper to return delayed values with timeout)
-- @dparams: default params in case of timeout or empty cbr()
-- @timeout: milliseconds, default 5000
function Task(callback, dparams, timeout) 
    if timeout == nil then timeout = 5000 end
    local r = {}
    r.done = false
    local finish = function(params) 
        if not r.done then
            if params == nil then params = dparams or {} end
            r.done = true
            callback(table.unpack(params))
        end
    end
    setmetatable(r, {__call = function(t,params) finish(params) end })
    SetTimeout(timeout, function() finish(dparams) end)
    return r
end

function DumpTable(table, nb)
	if nb == nil then
		nb = 0
	end

	if type(table) == 'table' then
		local s = ''
		for i = 1, nb + 1, 1 do
			s = s .. "    "
		end

		s = '{\n'
		for k,v in pairs(table) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			for i = 1, nb, 1 do
				s = s .. "    "
			end
			s = s .. '['..k..'] = ' .. DumpTable(v, nb + 1) .. ',\n'
		end

		for i = 1, nb, 1 do
			s = s .. "    "
		end

		return s .. '}'
	else
		return tostring(table)
	end
end

function DuplicateTable(tb)
    if type(obj) ~= 'table' then return obj end
    -- if seen and seen[obj] then return seen[obj] end
    -- local s = seen or {}
    local s = {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[DuplicateTable(k, s)] = DuplicateTable(v, s) end
    return res
end

local function areturn(self, ...)
    self.r = {...}
    self.p:resolve(self.r)
end

-- create an async returner or a thread (Citizen.CreateThreadNow)
-- func: if passed, will create a thread, otherwise will return an async returner
function async(func)
    if func then
        Citizen.CreateThreadNow(func)
    else
        return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
    end
end

function wait(self)
    local rets = Citizen.Await(self.p)

    if not rets then
        if self.r then
            rets = self.r
        else
            Debug("async wait(): Citizen.Await returned (nil) before the areturn call.")
        end
    end
  
    return table.unpack(rets, 1, table_maxn(rets))
end

-- table.maxn replacement
function table_maxn(t)
    local max = 0
    for k, v in pairs(t) do
        local n = tonumber(k)
        if n and n > max then max = n end
    end
    return max
end

local increment = 0
function MakeRandomString(length)
    increment = increment + 1
    if SERVER then math.randomseed(os.time() + increment) end
    if CLIENT then math.randomseed(GetGameTimer() + increment) end
    local character_set = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    local string_sub = string.sub
    local math_random = math.random
    local table_concat = table.concat
    local character_set_amount = #character_set
    local number_one = 1
    local default_length = 10

    local random_string = {}
    for int = number_one, length or default_length do
        local random_number = math_random(number_one, character_set_amount)
        local character = string_sub(character_set, random_number, random_number)
        random_string[#random_string + number_one] = character
    end

    return table_concat(random_string)
end

function MakeRandomNumber(length)
    increment = increment + 1
    if SERVER then math.randomseed(os.time() + increment) end
    if CLIENT then math.randomseed(GetGameTimer() + increment) end
    local character_set = "0123456789"

    local string_sub = string.sub
    local math_random = math.random
    local table_concat = table.concat
    local character_set_amount = #character_set
    local number_one = 1
    local default_length = 10

    local random_string = {}

    for int = number_one, length or default_length do
        local random_number = math_random(number_one, character_set_amount)
        local character = string_sub(character_set, random_number, random_number)

        random_string[#random_string + number_one] = character
    end

    return table_concat(random_string)
end

function ConditionalDates(date1, date2)
    Debug("Parsing dates " .. date1 .. " and " .. date2)
    -- get imput two os.time(), convert them to os.date and compare the single elements of the date
    local d1 = os.date("*t", date1)
    local d2 = os.date("*t", date2)

    if type(d1.year) ~= "number" then d1.year = tonumber(d1.year) end
    if type(d2.year) ~= "number" then d2.year = tonumber(d2.year) end
    if type(d1.month) ~= "number" then d1.month = tonumber(d1.month) end
    if type(d2.month) ~= "number" then d2.month = tonumber(d2.month) end
    if type(d1.day) ~= "number" then d1.day = tonumber(d1.day) end
    if type(d2.day) ~= "number" then d2.day = tonumber(d2.day) end
    if type(d1.hour) ~= "number" then d1.hour = tonumber(d1.hour) end
    if type(d2.hour) ~= "number" then d2.hour = tonumber(d2.hour) end
    if type(d1.min) ~= "number" then d1.min = tonumber(d1.min) end
    if type(d2.min) ~= "number" then d2.min = tonumber(d2.min) end
    if type(d1.sec) ~= "number" then d1.sec = tonumber(d1.sec) end
    if type(d2.sec) ~= "number" then d2.sec = tonumber(d2.sec) end

    if d1.year >= d2.year then
        Debug("Year is greater or equal " .. d1.year .. " >= " .. d2.year)
        if d1.month >= d2.month then
            Debug("Month is greater or equal " .. d1.month .. " >= " .. d2.month)
            if d1.day >= d2.day then
                Debug("Day is greater or equal " .. d1.day .. " >= " .. d2.day)
                return true
            end
            return false
        end
        return false
    end
    return false
end

function L(key, ...)
    if ZTH.Locale[key] then
        return string.format(ZTH.Locale[key], ...)
    else
        return key
    end
end

if SERVER then
    function GetAccountMoney(account)
        if ZTH.Config.AccountScript == "qb-bossmenu" then
            return exports[ZTH.Config.AccountScript]:GetAccount(account)
        elseif ZTH.Config.AccountScript == "qb-banking" then
            return exports[ZTH.Config.AccountScript]:GetAccountBalance(account)
        elseif ZTH.Config.AccountScript == "esx_society" then
            return exports[ZTH.Config.AccountScript]:GetAccount(account)
        end
    end

    function AddAccountMoney(account, amount)
        if ZTH.Config.AccountScript == "qb-bossmenu" then
            return exports[ZTH.Config.AccountScript]:AddAccountMoney(account, amount)
        elseif ZTH.Config.AccountScript == "qb-banking" then
            return exports[ZTH.Config.AccountScript]:AddAccountMoney(account, amount)
        elseif ZTH.Config.AccountScript == "esx_society" then
            return exports[ZTH.Config.AccountScript]:AddAccountMoney(account, amount)
        end
    end

    function RemoveAccountMoney(account, amount)
        if ZTH.Config.AccountScript == "qb-bossmenu" then
            return exports[ZTH.Config.AccountScript]:RemoveMoney(account, amount)
        elseif ZTH.Config.AccountScript == "qb-banking" then
            return exports[ZTH.Config.AccountScript]:RemoveMoney(account, amount)
        elseif ZTH.Config.AccountScript == "esx_society" then
            return exports[ZTH.Config.AccountScript]:RemoveMoney(account, amount)
        end
    end
end

local Luaoop = module("zth_garages", "lib/Luaoop")
class = Luaoop.class