--------------------------------------------------------------------------------
-- 武器函数 集,每个武器文件开头必加
--------------------------------------------------------------------------------
if Weapons_Function == nil then
	Weapons_Function = {}		-- 武器函数 集
end


--------------------------------------------------------------------------------
-- 武器的函数，OnHit是击中单位时运行，OnFinish是弹道结束时运行
--------------------------------------------------------------------------------
Weapons_Function["Heavy_Weapons_Fire"] = {}

Weapons_Function["Heavy_Weapons_Fire"]["OnHit"] = function (keys)
	local caster = keys.caster
	local target = keys.target
	local point = keys.target_points[1]
	local weapons_slot = keys.Weapons
	local iID = keys.iID

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ITEMS[iID].Damage,
		damage_type = DAMAGE_TYPE_PURE,
	}
	ApplyDamage(damageTable)
end

Weapons_Function["Heavy_Weapons_Fire"]["OnFinish"] = function (keys)
	return nil
end