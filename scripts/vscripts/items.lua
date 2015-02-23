if NEXT_itemID == nil then
	NEXT_itemID = 1
	ITEMS = {} --填入iID
end

--------------------------------------------------------------------------------
-- 物品马甲单位 遇到英雄的触发
--------------------------------------------------------------------------------
function PickUpItems(keys)
	local item = keys.caster
	local hero = keys.target

	item:RemoveSelf()
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------
function CreateItemForHero(itemname,hero,place_slot)
	-- 想弄，如果ITEMS[NEXT_itemID]不为空，则一直加下去。但是脑子短路了，
	-- for i = 1,ITEMS[NEXT_itemID] == nil do
	-- 	NEXT_itemID = NEXT_itemID +1
	-- 	print( "NEXT_itemID = ",NEXT_itemID )
	-- end
	while ITEMS[NEXT_itemID] ~= nil do
		NEXT_itemID = NEXT_itemID +1
		print( "NEXT_itemID += ",NEXT_itemID )
	end
	
	--已完成*判断武器的击中是否删除 弹道，以此还分配技能
	--已完成*创建技能，(击中删除弹道)and(击中不删除弹道) *3个槽位。共6个技能
	--已完成*武器槽位,技能序号 0.重武器 1.轻武器左 2.轻武器右
	--已完成*保存iID，生产 物品
	--todo*发送到AS中，物品的生成，带上装备

	local pID = hero:GetPlayerID()
	local iID = NEXT_itemID
	print( "NEXT_itemID = ",NEXT_itemID )
	ITEMS[iID] = {}
	NEXT_itemID = NEXT_itemID +1

	local weapons_data = WeaponsDataKv[itemname]

	--击中时 是否删除
	if tonumber(weapons_data.DeleteOnHit) >= 1 then
		ITEMS[iID].DeleteOnHit = true
	else
		ITEMS[iID].DeleteOnHit = false
	end

	ITEMS[iID].ItemName		= itemname
	ITEMS[iID].TextureName	= weapons_data.TextureName						or "gyrocopter_flak_cannon"
	ITEMS[iID].EffectName	= weapons_data.EffectName						or "particles/sb/Heavy_Weapons_Default.vpcf"
	ITEMS[iID].Damage		= tonumber(weapons_data.Damage)					or 10
	ITEMS[iID].Cooldown		= tonumber(weapons_data.Cooldown)				or 0.5
	ITEMS[iID].ManaCost		= tonumber(weapons_data.ManaCost)				or 25
	ITEMS[iID].Distance		= tonumber(weapons_data.Distance)				or 2000.0
	ITEMS[iID].MoveSpeed	= tonumber(weapons_data.MoveSpeed)				or 1600.0
	ITEMS[iID].StartRadius	= tonumber(weapons_data.StartRadius)			or 32.0
	ITEMS[iID].EndRadius	= tonumber(weapons_data.EndRadius)				or 32.0


	--是否 根据鼠标位置 攻击到地点
	if tonumber(weapons_data.IsAttackToPosition) >= 1 then
		ITEMS[iID].IsAttackToPosition = true
	else
		ITEMS[iID].IsAttackToPosition = false
	end

	--是否锥形范围
	if tonumber(weapons_data.HasFrontalCone) >= 1 then
		ITEMS[iID].HasFrontalCone = true
	else
		ITEMS[iID].HasFrontalCone = false
	end

	--是否
	if tonumber(weapons_data.CanBeLight) >= 1 then
		ITEMS[iID].CanBeLight = true
	else
		ITEMS[iID].CanBeLight = false
	end
	--是否
	if tonumber(weapons_data.CanBeHeavy) >= 1 then
		ITEMS[iID].CanBeHeavy = true
	else
		ITEMS[iID].CanBeHeavy = false
	end

	--发送到AS
	local item_data_table = {
		nPlayerID		= pID,
		sPlaceSlot		= place_slot,
		nItemID			= iID,
		bCanBeLight		= ITEMS[iID].CanBeLight,
		bCanBeHeavy		= ITEMS[iID].CanBeHeavy,
		sItemName		= itemname,
		sTextureName	= weapons_data.TextureName
	}
	FireGameEvent( "Send_Item_Data", item_data_table )

	if place_slot == "Light_Weapons_Left" or place_slot == "Light_Weapons_Right" or place_slot == "Heavy_Weapons_Middle" then
		local weapons_slot = place_slot
		if hero[weapons_slot] == nil then
			hero[weapons_slot] = {}
		end
		--击中时 是否删除
		if tonumber(weapons_data.DeleteOnHit) >= 1 then
 			ability = hero:FindAbilityByName(weapons_slot.."_DeleteOnHit")
		else
			ability = hero:FindAbilityByName(weapons_slot.."_NoDeleteOnHit")
		end
		hero[weapons_slot].Ability		= ability
		hero[weapons_slot].ItemID		= iID
	end

end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------
function CreateItemForGround(keys)
	
end