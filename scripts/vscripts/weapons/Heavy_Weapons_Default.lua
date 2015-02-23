--------------------------------------------------------------------------------
-- 武器函数 集,每个武器文件开头必加
--------------------------------------------------------------------------------
if Weapons_Function == nil then
	Weapons_Function = {}		-- 武器函数 集
end


--------------------------------------------------------------------------------
-- 武器的函数，OnHit是击中单位时运行，OnFinish是弹道结束时运行
--------------------------------------------------------------------------------
Weapons_Function["Heavy_Weapons_Default"] = {}

Weapons_Function["Heavy_Weapons_Default"]["OnHit"] = function (keys)
	local caster = keys.caster
	local target = keys.target
	local point = keys.target_points[1]
	local weapons_slot = keys.Weapons
	local iID = keys.iID

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ITEMS[iID].Damage/3,
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end

Weapons_Function["Heavy_Weapons_Default"]["OnFinish"] = function (keys)
	local caster = keys.caster
	local target = keys.target
	local point = keys.target_points[1]
	local weapons_slot = keys.Weapons
	local iID = keys.iID

	ApplyDamageInRadius(caster,ITEMS[iID].Damage,point,300)
end