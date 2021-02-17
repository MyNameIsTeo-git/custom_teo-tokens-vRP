local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "custom_teo-tokens")

--------------
-- COMMANDS --
--------------

-- COMMAND TO ADD TOKENS
RegisterCommand("addtokens", function (source, args, rawCommand)
    local _source = source
	local user_id = vRP.getUserId({_source})
	local player = vRP.getUserSource({user_id})  

	if args[1] ~= nil and args[2] ~= nil then
		local id = tonumber(args[1])
		local amount = tonumber(args[2])

		if id > 0 and amount > 0 then

			TriggerEvent("custom_teo-tokens:AddTokensFromDatabase", _source, id, amount)
		else

			vRPclient.notify(player, {"Enter a valid value!"})
		end
	else

		vRPclient.notify(player, {"You have not completed a field!"})
	end
end, true)

-- COMMAND TO REMOVE TOKENS
RegisterCommand("removetokens", function (source, args, rawCommand)
    local _source = source
	local user_id = vRP.getUserId({_source})
	local player = vRP.getUserSource({user_id})  

	if args[1] ~= nil and args[2] ~= nil then
		local id = tonumber(args[1])
		local amount = tonumber(args[2])

		if id > 0 and amount > 0 then

			TriggerEvent("custom_teo-tokens:RemoveTokensFromDatabase", _source, id, amount)
		else

			vRPclient.notify(player, {"Enter a valid value!"})
		end
	else

		vRPclient.notify(player, {"You have not completed a field!"})
	end
end, true)

-- COMMAND TO GET TOKENS
RegisterCommand("gettokens", function (source, args, rawCommand)
    local _source = source
	local user_id = vRP.getUserId({_source})
	local player = vRP.getUserSource({user_id})  
	
	if args[1] ~= nil then
		local id = tonumber(args[1]) 

		if id > 0 then

			TriggerEvent("custom_teo-tokens:GetTokensFromDatabase", _source, id)
		else

			vRPclient.notify(player, {"Enter a valid value!"})
		end
	elseif args[1] == nil or args[1] == "" then

		TriggerEvent("custom_teo-tokens:GetTokensFromDatabase", _source)
	end
end, true)

------------
-- EVENTS --
------------

-- CREATE ROW WHEN SPAWN
RegisterServerEvent('custom_teo-tokens:CreateRow')
AddEventHandler('custom_teo-tokens:CreateRow', function()
	local _source = source
	local name = GetPlayerName(_source)
	local identifier = Teo:GetSteamID(_source)

    local result = MySQL.Sync.fetchAll('SELECT `identifier` FROM tokens WHERE `identifier` = @identifier', {
        ['@identifier'] = identifier
    })

	if result then
		if result[1] == nil then
			MySQL.Async.execute('INSERT INTO tokens (`identifier`) VALUES (@identifier)', {
				['@identifier'] = identifier
			})
		end

		MySQL.Sync.execute('UPDATE tokens SET `name` = @name WHERE `identifier` = @identifier', { 
			['@identifier'] = identifier,
			['@name'] = name
		})
	end

	print(" \27[31mTokens\27[0m - Row Updated for [USER: " .. name .. "]")
end)

-- ADD TOKENS
RegisterServerEvent("custom_teo-tokens:AddTokensFromDatabase")
AddEventHandler("custom_teo-tokens:AddTokensFromDatabase", function(_source, id, amount)
	local name = GetPlayerName(id)
	local adminName = GetPlayerName(_source)
	local identifier = Teo:GetSteamID(id)
	local user_id = vRP.getUserId({_source})
	local player = vRP.getUserSource({user_id})  
	local target_user_id = vRP.getUserId({id})
	local target_player = vRP.getUserSource({target_user_id})  

	MySQL.Async.fetchAll('SELECT `n_tokens` FROM tokens WHERE `identifier` = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result then
			if result[1] then
				MySQL.Sync.execute('UPDATE tokens SET `n_tokens` = @n_tokens WHERE `identifier` = @identifier', { 
					['@identifier'] = identifier,
					['@n_tokens'] = result[1].n_tokens + amount
				})
			end
		end
	end)
	
	vRPclient.notify(player, {"You have added " .. amount .. " Tokens to ID " .. id})
	vRPclient.notify(target_player, {"You have had " .. amount .. " Tokens added!"})

	print(" \27[31mTokens\27[0m - Row Updated for [USER: " .. name .. "] by [ADMIN: " .. adminName .. "] | [COMMAND: Adding Tokens]")
end)

-- REMOVE TOKENS
RegisterServerEvent("custom_teo-tokens:RemoveTokensFromDatabase")
AddEventHandler("custom_teo-tokens:RemoveTokensFromDatabase", function(_source, id, amount)
	local name = GetPlayerName(id)
	local adminName = GetPlayerName(_source)
	local identifier = Teo:GetSteamID(id)
	local user_id = vRP.getUserId({_source})
	local player = vRP.getUserSource({user_id})  
	local target_user_id = vRP.getUserId({id})
	local target_player = vRP.getUserSource({target_user_id})  

	MySQL.Async.fetchAll('SELECT `n_tokens` FROM tokens WHERE `identifier` = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result then
			if result[1].n_tokens < amount then
				MySQL.Sync.execute('UPDATE tokens SET `n_tokens` = @n_tokens WHERE `identifier` = @identifier', { 
					['@identifier'] = identifier,
					['@n_tokens'] = 0
				})
			else
				MySQL.Sync.execute('UPDATE tokens SET `n_tokens` = @n_tokens WHERE `identifier` = @identifier', { 
					['@identifier'] = identifier,
					['@n_tokens'] = result[1].n_tokens - amount
				})
			end
		end
	end)

	vRPclient.notify(player, {"You have removed " .. amount .. " Tokens from ID " .. id})
	vRPclient.notify(target_player, {"You have had " .. amount .. " Tokens removed!"})

	print(" \27[31mTokens\27[0m - Row Updated for [USER: " .. name .. "] by [ADMIN: " .. adminName .. "] | [COMMAND: Removing Tokens]")
end)

-- GET TOKENS
RegisterServerEvent("custom_teo-tokens:GetTokensFromDatabase")
AddEventHandler("custom_teo-tokens:GetTokensFromDatabase", function(_source, id)
	local name = GetPlayerName(id)
	local identifier = Teo:GetSteamID(id)
	local user_id = vRP.getUserId({_source})
	local player = vRP.getUserSource({user_id})  

	local result = MySQL.Sync.fetchAll('SELECT `n_tokens` FROM tokens WHERE `identifier` = @identifier', {
		['@identifier'] = identifier
	})

	if result then
		if result[1] ~= nil then
			local n_tokens = result[1].n_tokens
	
			vRPclient.notify(player, {name .. " has " .. n_tokens .. " Tokens!"})
		end
	end
end)

-- ADD TOKENS WITH EVENT
RegisterServerEvent("custom_teo-tokens:AddTokensEvent")
AddEventHandler("custom_teo-tokens:AddTokensEvent", function(amount)
	local _source = source
	local identifier = Teo:GetSteamID(_source)
	local user_id = vRP.getUserId({_source})
	local player = vRP.getUserSource({user_id})

	MySQL.Async.fetchAll('SELECT `n_tokens` FROM tokens WHERE `identifier` = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result then
			if result[1] then
				MySQL.Sync.execute('UPDATE tokens SET `n_tokens` = @n_tokens WHERE `identifier` = @identifier', { 
					['@identifier'] = identifier,
					['@n_tokens'] = result[1].n_tokens + amount
				})
			end
		end
	end)
	
    vRPclient.notify(player, {"You have earned " .. amount .. " Tokens!"})
end)

-- REMOVE TOKENS WITH EVENT
RegisterServerEvent("custom_teo-tokens:RemoveTokensEvent")
AddEventHandler("custom_teo-tokens:RemoveTokensEvent", function(amount)
	local _source = source
	local identifier = Teo:GetSteamID(_source)
	local user_id = vRP.getUserId({_source})
	local player = vRP.getUserSource({user_id})

	MySQL.Async.fetchAll('SELECT `n_tokens` FROM tokens WHERE `identifier` = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result then
			if result[1].n_tokens < amount then
				MySQL.Sync.execute('UPDATE tokens SET `n_tokens` = @n_tokens WHERE `identifier` = @identifier', { 
					['@identifier'] = identifier,
					['@n_tokens'] = 0
				})
			else
				MySQL.Sync.execute('UPDATE tokens SET `n_tokens` = @n_tokens WHERE `identifier` = @identifier', { 
					['@identifier'] = identifier,
					['@n_tokens'] = result[1].n_tokens - amount
				})
			end
		end
	end)
	
    vRPclient.notify(player, {"You have lost " .. amount .. " Tokens!"})
end)