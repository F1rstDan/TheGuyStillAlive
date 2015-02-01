WeaponsDataKv = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
--------------------------------------------------------------------------------
-- 设定武器参数（英雄单位，武器槽位，技能）
--------------------------------------------------------------------------------
function Set_Hero_Weapons(hero,weapons_slot,ability)
	if hero[weapons_slot] == nil then
		hero[weapons_slot] = {}
	end

	local pID = hero:GetPlayerID()
	local ability_name = ability:GetAbilityName()
	local weapons_data = WeaponsDataKv[ability_name].Weapons_Data

	hero[weapons_slot].Ability		= ability
	hero[weapons_slot].EffectName	= weapons_data.EffectName						or "particles/sb/Heavy_Weapons_Default.vpcf"
	hero[weapons_slot].Cooldown		= WeaponsDataKv[ability_name].AbilityCooldown	or 0.5
	hero[weapons_slot].ManaCost		= WeaponsDataKv[ability_name].AbilityManaCost	or 25
	hero[weapons_slot].Distance		= ability:GetSpecialValueFor("Distance")		or 2000
	hero[weapons_slot].MoveSpeed	= ability:GetSpecialValueFor("MoveSpeed")		or 1600
	hero[weapons_slot].StartRadius	= ability:GetSpecialValueFor("StartRadius")		or 32
	hero[weapons_slot].EndRadius	= ability:GetSpecialValueFor("EndRadius")		or 32


	--是否 根据鼠标位置 攻击到地点
	if tonumber(weapons_data.IsAttackToPosition) >= 1 then
		hero[weapons_slot].IsAttackToPosition = true
	else
		hero[weapons_slot].IsAttackToPosition = false
	end
	--击中时 是否删除
	if tonumber(weapons_data.DeleteOnHit) >= 1 then
		hero[weapons_slot].DeleteOnHit = true
	else
		hero[weapons_slot].DeleteOnHit = false
	end
	--是否锥形范围
	if tonumber(weapons_data.HasFrontalCone) >= 1 then
		hero[weapons_slot].HasFrontalCone = true
	else
		hero[weapons_slot].HasFrontalCone = false
	end

end

--------------------------------------------------------------------------------
-- 射击函数（英雄单位，武器槽位）
--------------------------------------------------------------------------------
function Weapons_Shooting(hero,weapons_slot)
	local pID = hero:GetPlayerID()
	local hero_origin = hero:GetAbsOrigin()

	--魔法是否足够
	if hero:GetMana() < hero[weapons_slot].ManaCost then
		FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "#CustomError_ManaNotEnough" } )
		return
	else
		hero:SpendMana(hero[weapons_slot].ManaCost,hero[weapons_slot].Ability)
	end


	local spawn_origin
	if weapons_slot == "Light_Weapons_Left" then
		local origin = hero_origin + hero:GetUpVector() *155
		local forward = hero:GetForwardVector()
		spawn_origin = origin + Vector(forward.y,-forward.x,forward.z)*50 +forward*50 --原点+方向*距离

		Weapons_Cooldown[pID]["Light_Weapons"] = hero[weapons_slot].Cooldown/2		--重置武器时间间隔
		Weapons_Cooldown[pID]["Light_Weapons_Left"] = hero[weapons_slot].Cooldown	--重置武器时间间隔

	elseif weapons_slot == "Light_Weapons_Right" then
		local origin = hero_origin + hero:GetUpVector() *155
		local forward = hero:GetForwardVector()
		spawn_origin = origin + Vector(-forward.y,forward.x,forward.z)*50 +forward*50 --原点+方向*距离

		Weapons_Cooldown[pID]["Light_Weapons"] = hero[weapons_slot].Cooldown/2		--重置武器时间间隔
		Weapons_Cooldown[pID]["Light_Weapons_Right"] = hero[weapons_slot].Cooldown	--重置武器时间间隔

	elseif weapons_slot == "Heavy_Weapons_Middle" then
		spawn_origin = hero_origin + hero:GetUpVector() *110
		Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] = hero[weapons_slot].Cooldown	--重置武器时间间隔
	else
		return
	end

	--是否 根据鼠标位置 攻击到地点
	local distance = hero[weapons_slot].Distance
	if hero[weapons_slot].IsAttackToPosition then
		local AttackToPosition_Length = (hero_origin-Mouse.xyz[pID]):Length()
		if AttackToPosition_Length < distance then --如果没有超过最大距离
			distance = AttackToPosition_Length
		end
	end
	--发射角度和子弹速度
	local velocity = (Mouse.xyz[pID] - spawn_origin):Normalized() * hero[weapons_slot].MoveSpeed

	local info = 
	{
		Source				= hero,								--来源单位
		Ability				= hero[weapons_slot].Ability,		--技能
		EffectName			= hero[weapons_slot].EffectName,	--特效路径
		vSpawnOrigin		= spawn_origin,						--产生的地点,hero:GetAbsOrigin()
		fDistance			= distance,							--距离
		vVelocity			= velocity,							--速率,角度*速度(hero:GetForwardVector() * 1800)
		-- fMaxSpeed 			= hero[weapons_slot].MoveSpeed,		--最大速度
		fStartRadius		= hero[weapons_slot].StartRadius,	--开始范围
		fEndRadius			= hero[weapons_slot].EndRadius,		--结束范围
		bDeleteOnHit		= hero[weapons_slot].DeleteOnHit,	--击中时 是否删除
		bHasFrontalCone		= hero[weapons_slot].HasFrontalCone,--是否是 正面锥形？
		bReplaceExisting	= false,							--是否是 替换现有的？
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= GameRules:GetGameTime() + 10.0,	--到期时间
		bDrawsOnMinimap		= true,								--是否显示在小地图
		bProvidesVision		= true,								--是否提供视野
		iVisionRadius		= hero[weapons_slot].StartRadius,	--视野半径
		iVisionTeamNumber	= hero:GetTeamNumber()				--视野所属队伍
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)	--发射线性特效



	print("========= ")
	print("Mouse.xyz[pID] =							",Mouse.xyz[pID].x,Mouse.xyz[pID].y,Mouse.xyz[pID].z)
	print("spawn_origin =							",spawn_origin.x,spawn_origin.y,spawn_origin.z)
	print("(Mouse.xyz-spawn_origin) = 				",(Mouse.xyz[pID] - spawn_origin).x,(Mouse.xyz[pID] - spawn_origin).y,(Mouse.xyz[pID] - spawn_origin).z)
	print("(Mouse.xyz-spawn_origin):Normalized() =	",(Mouse.xyz[pID] - spawn_origin):Normalized().x,(Mouse.xyz[pID] - spawn_origin):Normalized().y,(Mouse.xyz[pID] - spawn_origin):Normalized().z)
	print("========= ")

end