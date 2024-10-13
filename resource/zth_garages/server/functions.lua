

function ZTH.MySQL.ExecQuery(msg, fn, query, parameters)
    local start = os.nanotime()
    local result = fn(query, parameters)
    local finish = os.nanotime()
 
    Debug(msg)
    Debug('Executed ' .. (type(query) == 'string' and 1 or #query) .. ' queries in ' .. (finish - start) / 1e6 .. 'ms')
 
    return result
end










function ZTH.Functions.Init()
    local initTable = {
        [[
            CREATE TABLE IF NOT EXISTS `zth_garages` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `name` varchar(255) NOT NULL,
                `label` varchar(255) NOT NULL,
                `coords` text NOT NULL,
                `garage_type` varchar(255) NOT NULL,
                `garage_state` varchar(255) NOT NULL,
                `garage_price` int(11) NOT NULL,
                `garage_owner` varchar(255) NOT NULL,
                `garage_plate` varchar(255) NOT NULL,
                `garage_vehicle` text NOT NULL,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
        ]]
    }
    
    ZTH.MySQL.ExecQuery("create table if not exists", MySQL.transaction.await, initTable)
end