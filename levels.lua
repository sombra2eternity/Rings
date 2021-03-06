rings_levels = {}
rings_levels.exp = {}
rings_levels.exp['mobs_mc:wolf']     = 1
rings_levels.exp['mobs_mc:spider']   = 8
rings_levels.exp['mobs_mc:skeleton'] = 10
rings_levels.exp['mobs_mc:zombie']   = 10
rings_levels.exp['mobs_mc:husk']     = 10
rings_levels.exp['mobs_mc:enderman'] = 20

rings_levels.npc = {}
rings_levels.npc['rings:dinieras_ves'] = true

--fixme esto debe ir a chars o algo asi
minetest.after(0,function()
	local counter = {};

	for _,ent in pairs(minetest.object_refs) do 
		--ent:remove()
		local obj = ent:get_luaentity()
		if obj ~= nil and obj.name ~= nil then
			if counter[obj.name] == nil then
				counter[obj.name] = 1
			else
				counter[obj.name] = counter[obj.name] + 1
			end
			if obj.name == 'rings:dinieras_ves' then
				print(dump(obj.name))
			end
		end
	end

	if counter['rings:dinieras_ves'] == nil then
		print(dump("Adding rings:dinieras_ves to set of monsters."))
		--minetest.add_entity({x=11, y=25, z=39},"rings:dinieras_ves")
	end
end)

cmi.register_on_activatemob(function(mob,dtime)
	local name = mob:get_luaentity().name
	print(dump("added " .. name))

	-- Check named
	if rings_levels.npc[name] ~= nil then
		local old_status = datastorage.key_get("___npcs_status",name)
		if old_status ~= "alive" then
			-- print(dump("status set: " .. name))
			datastorage.key_set("___npcs_status",name,"alive")
			print(dump(datastorage.data["___npcs_status"]))
		else
			-- remove duplicates
			mob:remove();
		end
	end
end)

cmi.register_on_diemob(function(mob,cause)
	if cause.type == 'punch'
	 and cause.puncher ~= nil
	 and cause.puncher:is_player() then
		local name = mob:get_luaentity().name

		-- Check named
		if rings_levels.npc[name] ~= nil then
			datastorage.key_set("___npcs_status",name,"dead")
		end

		print(dump("killed " .. name))
		if rings_levels.exp[name] ~= nil then
			rings_player.experience_add(cause.puncher,rings_levels.exp[name]);
		end
	end
end)

minetest.after(2.5,function()
	local ents = minetest.registered_entities
	local monsters = {}

	for _,ent in pairs(ents) do 
		if ent.hp_max ~= nil and ent.hp_max > 0 and ent.damage ~= nil and ent.damage > 0 then
			table.insert(monsters,ent)
			print(dump("Adding " .. ent.name .. " to set of monsters."))
		end
	end

	for _,monster in pairs(monsters) do
		if false then --disabled
			if monster.on_punch ~= nil then
				monster._old_on_punch = monster.on_punch;
			end
			monster.on_punch = function(self,player,tflp,tool_capabilities,dir)
				if self._old_on_punch ~= nil then
					self._old_on_punch(self,player,tflp,tool_capabilities,dir)
				end

				if player and player:is_player() then
					if self.health < 1 then
						minetest.log('error','killed '..self.name,event);

						if rings_levels.exp[self.name] ~= nil then
							rings_player.experience_add(player,rings_levels.exp[self.name]);
						end
					end
					-- print(dump("Monster punched by: " .. player:get_player_name()))
					-- print(dump("Monsters current hitpoints: " .. self.health .. " and max hp was " .. self.hp_max))
				end
			end
		end
	end


end)
