-- Combat mod
-- Author  Van (VanicGame)
-- Version 2.2
-- License WTFPL

-- Сколько процентов неполного урона будет наносится
local DAMAGE_MOD = 0.25
-- Порог меньше которого урон будет равен нулю
local NULL_LIMIT = 0.6

combat_api = {}

combat_api.punch = function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if (not player) or (not hitter) or (not tool_capabilities) then
		return
	end

	-- Если атакующий не игрок
	if not hitter:is_player() then
		return
	end

	-- Если игрок уже мертв
	if player:get_hp() <= 0 then
		return
	end

	-- Расчет урона
	local damage = 0
	if tool_capabilities.damage_groups then
		print(tool_capabilities.damage_groups)
	end
	for group, value in pairs(tool_capabilities.damage_groups) do
		damage = damage + tool_capabilities.damage_groups[group]*(player:get_armor_groups()[group] / 100.0)
	end

	-- Если время больше куллдауна - весь урон
	if tool_capabilities.full_punch_interval < time_from_last_punch then
		damage = damage
	-- Если время меньше NULL_LIMIT куллдауна - ноль урона
	elseif time_from_last_punch/tool_capabilities.full_punch_interval < NULL_LIMIT then
		damage = 0
	-- Если время больше NULL_LIMIT, но меньше куллдауна
	elseif time_from_last_punch/tool_capabilities.full_punch_interval > NULL_LIMIT then
		damage = damage*DAMAGE_MOD
	end

	player:set_hp(player:get_hp()-damage, "punch")

	-- Отбрасывание
	player:add_velocity({
		x = dir.x*damage,
		y = 1*damage,
		z = dir.z*damage,
	})

	return true
end

minetest.register_on_punchplayer(combat_api.punch)
