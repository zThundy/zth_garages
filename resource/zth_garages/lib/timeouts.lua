
local timeout = nil
-- if SERVER then
--     timeout = {}
-- else
--     timeout = {}
-- end

addTimeout = function(source, time, finishCb, dparams)
    if SERVER then
        if not timeout or (timeout[source] == nil and timeout[source].done) then
            Debug("addTimeout on SERVER: " .. source .. " - " .. time)
            if not timeout then timeout = {} end
            timeout[source] = {}
            
            timeout[source].done = false
            timeout[source].finish = function(params)
                Debug("timeout.finish on SERVER: " .. source .. " - " .. time)
                if not timeout[source].done then
                    if params == nil then params = dparams or {} end
                    timeout[source].done = true
                    if finishCb then finishCb(table.unpack(params)) end
                end
            end
            setmetatable(timeout[source], {__call = function(t,params) timeout[source].finish(params) end })
            SetTimeout(time, function() timeout[source].finish(dparams) end)
            return timeout[source]
        else
            return timeout[source]
        end
    else
        if not timeout or timeout.done then
            Debug("addTimeout on CLIENT: " .. time)
            timeout = {}

            timeout.done = false
            timeout.finish = function(params)
                Debug("timeout.finish on CLIENT: " .. time)
                if not timeout.done then
                    if params == nil then params = dparams or {} end
                    timeout.done = true
                    if finishCb then finishCb(table.unpack(params)) end
                end
            end
            setmetatable(timeout, {__call = function(t,params) timeout.finish(params) end })
            SetTimeout(time, function() timeout.finish(dparams) end)
            return timeout
        else
            return timeout
        end
    end
end

hasTimeout = function(source)
    if SERVER then
        if timeout[source] == nil or timeout[source].done then
            Debug("hasTimeout on SERVER: " .. source .. " - false")
            return false
        else
            Debug("hasTimeout on SERVER: " .. source .. " - true")
            return true
        end
    else
        if timeout == nil or timeout.done then
            Debug("hasTimeout on CLIENT: false")
            return false
        else
            Debug("hasTimeout on CLIENT: true")
            return true
        end
    end
end