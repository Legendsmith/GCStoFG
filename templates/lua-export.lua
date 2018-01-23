--Lua export template by legendsmith
--Legendsmith#1102 on discord
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
}
