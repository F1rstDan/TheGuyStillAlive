savedhero=nil   --存储英雄
if Global == nil then
	Global = class({})
end

--------------------------------------------------------------------------------
-- 游戏初始化
--------------------------------------------------------------------------------
function Global:InitGameMode()
	--按键注册
	KeyboardRegisterCommand()

	--游戏是否暂停
	GameRules.IsGamePaused = false
	local oldtime = GameRules:GetGameTime()
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("IsGamePaused"),function()
			local new = GameRules:GetGameTime()
			if oldtime == new then
				if not GameRules.IsGamePaused then
					GameRules.IsGamePaused = true
					print( "Game Paused!" )
				end
			else
				if GameRules.IsGamePaused then
					GameRules.IsGamePaused = false
				end
			end
			oldtime = new
			return 0.1
	end,1)

	-- 英雄出生时
	ListenToGameEvent("npc_spawned", Dynamic_Wrap( Global, "HeroMoveAndShooting" ), self )

	--单位死亡事件
	ListenToGameEvent('entity_killed', Dynamic_Wrap(Global, 'OnEntityKilled_CreateUnit'), self)

end

--------------------------------------------------------------------------------
-- 单位死亡事件
--------------------------------------------------------------------------------
function Global:OnEntityKilled_CreateUnit( keys )
	-- print( '[KATA] OnEntityKilled Called' )
	-- print( '[KATA_Killed] entindex_killed = '..EntIndexToHScript( keys.entindex_killed ):GetName() )
	-- print( '[KATA_Killed] entindex_attacker = '..EntIndexToHScript( keys.entindex_attacker ):GetName() )
	-- print( '[KATA_Killed] entindex_inflictor = '..EntIndexToHScript( keys.entindex_inflictor ):GetName() )
	-- print( '[KATA_Killed] damagebits = '..keys.damagebits )

	-- 储存被击杀的单位
	local killed = EntIndexToHScript( keys.entindex_killed )
	-- 储存杀手单位
	-- local attacker =EntIndexToHScript( keys.entindex_attacker )

	if not killed:IsHero() then
		--这段是早期刷怪用，以后记得删除
		--CreateUnit_amount = CreateUnit_amount -1
		
		-- local loc = killed:GetAbsOrigin()	--得到主体坐标
		-- local unitname = killed:GetClassname()
		-- print("unitname = ",killed:GetClassname()) --npc_dota_creature?
		-- GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("CreateUnit"), 
		-- 	function()
		-- 		CreateUnit_amount = CreateUnit_amount +1
		-- 		-- local unit = CreateUnitByName(unitname,loc,true,nil,nil,DOTA_TEAM_NEUTRALS)
		-- 		local unit = CreateUnitByName("npc_zombie_01",loc,true,nil,nil,DOTA_TEAM_NEUTRALS)
		-- 	return nil
		-- end,30)

	end
end

--------------------------------------------------------------------------------
-- 英雄出生时， 判断按键并移动 ， 计算时间并射击
--------------------------------------------------------------------------------
function Global:HeroMoveAndShooting( event )
	local hero = EntIndexToHScript( event.entindex )
	if not hero or hero:IsPhantom() then
		return
	end

	if hero:IsRealHero() and not hero.firstspawned then -- 如果英雄第一次出生
		print( '[HotD] OnNPCSpawned' )
		hero.firstspawned = true --设置英雄第一次出生。免得重生又运行一次
		local pID = hero:GetPlayerID()

		--给英雄所有普通技能添加一级，除大招和黄点
		hero:SetAbilityPoints(0)		--设置英雄的升级点为0
		for i=0,hero:GetAbilityCount()-1 do
			local ability = hero:GetAbilityByIndex(i)
			if ability then
				if ability:GetAbilityType() == 0 then 	--AbilityType, 普通技能=0, 大招技能=1, 属性技能=2
					-- ability:UpgradeAbility()
					ability:SetLevel(1)
				end
				print( "[HotDAddAbility] ability= "..ability:GetAbilityName().."	 ,AbilityType= "..ability:GetAbilityType() )
			end
		end

		--产生怪
		-- CreateUnit_amount = 0
		-- GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("CreateUnit"), 
		-- 	function()
		-- 		if hero == nil then
		-- 			return nil
		-- 		end
		-- 		if GameRules.IsGamePaused or hero:IsAlive() == false then
		-- 			return 1
		-- 		end

		-- 		local hero_in = hero:GetAbsOrigin()	--得到主体坐标
		-- 		if CreateUnit_amount < 50 then
		-- 			for i = 1,RandomInt(4,9) do
		-- 					CreateUnit_amount = CreateUnit_amount +1
		-- 					local unit = CreateUnitByName("npc_zombie_01",hero:GetAbsOrigin()+RandomVector(1000),true,nil,nil,DOTA_TEAM_NEUTRALS)
		-- 			end
		-- 			for i = 1,RandomInt(2,4) do
		-- 					CreateUnit_amount = CreateUnit_amount +1
		-- 					local unit = CreateUnitByName("npc_zombie_02",hero:GetAbsOrigin()+RandomVector(1200),true,nil,nil,DOTA_TEAM_NEUTRALS)
		-- 			end
		-- 		end
		-- 	return 10
		-- end,90)

		--移动
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("move"), 
			function()
				if hero == nil then
					return nil
				end
				if GameRules.IsGamePaused or hero:IsAlive() == false then
					return 0.01
				end
				--local hero_in = hero:GetOrigin()
				local hero_in = hero:GetAbsOrigin()	--得到主体坐标
				local hero_next = hero_in			--下个地点坐标
				local hero_movespeed = hero:GetMoveSpeedModifier( hero:GetBaseMoveSpeed() )/30
				--print( '[HotD] hero_movespeed =' ,hero_movespeed*30)
				local IsMove = false
				if IsPriorityW[pID] then
					if IsDown_W[pID] and GridNav:IsTraversable( Vector(hero_next.x,hero_next.y+50,hero_next.z) ) and GridNav:IsBlocked( Vector(hero_next.x,hero_next.y+50,hero_next.z) )== false then
						hero_next = Vector(hero_next.x,hero_next.y+hero_movespeed,hero_next.z)
						IsMove = true
					end
				else
					if IsDown_S[pID] and GridNav:IsTraversable( Vector(hero_next.x,hero_next.y-50,hero_next.z) ) and GridNav:IsBlocked( Vector(hero_next.x,hero_next.y-50,hero_next.z) )== false then
						hero_next = Vector(hero_next.x,hero_next.y-hero_movespeed,hero_next.z)
						IsMove = true
					end
				end

				if IsPriorityA[pID] then
					if IsDown_A[pID] and GridNav:IsTraversable( Vector(hero_next.x-50,hero_next.y,hero_next.z) ) and GridNav:IsBlocked( Vector(hero_next.x-50,hero_next.y,hero_next.z) )== false then
						hero_next = Vector(hero_next.x-hero_movespeed,hero_next.y,hero_next.z)
						IsMove = true
					end
				else
					if IsDown_D[pID] and GridNav:IsTraversable( Vector(hero_next.x+50,hero_next.y,hero_next.z) ) and GridNav:IsBlocked( Vector(hero_next.x+50,hero_next.y,hero_next.z) )== false then
						hero_next = Vector(hero_next.x+hero_movespeed,hero_next.y,hero_next.z)
						IsMove = true
					end
				end

				if IsMove then
					--hero:SetOrigin( hero_next )
					hero:SetAbsOrigin( hero_next )
					--hero:SetForwardVector( hero_next - hero_in )
					--hero:SetAnimation("ACT_DOTA_RUN")
				end

			return 0.01
		end,0)

		--注册默认武器
		-- Set_Hero_Weapons(hero,"Light_Weapons_Left",hero:GetAbilityByIndex(0))
		-- Set_Hero_Weapons(hero,"Light_Weapons_Right",hero:GetAbilityByIndex(0))
		-- Set_Hero_Weapons(hero,"Heavy_Weapons_Middle",hero:GetAbilityByIndex(1))

		CreateItemForHero("Light_Weapons_Default",hero,"Light_Weapons_Left")
		CreateItemForHero("Light_Weapons_Default",hero,"Light_Weapons_Right")
		CreateItemForHero("Heavy_Weapons_Default",hero,"Heavy_Weapons_Middle")

		CreateItemForHero("Heavy_Weapons_Fire",hero,"inbag")
		CreateItemForHero("Light_Weapons_Default",hero,"inbag")
		CreateItemForHero("Heavy_Weapons_Fire",hero,"inbag")
		CreateItemForHero("Heavy_Weapons_Fire",hero,"inbag")
		-- CreateItemForHero("Heavy_Weapons_Default",hero,"inbag")
		-- CreateItemForHero("Heavy_Weapons_Fire",hero,"inbag")
		-- CreateItemForHero("Heavy_Weapons_Fire",hero,"inbag")

		--武器左右键的冷却时间
		if Weapons_Cooldown == nil then
			Weapons_Cooldown = {}
			Weapons_Cooldown[pID] = {}
		end
		Weapons_Cooldown[pID]["Light_Weapons"] = 0.0
		Weapons_Cooldown[pID]["Light_Weapons_IsToggle"] = true
		Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Left"
		Weapons_Cooldown[pID]["Light_Weapons_Left"] = 0.0
		Weapons_Cooldown[pID]["Light_Weapons_Right"] = 0.0

		Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] = 0.0
		--射击
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("shoot"), 
			function()
				if hero == nil then
					return nil
				end

				local Interval_time = 0.1
				if GameRules.IsGamePaused or hero:IsAlive() == false then
					return Interval_time
				end

				--恢复魔法值
				if Mouse.left[pID] == false and Mouse.right[pID] == false then
					hero:GiveMana(50)
				end

				if Weapons_Cooldown[pID]["Light_Weapons"] > 0.0 then
					Weapons_Cooldown[pID]["Light_Weapons"] = Weapons_Cooldown[pID]["Light_Weapons"] -Interval_time
				elseif Weapons_Cooldown[pID]["Light_Weapons"] < 0.0 then
					Weapons_Cooldown[pID]["Light_Weapons"] = 0.0
				end
				if Weapons_Cooldown[pID]["Light_Weapons_Left"] > 0.0 then
					Weapons_Cooldown[pID]["Light_Weapons_Left"] = Weapons_Cooldown[pID]["Light_Weapons_Left"] -Interval_time
				elseif Weapons_Cooldown[pID]["Light_Weapons_Left"] < 0.0 then
					Weapons_Cooldown[pID]["Light_Weapons_Left"] = 0.0
				end
				if Weapons_Cooldown[pID]["Light_Weapons_Right"] > 0.0 then
					Weapons_Cooldown[pID]["Light_Weapons_Right"] = Weapons_Cooldown[pID]["Light_Weapons_Right"] -Interval_time
				elseif Weapons_Cooldown[pID]["Light_Weapons_Right"] < 0.0 then
					Weapons_Cooldown[pID]["Light_Weapons_Right"] = 0.0
				end

				if Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] > 0.0 then
					Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] = Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] -Interval_time
				elseif Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] < 0.0 then
					Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] = 0.0
				end



				local origin = hero:GetAbsOrigin()
				local forward = hero:GetForwardVector()
				local unit_left = origin + Vector(forward.y,-forward.x,forward.z)*50 +forward*50 --原点+方向*距离
				unit_left = unit_left + hero:GetUpVector() * 155
				-- unit_left = RotatePosition( unit_left , VectorToAngles(Mouse.xyz[pID] - unit_left) ,unit_left)
				

				local unit_right =origin + Vector(-forward.y,forward.x,forward.z)*50 +forward*50 --原点+方向*距离
				unit_right = unit_right + hero:GetUpVector() * 155
				-- local weizhi = origin + unit_right*50 --原点+方向*距离
				-- weizhi = Vector( weizhi.x,weizhi.y,weizhi.z+150 )
				-- weizhi = weizhi + hero:GetUpVector() * 150


				if Mouse.left[pID] and Weapons_Cooldown[pID]["Light_Weapons_IsToggle"] and Weapons_Cooldown[pID]["Light_Weapons"] == 0.0 then
					if Weapons_Cooldown[pID]["Light_Weapons_Toggle"] == "_Left" then
						if Weapons_Cooldown[pID]["Light_Weapons_Left"] == 0.0 then
							Weapons_Shooting(hero,"Light_Weapons_Left")
							Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Right"
						elseif Weapons_Cooldown[pID]["Light_Weapons_Right"] == 0.0 then
							Weapons_Shooting(hero,"Light_Weapons_Right")
							Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Left"
						end
					elseif Weapons_Cooldown[pID]["Light_Weapons_Toggle"] == "_Right" then
						if Weapons_Cooldown[pID]["Light_Weapons_Right"] == 0.0 then
							Weapons_Shooting(hero,"Light_Weapons_Right")
							Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Left"
						elseif Weapons_Cooldown[pID]["Light_Weapons_Left"] == 0.0 then
							Weapons_Shooting(hero,"Light_Weapons_Left")
							Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Right"
						end
					end
				elseif Mouse.left[pID] and Weapons_Cooldown[pID]["Light_Weapons_IsToggle"] == false then
					if Weapons_Cooldown[pID]["Light_Weapons_Left"] == 0.0 then
						Weapons_Shooting(hero,"Light_Weapons_Left")
					end
					if Weapons_Cooldown[pID]["Light_Weapons_Right"] == 0.0 then
						Weapons_Shooting(hero,"Light_Weapons_Right")
					end

					-- Weapons_Shooting(hero,"Light_Weapons_Left")
					-- Weapons_Shooting(hero,"Light_Weapons_Right")

					-- Weapons_Cooldown[pID]["Light_Weapons"] = 0.2								--重置武器时间间隔
					-- hero:GetAbilityByIndex(0):ApplyDataDrivenModifier(hero, hero, "Weapons_Left_Interval",{Duration=0.2}) --

					-- DeepPrintTable( hero:GetAbilityByIndex(0):GetSpecialValueFor("EffectName") )
				end

				if Mouse.right[pID] and Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] == 0.0 then
					Weapons_Shooting(hero,"Heavy_Weapons_Middle")
				end

			return Interval_time
		end,0)

	end
end

--------------------------------------------------------------------------------
-- 注册命令
--------------------------------------------------------------------------------
function KeyboardRegisterCommand()

	-- test测试，重选英雄，
	Convars:RegisterCommand( "rehero", function(name)
		GameRules:ResetToHeroSelection()
	end, "rehero", 0 )

	-- 更换武器
	Convars:RegisterCommand( "onSwapWeapons", function(name,weapons_slot,itemID)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		local iID = tonumber(itemID)
		local hero = player:GetAssignedHero()
		print("[[onSwapWeapons]]weapons_slot = ",weapons_slot)
		print("[[onSwapWeapons]]iID = ",iID)
		if iID == -1 then
			hero[weapons_slot].ItemID = iID
			return
		end

		if hero[weapons_slot] == nil then
			hero[weapons_slot] = {}
		end
		--击中时 是否删除
		if ITEMS[iID].DeleteOnHit then
 			ability = hero:FindAbilityByName(weapons_slot.."_DeleteOnHit")
		else
			ability = hero:FindAbilityByName(weapons_slot.."_NoDeleteOnHit")
		end
		hero[weapons_slot].Ability		= ability
		hero[weapons_slot].ItemID		= iID
	end, "Swap Weapons", 0 )
	
	--== 注册鼠标相关变量
	Mouse = {}
	Mouse.x = {}
	Mouse.y = {}
	Mouse.z = {}
	Mouse.xyz = {}		--玩家鼠标位置，Vector(Mouse.x[pID],Mouse.y[pID],Mouse.z[pID])
	Mouse.left = {}		--玩家鼠标左键是否按下，true=按下
	Mouse.right = {}	--玩家鼠标右键是否按下，true=按下
	for pID=0,9 do 
		Mouse.x[pID] = nil
		Mouse.y[pID] = nil
		Mouse.z[pID] = nil
		Mouse.xyz[pID] = Vector(0,0,0)
		Mouse.left[pID] = false
		Mouse.right[pID] = false
	end
	-- 鼠标移动
	Convars:RegisterCommand( "onMouseMove", function(name,xx,yy,zz)
		local player = Convars:GetCommandClient()
		if player:GetAssignedHero() then
			local pID = player:GetPlayerID()

			local hero = player:GetAssignedHero()
			local hero_in = hero:GetAbsOrigin()	--得到主体坐标
			
			Mouse.x[pID] = tonumber(xx)
			Mouse.y[pID] = tonumber(yy)
			Mouse.z[pID] = tonumber(zz)
			Mouse.xyz[pID] = Vector(Mouse.x[pID],Mouse.y[pID],Mouse.z[pID])

			if hero:IsAlive() then
				hero:SetForwardVector( Mouse.xyz[pID] - hero_in )
			end

			--Say(nil, " "..x..", "..y..", "..z , false)
		end
	end, "mouse move", 0 )

	-- 鼠标左键按下
	Convars:RegisterCommand( "onMouseDown_Left", function(name)
		local player = Convars:GetCommandClient()
		if player:GetAssignedHero() then
			local pID = player:GetPlayerID()
			local hero = player:GetAssignedHero()

			if GameRules.IsGamePaused == false and hero:IsAlive() then
				if Weapons_Cooldown[pID]["Light_Weapons_IsToggle"] and Weapons_Cooldown[pID]["Light_Weapons"] == 0.0 then
					if Weapons_Cooldown[pID]["Light_Weapons_Toggle"] == "_Left" then
						if Weapons_Cooldown[pID]["Light_Weapons_Left"] == 0.0 then
							Weapons_Shooting(hero,"Light_Weapons_Left")
							Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Right"
						elseif Weapons_Cooldown[pID]["Light_Weapons_Right"] == 0.0 then
							Weapons_Shooting(hero,"Light_Weapons_Right")
							Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Left"
						end
					elseif Weapons_Cooldown[pID]["Light_Weapons_Toggle"] == "_Right" then
						if Weapons_Cooldown[pID]["Light_Weapons_Right"] == 0.0 then
							Weapons_Shooting(hero,"Light_Weapons_Right")
							Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Left"
						elseif Weapons_Cooldown[pID]["Light_Weapons_Left"] == 0.0 then
							Weapons_Shooting(hero,"Light_Weapons_Left")
							Weapons_Cooldown[pID]["Light_Weapons_Toggle"] = "_Right"
						end
					end
				elseif Mouse.left[pID] and Weapons_Cooldown[pID]["Light_Weapons_IsToggle"] == false then
					if Weapons_Cooldown[pID]["Light_Weapons_Left"] == 0.0 then
						Weapons_Shooting(hero,"Light_Weapons_Left")
					end
					if Weapons_Cooldown[pID]["Light_Weapons_Right"] == 0.0 then
						Weapons_Shooting(hero,"Light_Weapons_Right")
					end
				end
			end
			-- if Weapons_Cooldown[pID]["Light_Weapons"] == 0.0 then
			-- 	local info = 
			-- 	{
			-- 		Ability = hero:GetAbilityByIndex(0),				--技能
			-- 		-- EffectName = "particles/gyro_base_attack.vpcf",		--特效路径
			-- 		EffectName = "particles/sb/Light_Weapons_Default.vpcf",		--特效路径
			-- 		vSpawnOrigin = hero:GetAbsOrigin(),					--产生的地点
			-- 		fDistance = 2000,									--距离
			-- 		fStartRadius = 32,									--开始范围
			-- 		fEndRadius = 32,									--结束范围
			-- 		Source = hero,										--来源单位
			-- 		bHasFrontalCone = false,							--是否是 正面锥形？
			-- 		bReplaceExisting = false,							--是否是 替换现有的？
			-- 		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			-- 		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			-- 		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			-- 		fExpireTime = GameRules:GetGameTime() + 10.0,		--到期时间
			-- 		bDeleteOnHit = true,								--击中时 是否删除
			-- 		vVelocity = hero:GetForwardVector() * 1800,			--速率
			-- 		bProvidesVision = true,								--是否提供视野
			-- 		iVisionRadius = 1000,								--视野半径
			-- 		iVisionTeamNumber = hero:GetTeamNumber()			--视野所属队伍
			-- 	}
			-- 	projectile = ProjectileManager:CreateLinearProjectile(info)	--发射线性特效
			-- 	Weapons_Cooldown[pID]["Light_Weapons"] = 0.2								--重置武器时间间隔
			-- 	hero:GetAbilityByIndex(0):ApplyDataDrivenModifier(hero, hero, "Weapons_Left_Interval",{Duration=0.2}) --
			-- 	hero:GetAbilityByIndex(0):StartCooldown(0.2)
			-- end

			Mouse.left[pID] = true

			-- print("=====Ability=====",hero:GetAbilityByIndex(0))
			-- DeepPrintTable(hero:GetAbilityByIndex(0))			--打印表
			-- print("=====Ability")

			-- Say(nil, "onMouseDown_Left" , false)
		end
	end, "mouse down _Left", 0 )

	-- 鼠标左键松开
	Convars:RegisterCommand( "onMouseUp_Left", function(name)
		local player = Convars:GetCommandClient()
		if player:GetAssignedHero() then
			local pID = player:GetPlayerID()
			local hero = player:GetAssignedHero()

			Mouse.left[pID] = false

			-- Say(nil, "onMouseUp_Left" , false)
		end
	end, "mouse up _Left", 0 )

	-- 鼠标右键按下
	Convars:RegisterCommand( "onMouseDown_Right", function(name)
		local player = Convars:GetCommandClient()
		if player:GetAssignedHero() then
			local pID = player:GetPlayerID()
			local hero = player:GetAssignedHero()

			if GameRules.IsGamePaused == false and hero:IsAlive() then
				if Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] == 0.0 then
					Weapons_Shooting(hero,"Heavy_Weapons_Middle")
					-- local info = 
					-- {
					-- 	Ability = hero:GetAbilityByIndex(1),				--技能
					-- 	EffectName = "particles/sb/Heavy_Weapons_Default.vpcf",	--特效路径
					-- 	vSpawnOrigin = hero:GetAbsOrigin(),					--产生的地点
					-- 	fDistance = (hero:GetAbsOrigin()-Mouse.xyz[pID]):Length(),		--距离
					-- 	fStartRadius = 64,									--开始范围
					-- 	fEndRadius = 64,									--结束范围
					-- 	Source = hero,										--来源单位
					-- 	bHasFrontalCone = false,							--是否是 正面锥形？
					-- 	bReplaceExisting = false,							--是否是 替换现有的？
					-- 	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					-- 	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					-- 	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					-- 	fExpireTime = GameRules:GetGameTime() + 10.0,		--到期时间
					-- 	bDeleteOnHit = false,								--击中时 是否删除
					-- 	vVelocity = hero:GetForwardVector() * 800,			--速率
					-- 	-- vAcceleration = hero:GetForwardVector() * 1800,		--加速度，加速到期？
					-- 	--fMaxSpeed = 10000,									--最大速度
					-- 	bProvidesVision = true,								--是否提供视野
					-- 	iVisionRadius = 1000,								--视野半径
					-- 	iVisionTeamNumber = hero:GetTeamNumber(),			--视野所属队伍
					-- 	bVisibleToEnemies = false,							--视野是否提供给敌人？
					-- 	bDrawsOnMinimap = true,								--是否显示在小地图
					-- 	bIgnoreSource = false								--是否忽视来源
					-- }
					-- projectile = ProjectileManager:CreateLinearProjectile(info)	--发射线性特效
					-- Weapons_Cooldown[pID]["Heavy_Weapons_Middle"] = 2.0								--重置武器时间间隔
					-- hero:GetAbilityByIndex(1):ApplyDataDrivenModifier(hero, hero, "Weapons_Right_Interval",{Duration=2.0}) --
					-- hero:GetAbilityByIndex(1):StartCooldown(0.5)
				end
			end

			Mouse.right[pID] = true

			-- Say(nil, "onMouseDown_Right" , false)
		end
	end, "mouse down _Right", 0 )

	-- 鼠标右键松开
	Convars:RegisterCommand( "onMouseUp_Right", function(name)
		local player = Convars:GetCommandClient()
		if player:GetAssignedHero() then
			local pID = player:GetPlayerID()
			local hero = player:GetAssignedHero()

			Mouse.right[pID] = false

			-- Say(nil, "onMouseUp_Right" , false)
		end
	end, "mouse up _Right", 0 )

	--== 注册移动相关变量
	IsDown_W = {}		--是否 W 按键已按下(上↑)
	IsDown_A = {}		--是否 A 按键已按下(左←)
	IsDown_S = {}		--是否 S 按键已按下(下↓)
	IsDown_D = {}		--是否 D 按键已按下(右→)
	IsPriorityW = {}	--是否 W 按键优先(判断上下↑↓)
	IsPriorityA = {}	--是否 A 按键优先(判断左右←→)
	for pID=0,9 do 
		IsDown_W[pID] = false
		IsDown_A[pID] = false
		IsDown_S[pID] = false
		IsDown_D[pID] = false
		IsPriorityW[pID] = true
		IsPriorityA[pID] = true
	end
	-- W 按键(上↑)
	Convars:RegisterCommand( "UpWalking", function(name)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		if pID > -1 then
			IsDown_W[pID] = true		--W按键 按下
			IsPriorityW[pID] = true	--W按键 优先
			-- Say(nil, "W↑ down", false)
		end
	end, "walking up", 0 )
	Convars:RegisterCommand( "UpWalkingDone", function(name)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		if pID > -1 then
			IsDown_W[pID] = false		--W按键 松开
			IsPriorityW[pID] = false	--W按键 不优先了，S按键 优先
			-- Say(nil, "W↑ up", false)
		end
	end, "walking up", 0 )

	-- S 按键(下↓)
	Convars:RegisterCommand( "DownWalking", function(name)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		if pID > -1 then
			IsDown_S[pID] = true
			IsPriorityW[pID] = false
			-- Say(nil, "S↓ down", false)
		end
	end, "walking down", 0 )
	Convars:RegisterCommand( "DownWalkingDone", function(name)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		if pID > -1 then
			IsDown_S[pID] = false
			IsPriorityW[pID] = true
			-- Say(nil, "S↓ up", false)
		end
	end, "walking down", 0 )

	-- A 按键(左←)
	Convars:RegisterCommand( "LeftWalking", function(name)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		if pID > -1 then
			IsDown_A[pID] = true
			IsPriorityA[pID] = true
			-- Say(nil, "A← down", false)
		end
	end, "walking left", 0 )
	Convars:RegisterCommand( "LeftWalkingDone", function(name)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		if pID > -1 then
			IsDown_A[pID] = false
			IsPriorityA[pID] = false
			-- Say(nil, "A← up", false)
		end
	end, "walking left", 0 )

	-- D 按键(右→)
	Convars:RegisterCommand( "RightWalking", function(name)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		if pID > -1 then
			IsDown_D[pID] = true
			IsPriorityA[pID] = false
			-- Say(nil, "D→ down", false)
		end
	end, "walking left", 0 )
	Convars:RegisterCommand( "RightWalkingDone", function(name)
		local player = Convars:GetCommandClient()
		local pID = player:GetPlayerID()
		if pID > -1 then
			IsDown_D[pID] = false
			IsPriorityA[pID] = true
			-- Say(nil, "D→ up", false)
		end
	end, "walking left", 0 )

end

--------------------------------------------------------------------------------
-- 伤害半径的敌方单位(伤害来源单位，伤害值，目标点，范围)
--------------------------------------------------------------------------------
function ApplyDamageInRadius(caster,damage,point,radius)
	local target_entities = FindUnitsInRadius(
							caster:GetTeam(),
							point,
							nil,
							radius,
							DOTA_UNIT_TARGET_TEAM_ENEMY,
							DOTA_UNIT_TARGET_ALL,
							DOTA_UNIT_TARGET_FLAG_NONE,
							FIND_CLOSEST,
							false)

	for i, target in ipairs(target_entities) do
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
		}
		ApplyDamage(damageTable)
	end

end