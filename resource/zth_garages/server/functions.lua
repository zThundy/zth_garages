

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
        "ALTER TABLE `player_vehicles` ADD `garage_id` VARCHAR(255) NOT NULL DEFAULT '' AFTER `status`;",
        -- -1 if the parking has unlimited spots
        "ALTER TABLE `player_vehicles` ADD `parking_spot` VARCHAR(255) NOT NULL DEFAULT '' AFTER `garage_id`;",
        "ALTER TABLE `player_vehicles` ADD `parking_date` DATETIME NOT NULL AFTER `parking_spot`;",
        "ALTER TABLE `player_vehicles` ADD `parking_until` DATETIME NOT NULL AFTER `parking_date`;",

        [[
            CREATE TABLE IF NOT EXISTS `garages` (
                `user_id` VARCHAR(255) NOT NULL,
                `garage_id` VARCHAR(255) NOT NULL,
                `balance` INT(11) NOT NULL DEFAULT '0',
                `total_earnings` INT(11) NOT NULL DEFAULT '0',
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]]
    }
    
    ZTH.MySQL.ExecQuery("create table if not exists and alter", MySQL.transaction.await, initTable)
end