--Legendsmith#1107 on discord
--Join the GURPS discord server for Q&A http://discord.gg/89yqtsx

--init
function onInit()
	Comm.registerSlashHandler("importcharlua", importCharlua)
	chars = docharacters()
end

--
function weightToNum(s)
	local a,b = string.gsub(s, "[a-z ,]", "")
	return tonumber(a)
end

function reEncode(s)
	s = s or "error/field blank"
	local a,b = string.gsub(s, "&quot;", "\"")
	a,b = string.gsub(a, "&#8224;", "th")
	a,b = string.gsub(a, "&#8225;", "thU")
	a,b = string.gsub(a, "&amp;", "&")
	return a
end

function split(str, pat) -- from http://lua-users.org/wiki/SplitJoin
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function rslConverter(s) --used in skills and spells for parsing the RSL field from GCS. function matches the base attribute abbreviation, or substitutes T for techniques when not found.
	if string.sub(s,1,1) == ("+" or "-") then
		return "T"
	else
		return string.match(s,"([A-Z]*[a-z]*)") or "10"
	end
end
--main importer function
function importCharlua(fun_name,_char_num)
	local char_num= tonumber(_char_num)
	if char_num then
		Comm.addChatMessage({text="importing character "..chars[char_num]["name"]})
	else
		Comm.addChatMessage({text="character not found"})
		return ""
	end
	local luasheet = chars[char_num]

	local nodeChar = DB.createChild("charsheet")
	DB.setValue(nodeChar, "name", "string", luasheet.name )
	--points
	DB.createChild(nodeChar,"pointtotals")
	DB.setValue(nodeChar, "pointtotals.ads","number",luasheet.pointsbreakdown.advantages)
	DB.setValue(nodeChar, "pointtotals.disads","number",luasheet.pointsbreakdown.disadvantages)
	DB.setValue(nodeChar, "pointtotals.others","number",luasheet.pointsbreakdown.race)
	DB.setValue(nodeChar, "pointtotals.attributes","number",luasheet.pointsbreakdown.attributes)
	DB.setValue(nodeChar, "pointtotals.quirks","number",luasheet.pointsbreakdown.quirks)
	DB.setValue(nodeChar, "pointtotals.skills","number",luasheet.pointsbreakdown.skills)
	DB.setValue(nodeChar, "pointtotals.spells","number",luasheet.pointsbreakdown.spells)
	DB.setValue(nodeChar, "pointtotals.totalpoints","number",luasheet.points)
	DB.setValue(nodeChar, "pointtotals.unspentpoints","number",luasheet.pointsbreakdown.unspent)

	--branch creation
	DB.createChild(nodeChar,"attributes") --create attributes branch
	DB.createChild(nodeChar,"combat") --create combat branch
	DB.createChild(nodeChar,"traits") --create traits branch
	--attributes population
	DB.setValue(nodeChar, "attributes.strength", "number", luasheet.ST.stat );--1 is value of the attribute, 
	DB.setValue(nodeChar, "attributes.strength_points", "number", luasheet.ST.pts );
	DB.setValue(nodeChar, "attributes.dexterity", "number", luasheet.DX.stat );
	DB.setValue(nodeChar, "attributes.dexterity_points", "number", luasheet.DX.pts );
	DB.setValue(nodeChar, "attributes.intelligence", "number", luasheet.IQ.stat );
	DB.setValue(nodeChar, "attributes.intelligence_points", "number", luasheet.IQ.pts );
	DB.setValue(nodeChar, "attributes.health", "number", luasheet.HT.stat );
	DB.setValue(nodeChar, "attributes.health_points", "number", luasheet.HT.pts );
	DB.setValue(nodeChar, "attributes.hitpoints", "number", luasheet.HP.stat );
	DB.setValue(nodeChar, "attributes.hitpoints_points", "number", luasheet.HP.pts );
	DB.setValue(nodeChar, "attributes.fatiguepoints", "number", luasheet.FP.stat );
	DB.setValue(nodeChar, "attributes.fatiguepoints_points", "number", luasheet.FP.pts );
	DB.setValue(nodeChar, "attributes.will", "number", luasheet.will.stat );
	DB.setValue(nodeChar, "attributes.will_points", "number", luasheet.will.pts );
	DB.setValue(nodeChar, "attributes.perception", "number", luasheet.per.stat );
	DB.setValue(nodeChar, "attributes.perception_points", "number", luasheet.per.pts );
	--Not sure i.f the DB will automatically convert the number to string because
	--the exporter is exporting speed as a float
	DB.setValue(nodeChar, "attributes.basiclift", "string", luasheet.bl);
	DB.setValue(nodeChar, "attributes.basicspeed", "string", luasheet.speed.stat);
	DB.setValue(nodeChar, "attributes.basicspeed_points", "number", luasheet.speed.pts);
	DB.setValue(nodeChar, "attributes.basicmove", "string", luasheet.move.stat);
	DB.setValue(nodeChar, "attributes.basicmove_points", "number", luasheet.move.pts);
	--should work
	DB.setValue(nodeChar, "attributes.swing", "string", luasheet.sw);
    DB.setValue(nodeChar, "attributes.thrust", "string", luasheet.thr);
    --not exporting the current HP and FP yet, but this should deal with it.
    DB.setValue(nodeChar, "attributes.fps", "number", (tonumber(luasheet.cFP) or 0));
    DB.setValue(nodeChar, "attributes.hps", "number", (tonumber(luasheet.cHP) or 0));
    DB.setValue(nodeChar, "attributes.current_move", "string", "");
    DB.setValue(nodeChar, "combat.block", "number", tonumber(luasheet.cBlock) or 0);
    DB.setValue(nodeChar, "combat.parry", "number", tonumber(luasheet.cParry) or 0);
    DB.setValue(nodeChar, "combat.dodge", "number", luasheet.cDodge or 0);
    --should work, i.f not it's 0
    DB.setValue(nodeChar, "combat.dr", "string", luasheet.dr.torso or 0)
    DB.createChild(nodeChar, "encumbrance")
    if luasheet.enc then
    	--encumbrance dodge
    	DB.setValue(nodeChar, "encumbrance.enc0_dodge", "number", luasheet.enc[1].dodge or 0);
    	DB.setValue(nodeChar, "encumbrance.enc1_dodge", "number", luasheet.enc[2].dodge or 0);
    	DB.setValue(nodeChar, "encumbrance.enc2_dodge", "number", luasheet.enc[3].dodge or 0);
    	DB.setValue(nodeChar, "encumbrance.enc3_dodge", "number", luasheet.enc[4].dodge or 0);
    	DB.setValue(nodeChar, "encumbrance.enc4_dodge", "number", luasheet.enc[5].dodge or 0);
    	--encumbrance move
    	DB.setValue(nodeChar, "encumbrance.enc0_move", "string", luasheet.enc[1].move or 0);
    	DB.setValue(nodeChar, "encumbrance.enc1_move", "string", luasheet.enc[2].move or 0);
    	DB.setValue(nodeChar, "encumbrance.enc2_move", "string", luasheet.enc[3].move or 0);
    	DB.setValue(nodeChar, "encumbrance.enc3_move", "string", luasheet.enc[4].move or 0);
    	DB.setValue(nodeChar, "encumbrance.enc4_move", "string", luasheet.enc[5].move or 0);
    	--encumbrance weight
    	DB.setValue(nodeChar, "encumbrance.enc0_weight", "string", luasheet.enc[1].max or 0);
    	DB.setValue(nodeChar, "encumbrance.enc1_weight", "string", luasheet.enc[2].max or 0);
    	DB.setValue(nodeChar, "encumbrance.enc2_weight", "string", luasheet.enc[3].max or 0);
    	DB.setValue(nodeChar, "encumbrance.enc3_weight", "string", luasheet.enc[4].max or 0);
    	DB.setValue(nodeChar, "encumbrance.enc4_weight", "string", luasheet.enc[5].max or 0);
    	
    end
   if luasheet.description then
   	 DB.setValue(nodeChar, "traits.race", "string", reEncode(luasheet.description.race));
   	 DB.setValue(nodeChar, "traits.age", "string", reEncode(luasheet.description.age));
   	 DB.setValue(nodeChar, "traits.height", "string", reEncode(luasheet.description.height));
   	 DB.setValue(nodeChar, "traits.weight", "string", reEncode(luasheet.description.weight));
   	 DB.setValue(nodeChar, "traits.sizemodifier", "string", reEncode(luasheet.description.size));
   	 DB.setValue(nodeChar, "traits.tl", "string", luasheet.description.tl);
   	 DB.setValue(nodeChar, "traits.tl_points", "number", 0);
   	 DB.setValue(nodeChar, "traits.appearance", "string", reEncode("Auto appearance: "..reEncode(luasheet.description.hair).." hair; "..reEncode(luasheet.description.eyes).." eyes;"..reEncode(luasheet.description.skin).." skin."));

	end
	--add & fill advantages
	local nodeAds = DB.createChild(nodeChar, "traits.adslist")
	if luasheet.advantages then
		for k,v in pairs(luasheet.advantages) do --is it a language?
			if string.find(v.name, "Language:") then
		else
			local nodeNew = DB.createChild(nodeAds);
			DB.setValue(nodeNew, "name", "string", v.name);
			DB.setValue(nodeNew, "points", "number", v.pts or 0);
			if v.modifiers and v.notes then
				DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
				elseif v.modifiers then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
				elseif v.notes then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>NOTES</h>\n <p>"..reEncode(v.notes).."</p>");
			end
		end
		--add & fill perks
	end
	if luasheet.perks then
		for k,v in pairs(luasheet.perks) do
			local nodeNew = DB.createChild(nodeAds);
			DB.setValue(nodeNew, "name", "string", v.name);
			DB.setValue(nodeNew, "points", "number", v.pts or 0);
			if v.modifiers and v.notes then
				DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
				elseif v.modifiers then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
				elseif v.notes then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>NOTES</h>\n <p>"..reEncode(v.notes).."</p>");
			end
		end
	end
	--add & fill disads 
	local nodeDisads = DB.createChild(nodeChar, "traits.disadslist")
	if luasheet.disadvantages then
		
		for k,v in pairs(luasheet.disadvantages) do
			local nodeNew = DB.createChild(nodeDisads);
			DB.setValue(nodeNew, "name", "string", v.name);
			DB.setValue(nodeNew, "points", "number", v.pts or 0);
			if v.modifiers and v.notes then
				DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
				elseif v.modifiers then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
				elseif v.notes then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>NOTES</h>\n <p>"..reEncode(v.notes).."</p>");
			end
		end
	end
	if luasheet.quirks then
		--add & fill quirks
		for k,v in pairs(luasheet.quirks) do
			local nodeNew = DB.createChild(nodeDisads);
			DB.setValue(nodeNew, "name", "string", v.name);
			DB.setValue(nodeNew, "points", "number", v.pts or 0);
			if v.modifiers and v.notes then
				DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
				elseif v.modifiers then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
				elseif v.notes then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>NOTES</h>\n <p>"..reEncode(v.notes).."</p>");
			end
		end
	end

	if luasheet.skills then
		print("importing skills")
		local nodeSkills = DB.createChild(nodeChar, "abilities.skilllist");
		for k,v in pairs(luasheet.skills) do
			local nodeNew = DB.createChild(nodeSkills);
			DB.setValue(nodeNew, "name", "string", v.name)
			DB.setValue(nodeNew, "level", "number", tonumber(v.sl))
			DB.setValue(nodeNew, "type", "string", rslConverter(v.rsl))
			DB.setValue(nodeNew, "relativelevel", "string", string.match(v.rsl,"([\+\-][0-9]+)"))--regex matches the +1 or -1 type in the RSL output from GCS
			DB.setValue(nodeNew, "points", "number", v.pts)
			if v.modifiers and v.notes then
				DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
				elseif v.modifiers then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
				elseif v.notes then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>NOTES</h>\n <p>"..reEncode(v.notes).."</p>");
			end
		end	
	end
	if luasheet.spells then
		local nodeSpells = DB.createChild(nodeChar, "abilities.spelllist");
		for k,v in pairs(luasheet.spells) do
			local nodeNew = DB.createChild(nodeSpells);
			DB.setValue(nodeNew, "name", "string", v.name)
			DB.setValue(nodeNew, "level", "number", tonumber(v.sl))
			DB.setValue(nodeNew, "type", "string", rslConverter(v.rsl))--function matches the base attribute abbreviation, or substitutes T for techniques when not found.
			DB.setValue(nodeNew, "relativelevel", "string", string.match(v.rsl,"([\+\-][0-9]+)"))--regex matches the +1 or -1 type in the RSL output from GCS
			DB.setValue(nodeNew, "points", "number", v.pts)
			DB.setValue(nodeNew, "class", "string", split(v.class,'[\\/]+')[1]) --GCS puts resistance and class in the same entry, good job. We split it here and take the first, which is class
			DB.setValue(nodeNew, "college", "string", v.college)
			DB.setValue(nodeNew, "costmaintain", "string", v.manacast.."/"..v.manamaint)
			DB.setValue(nodeNew, "duration", "string", v.duration)
			DB.setValue(nodeNew, "page", "string", v.ref)
			DB.setValue(nodeNew, "resist", "string", split(v.class,'[\\/]+')[2] or "N/A")
			DB.setValue(nodeNew, "time", "string", v.casttime)

			if v.modifiers and v.notes then
				DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
				elseif v.modifiers then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
				elseif v.notes then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>NOTES</h>\n <p>"..reEncode(v.notes).."</p>");
			end
		end	
	end
	if luasheet.melee then--add melee weapons. I hope you like for loops
		print("importing melee weapons")
		local nodemelee = DB.createChild(nodeChar, "combat.meleecombatlist");
		--preprocessing
		local meleeTable = {}
		local meleeIndex = {}
		for k,v in pairs(luasheet.melee) do --setup the meleeTable with the names, this allows us to collapse things by usage preventing duplicate entries for each usage of a weapon.
			if meleeTable[v.name] then
				--pass, it already exists
			else --else create entry
				meleeTable[v.name]={}
				meleeIndex[v.name]={}
			end
			meleeTable[v.name][v.usage]=k
			meleeIndex[v.name][v.usage]=k
			for eK,eV in pairs(luasheet.equipment) do --find the corresponding equipment entry for the other info.
				if eV.name == v.name then
					meleeIndex[v.name]["equip"]=eK
				end
			end
			
		end
		for k,v in pairs(meleeTable) do
			print(nodemelee)
			local nodeNew = DB.createChild(nodemelee)
			DB.setValue(nodeNew, "name", "string", reEncode(k))
			DB.setValue(nodeNew, "st", "string", "")
			if luasheet.equipment[meleeIndex[k]["equip"]] then
				DB.setValue(nodeNew, "cost", "string", luasheet.equipment[meleeIndex[k]["equip"]]["cost"]);
				DB.setValue(nodeNew, "weight", "string", luasheet.equipment[meleeIndex[k]["equip"]]["weight"]);
				if luasheet.equipment[meleeIndex[k]["equip"]].modifiers and luasheet.equipment[meleeIndex[k]["equip"]].notes then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
					elseif luasheet.equipment[meleeIndex[k]["equip"]].modifiers then
						DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
					elseif luasheet.equipment[meleeIndex[k]["equip"]].notes then
						DB.setValue(nodeNew, "text", "formattedtext", "<h>NOTES</h>\n <p>"..reEncode(v.notes).."</p>");
				end
			end
			
			--make the melee mode list
			local nodeModelist = DB.createChild(nodeNew, "meleemodelist");
			for kU,vU in pairs(meleeTable[k]) do --key Usage, value Usage
				local nodeMode = DB.createChild(nodeModelist)
				local weapon = luasheet.melee[vU]
				DB.setValue(nodeMode, "damage", "string", weapon.damage);
				DB.setValue(nodeMode, "level", "number", weapon.level);
				DB.setValue(nodeMode, "name", "string",  reEncode(weapon.usage));
				DB.setValue(nodeMode, "parry", "string", weapon.parry)
				DB.setValue(nodeMode,"reach", "string", weapon.reach)
				if weapon.st ~= "" then
					DB.setValue(nodeNew, "st", "string", DB.getValue(nodeNew, "st", "")..reEncode(weapon.st).."/")
				end
			end
			local preST =DB.getValue(nodeNew, "st", "x")
			DB.setValue(nodeNew, "st", "string", string.sub(preST,1,-2)) --trims the trailing slash off ST.
		end

	end
	if luasheet.range then--add range weapons. 
		print("importing ranged weapons")
		local nodeRanged = DB.createChild(nodeChar, "combat.rangedcombatlist");
		--preprocessing
		local rangedTable = {}
		local rangedIndex = {}
		for k,v in pairs(luasheet.range) do --setup the rangedTable with the names, this allows us to collapse things by usage preventing duplicate entries for each usage of a weapon.
			if rangedTable[v.name] then
				--pass, it already exists
			else --else create entry
				rangedTable[v.name]={}
				rangedIndex[v.name]={}
			end
			rangedTable[v.name][v.usage]=k
			rangedIndex[v.name][v.usage]=k
			for eK,eV in pairs(luasheet.equipment) do --find the corresponding equipment entry for the other info.
				if eV.name == v.name then
					rangedIndex[v.name]["equip"]=eK
				end
			end
			
		end
		for k,v in pairs(rangedTable) do
			local nodeNew = DB.createChild(nodeRanged)
			DB.setValue(nodeNew, "name", "string", reEncode(k))
			DB.setValue(nodeNew, "st", "string", "")
			if luasheet.equipment[rangedIndex[k]["equip"]] then
				DB.setValue(nodeNew, "cost", "string", luasheet.equipment[rangedIndex[k]["equip"]]["cost"]);
				DB.setValue(nodeNew, "weight", "string", luasheet.equipment[rangedIndex[k]["equip"]]["weight"]);
				if luasheet.equipment[rangedIndex[k]["equip"]].modifiers and luasheet.equipment[rangedIndex[k]["equip"]].notes then
				DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
				elseif luasheet.equipment[rangedIndex[k]["equip"]].modifiers then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
				elseif luasheet.equipment[rangedIndex[k]["equip"]].notes then
					DB.setValue(nodeNew, "text", "formattedtext", "<h>NOTES</h>\n <p>"..reEncode(v.notes).."</p>");
				end
			end
			--make the ranged mode list
			local nodeModelist = DB.createChild(nodeNew, "rangedmodelist");
			for kU,vU in pairs(rangedTable[k]) do --key Usage, value Usage
				local nodeMode = DB.createChild(nodeModelist)
				local weapon = luasheet.range[vU]
				DB.setValue(nodeMode, "damage", "string", weapon.damage);
				DB.setValue(nodeMode, "level", "number", weapon.level);
				DB.setValue(nodeMode, "name", "string", reEncode(weapon.usage));
				DB.setValue(nodeMode, "acc", "number", weapon.acc)
				DB.setValue(nodeMode,"range", "string", weapon.range)
				DB.setValue(nodeMode,"rof", "string", weapon.rof)
				DB.setValue(nodeMode,"rcl", "number", tonumber(weapon.recoil) or 1)
				DB.setValue(nodeMode,"shots", "string", tonumber(weapon.shots or 1) or 1)
				if weapon.st ~= "" then
					DB.setValue(nodeNew, "st", "string", DB.getValue(nodeNew, "st", "")..reEncode(weapon.st).."/")
				end
				if weapon.bulk ~= "" then
					DB.setValue(nodeNew,"bulk", "number", tonumber(weapon.bulk) or 0)
				end
			end
			local preST =DB.getValue(nodeNew, "st", "x")
			DB.setValue(nodeNew, "st", "string", string.sub(preST,1,-2)) --trims the trailing slash off ST.
		end
	end
	local protNode = DB.createChild(nodeChar, "combat.protectionlist")
	print("importing protection")
	for k,v in pairs(luasheet.dr) do
		if v ~= "0" then 
			local newNode = DB.createChild(protNode)
			DB.setValue(newNode, "name", "string", "DEFAULT (IMPORTED)")
			DB.setValue(newNode, "dr", "string", v)
			DB.setValue(newNode, "location", "string", k)
		end
	end
	if luasheet.notes then
		print("importing notes")
		local nodeNotes = DB.createChild(nodeChar, "notelist")
		for i,v in ipairs(luasheet.notes) do
			local newNote = DB.createChild(nodeNotes)
			local nname = ""
			local iter=0
			for id in string.gmatch(v,"(%w+ *)") do
				if iter >3 then break; end
				nname=nname..id
				iter = iter+1
			end
			local str, _ = string.gsub("<p>"..v.."</p>","<br>","</p><p>")
			DB.setValue(newNote, "name", "string", nname.."...")
			DB.setValue(newNote, "text", "formattedtext", reEncode(str));
		end
	end
	--languages.
	if luasheet.languages then
		local nodeLang = DB.createChild(nodeChar, "traits.languagelist")
		for i,v in ipairs(luasheet.languages) do
			local newNode = DB.createChild(nodeLang)
			--process the name of the language out of the advantage name
			local a,_ = string.find(v.name,":")
			print(v.name)
			a= a+2--increment the start index so we trim out the space and colon
			
			local _spoken =" "--process the modifier notes to find spoken and written.
			local _written =" "
			for i in string.gmatch(v.modifiers, "%w+ %(%w+%)") do
			   if string.find(i,"Spoken") then
			   	_spoken = string.sub(i, i:find("%(%w+%)"));
			   elseif string.find(i,"Written") then
			   	_written= string.sub(i, i:find("%(%w+%)"));
			   end
			end

			DB.setValue(newNode, "name", "string", string.sub(v.name, a))
			DB.setValue(newNode, "points", "number", v.pts)
			DB.setValue(newNode, "spoken", "string", string.sub(_spoken,2,-2))--trim off the brackets
			DB.setValue(newNode, "written", "string", string.sub(_written,2,-2))
		end
	end
	if luasheet.cultures then
		local nodeCult = DB.createChild(nodeChar, "traits.culturalfamiliaritylist")
		for i,v in ipairs(luasheet.cultures) do
			local nodeNew = DB.createChild(nodeCult)
			DB.setValue(nodeNew, "points", "number", v.pts)
			local _name = string.gsub(v.name, "Cultural Familiarity %(","")
				print("culture name:")
				print(_name)
			local _name = string.sub(_name,1,-2)
			print(_name)
			DB.setValue(nodeNew, "name", "string", _name)
		end
	end
	if luasheet.equipment then
		local nodeInven = DB.createChild(nodeChar, "inventorylist")
		for i,v in ipairs(luasheet.equipment) do
			local nodeNew = DB.createChild(nodeInven)
			DB.setValue(nodeNew, "name","string",v.name)
			DB.setValue(nodeNew, "count","number",v.quantity)
			DB.setValue(nodeNew, "cost","string",v.cost)
			DB.setValue(nodeNew,"isidentified","number",1)
			DB.setValue(nodeNew,"locked", "number",1)
			DB.setValue(nodeNew,"weight","number", weightToNum(v.weight))
			local _state = 2
			if v.state=="E" then
				state = 2
			elseif v.state=="C" then
				state=1
			elseif v.state=="-" then
				state=0
			end
			DB.setValue(nodeNew,"carried", "number",_state) --sets the carried state
			if v.modifiers ~= "" and v.notes ~= "" then
				DB.setValue(nodeNew, "notes", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>\n <h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
			elseif v.modifiers and not v.notes  then
				DB.setValue(nodeNew, "notes", "formattedtext", "<h>MODIFIERS</h>\n <p>"..reEncode(v.modifiers).."</p>");
			elseif v.notes and not v.modifiers then
				DB.setValue(nodeNew, "notes", "formattedtext", "<h>NOTES</h> \n<p>"..reEncode(v.notes).."</p>");
			end



			end
		end
end
-- delete this
Comm.addChatMessage({text="Import successful"})
end

---character defs

function docharacters()
	return{
	--INSERT CHARACTER DATA HERE! Append each with a , too or it won't work. Import with /importcharlua #, where # is the order of characters in this table.
{
	["name"]="@NAME",
	["points"]=@TOTAL_POINTS,
	["pointsbreakdown"]={
		race=@RACE_POINTS,
		attributes=@ATTRIBUTE_POINTS,
		advantages=@ADVANTAGE_POINTS,
		disadvantages=@DISADVANTAGE_POINTS,
		quirks=@QUIRK_POINTS,
		skills=@SKILL_POINTS,
		spells=@SPELL_POINTS,
		unspent=@EARNED_POINTS
	},
	["ST"]={stat=@ST,pts=@ST_POINTS},
	["DX"]={stat=@DX,pts=@DX_POINTS},
	["IQ"]={stat=@IQ,pts=@IQ_POINTS},
	["HT"]={stat=@HT,pts=@HT_POINTS},
	["description"]={
		["race"]="@RACE",
		["gender"]="@GENDER",
		["age"]="@AGE",
		["birthday"]="@BIRTHDAY",
		["height"]="@HEIGHT",
		["weight"]="@WEIGHT",
		["size"]="@SIZE",
		["tl"]="@TL",
		["hair"]="@HAIR",
		["eyes"]="@EYES",
		["skin"]="@SKIN",
		["hand"]="@HAND",
	},
	["thr"]="@THRUST",
	["sw"]="@SWING",
	["bl"]="@BASIC_LIFT",
	["HP"]={stat=@BASIC_HP,pts=@HP_POINTS},
	["FP"]={stat=@BASIC_FP,pts=@FP_POINTS},
	--current HP and FP & other stuff
	["cHP"]="@HP",
	["cFP"]="@FP",
	["cDodge"]=@CURRENT_DODGE,
	["cBlock"]="@BEST_CURRENT_BLOCK",
	["cParry"]="@BEST_CURRENT_PARRY",
	--
	["will"]={stat=@WILL,pts=@WILL_POINTS},
	["per"]={stat=@PERCEPTION,pts=@PERCEPTION_POINTS},
	["speed"]={stat=@BASIC_SPEED,pts=@BASIC_SPEED_POINTS},
	["move"]={stat=@BASIC_MOVE,pts=@BASIC_MOVE_POINTS},
	["languages"]={
	@LANGUAGES_LOOP_START
	{name="@DESCRIPTION_PRIMARY",pts=@POINTS,notes="@DESCRIPTION_NOTES", modifiers="@DESCRIPTION_MODIFIER_NOTES"},@LANGUAGES_LOOP_END
	nil
	},
	["cultures"]={
	@CULTURAL_FAMILIARITIES_LOOP_START
	{name="@DESCRIPTION_PRIMARY",pts=@POINTS,notes="@DESCRIPTION_NOTES", modifiers="@DESCRIPTION_MODIFIER_NOTES"},@CULTURAL_FAMILIARITIES_LOOP_END
	nil
	},
	["advantages"]={
		@ADVANTAGES_ONLY_LOOP_START
		{name="@DESCRIPTION_PRIMARY",pts=@POINTS,notes="@DESCRIPTION_NOTES",modifiers="@DESCRIPTION_MODIFIER_NOTES"},@ADVANTAGES_ONLY_LOOP_END
		nil
	},
	["perks"]={
		@PERKS_LOOP_START
		{name="@DESCRIPTION_PRIMARY",pts=@POINTS,notes="@DESCRIPTION_NOTES",modifiers="@DESCRIPTION_MODIFIER_NOTES"},@PERKS_LOOP_END
		nil
	},
	["disadvantages"]={
		@DISADVANTAGES_LOOP_START
		{name="@DESCRIPTION_PRIMARY",pts=@POINTS,notes="@DESCRIPTION_NOTES",modifiers="@DESCRIPTION_MODIFIER_NOTES"},@DISADVANTAGES_LOOP_END
		nil
	},
	["quirks"]={
		@QUIRKS_LOOP_START
		{name="@DESCRIPTION_PRIMARY",pts=@POINTS,notes="@DESCRIPTION_NOTES",modifiers="@DESCRIPTION_MODIFIER_NOTES"},@QUIRKS_LOOP_END
		nil
	},
	["skills"]={
		@SKILLS_LOOP_START
		{name="@DESCRIPTION_PRIMARY",sl="@SL",rsl="@RSL",pts=@POINTS, notes="@DESCRIPTION_NOTES", modifiers="@DESCRIPTION_MODIFIER_NOTES"},@SKILLS_LOOP_END
		nil
	},
	["spells"]={
		@SPELLS_LOOP_START
		{name="@DESCRIPTION_PRIMARY",sl="@SL",rsl="@RSL",pts=@POINTS, class="@CLASS", college="@COLLEGE", manacast="@MANA_CAST",manamaint="@MANA_MAINTAIN",casttime="@TIME_CAST",duration="@DURATION",ref="@REF", notes="@DESCRIPTION_NOTES", modifiers="@DESCRIPTION_MODIFIER_NOTES"},@SPELLS_LOOP_END
		nil
	},
	["equipment"]={
		@EQUIPMENT_LOOP_START
		{name="@DESCRIPTION_PRIMARY",quantity=@QTY,cost="@COST",weight="@WEIGHT", state="@STATE", notes="@DESCRIPTION_NOTES", modifiers="@DESCRIPTION_MODIFIER_NOTES"},@EQUIPMENT_LOOP_END
		nil
	},
	["melee"]={
	@MELEE_LOOP_START
	{name="@DESCRIPTION_PRIMARY", usage="@USAGE",level=@LEVEL,parry="@PARRY",block="@BLOCK",damage="@DAMAGE",reach="@REACH",st="@STRENGTH", notes="@DESCRIPTION_NOTES"},@MELEE_LOOP_END
	nil
	},
	["range"]={
	@RANGED_LOOP_START
	{name="@DESCRIPTION_PRIMARY", usage="@USAGE",level=@LEVEL,acc=@ACCURACY,range="@RANGE",damage="@DAMAGE",rof="@ROF",st="@STRENGTH",bulk="@BULK",recoil="@RECOIL",shots="@SHOTS",notes="@DESCRIPTION_NOTES"},@RANGED_LOOP_END
	nil
	},
	["dr"]={
		@HIT_LOCATION_LOOP_START
		["@WHERE"]="@DR",@HIT_LOCATION_LOOP_END
		nil
	},
	["enc"]={
	 @ENCUMBRANCE_LOOP_START
	{level="@LEVEL", max="@MAX_LOAD",move=@MOVE,dodge=@DODGE},@ENCUMBRANCE_LOOP_END
	nil
	},
	["notes"]={
	@NOTES_LOOP_START
	"@NOTE",@NOTES_LOOP_END
	nil
	}
},

nil
}
end