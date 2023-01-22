local http = require("http.request")
local lunajson = require("lunajson")
local gears = require("gears")
local naughty = require("naughty")
local inspect = require("inspect")

local lol_api_url = "https://euw1.api.riotgames.com"
local summoner_api_url = lol_api_url .. "/lol/summoner/v4/summoners/by-name/"
local spectator_api_url = lol_api_url .. "/lol/spectator/v4/active-games/by-summoner/"
local secrets = require("lolfriends_notify.secrets")

local M = {}

local get_summoner_api_url = function(summoner_name)
	return summoner_api_url .. summoner_name .. "?api_key=" .. secrets.api_key
end

local get_spectator_api_url = function(summoner_id)
	return spectator_api_url .. summoner_id .. "?api_key=" .. secrets.api_key
end

local get_summoner_id_by_summoner_name = function(summoner_name)
	local _, stream = assert(http.new_from_uri(get_summoner_api_url(summoner_name)):go())
	local body = assert(stream:get_body_as_string())
	return lunajson.decode(body)
end

local get_all_summoner_ids = function()
	local _summoner_ids = {}
	for _, summoner_name in pairs(secrets.friendlist) do
		local response = get_summoner_id_by_summoner_name(summoner_name:gsub(" ", "%%20"))
		table.insert(_summoner_ids, response["id"])
	end
	return _summoner_ids
end

local track_summoner_game = function(status, summoner_name, game_tracking)
	if status == "200" then
		game_tracking[summoner_name] = true
		return true
	else
		if game_tracking[summoner_name] then
			naughty.notify({ text = summoner_name .. " finished the game." })
		end
		game_tracking[summoner_name] = false
		return true
	end
end

local init_game_tracking = function(friendlist)
	local is_ingame_list = {}
	for _, summoner_name in pairs(friendlist) do
		is_ingame_list[summoner_name] = false
	end
	return is_ingame_list
end

M.setup = function()
	local summoner_ids = get_all_summoner_ids()
	local tracking_list = init_game_tracking(secrets.friendlist)
	local continue_timer = true
	gears.timer.start_new(12, function()
		for key, summoner_id in pairs(summoner_ids) do
			local headers, _ = assert(http.new_from_uri(get_spectator_api_url(summoner_id)):go())
			continue_timer = track_summoner_game(headers:get(":status"), secrets.friendlist[key], tracking_list)
		end
		return continue_timer
	end)
end

return M

-- naughty.notify({ text = "Wow " .. print(inspect(gears.timer.timer)) })
