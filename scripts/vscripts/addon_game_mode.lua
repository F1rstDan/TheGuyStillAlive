-- load everyhing
require('require_everything')
hulage=0
if SBGameMode == nil then
	SBGameMode = class({})
end

function PrecacheEveryThingFromKV( context )
	local kv_files = {"scripts/npc/npc_units_custom.txt","scripts/npc/npc_abilities_custom.txt","scripts/npc/npc_heroes_custom.txt","scripts/npc/npc_abilities_override.txt","npc_items_custom.txt"}
	for _, kv in pairs(kv_files) do
		local kvs = LoadKeyValues(kv)
		if kvs then
			print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
			PrecacheEverythingFromTable( context, kvs)
		end
	end
end
function PrecacheEverythingFromTable( context, kvtable)
	for key, value in pairs(kvtable) do
		if type(value) == "table" then
			PrecacheEverythingFromTable( context, value )
		else
			if string.find(value, "vpcf") then
				PrecacheResource( "particle",  value, context)
				print("PRECACHE PARTICLE RESOURCE", value)
			end
			if string.find(value, "vmdl") then
				PrecacheResource( "model",  value, context)
				print("PRECACHE MODEL RESOURCE", value)
			end
			if string.find(value, "vsndevts") then
				PrecacheResource( "soundfile",  value, context)
				print("PRECACHE SOUND RESOURCE", value)
			end
		end
	end
end
function Precache( context )
	print("BEGIN TO PRECACHE RESOURCE")
	local time = GameRules:GetGameTime()
	PrecacheEveryThingFromKV( context )
	time = time - GameRules:GetGameTime()
	print("DONE PRECACHEING IN:"..tostring(time).."Seconds")

	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	PrecacheResource( "particle_folder", "particles/sb", context )
	-- PrecacheResource( "particle_folder", "particles/units/heroes/hero_mirana", context )
	-- PrecacheResource( "particle", "particles/gyro_base_attack.vpcf", context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = SBGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function SBGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

	Global:InitGameMode()

	--注册命令和向控制台发布命令
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("SendToConsole"),function()
			--SendToConsole("scaleform_spew 1")				--显示flash打印
			SendToConsole("dota_render_y_inset 0")			--顶部开始渲染高度
			SendToConsole("dota_render_crop_height 0")		--底部开始渲染高度
			SendToConsole("dota_camera_distance 1600")		--视角高度

			SendToConsole("dota_sf_hud_actionpanel 0")		--隐藏操作栏UI
			SendToConsole("dota_sf_hud_inventory 0")		--隐藏物品栏UI
			

			SBGameMode:BindHotKey()							--绑定键位
			-- 为UI注册命令
			Convars:RegisterCommand( "BindHotKey_WASD", function(name)
				-- local player = Convars:GetCommandClient()
				-- local pID = player:GetPlayerID()
				SBGameMode:BindHotKey()							--绑定键位
			end, "BindHotKey", 0 )
			return nil
	end,1)

	
end

-- Evaluate the state of the game
function SBGameMode:OnThink()
   	  if hulage==0 then
        player_init()
        hulage=1
      end

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

--------------------------------------------------------------------------------
-- 注册命令
--------------------------------------------------------------------------------
function SBGameMode:BindHotKey()
	--SendToConsole("unbindall");								--解除全部按键绑定
	SendToConsole("alias \"+move_up\" \"UpWalking\"");
	SendToConsole("alias \"-move_up\" \"UpWalkingDone\"");
	SendToConsole("alias \"+move_down\" \"DownWalking\"");
	SendToConsole("alias \"-move_down\" \"DownWalkingDone\"");
	SendToConsole("bind w +move_up");
	SendToConsole("bind s +move_down");
	SendToConsole("bind uparrow +move_up");
	SendToConsole("bind downarrow +move_down");

	SendToConsole("alias \"+move_left\" \"LeftWalking\"");
	SendToConsole("alias \"-move_left\" \"LeftWalkingDone\"");
	SendToConsole("alias \"+move_right\" \"RightWalking\"");
	SendToConsole("alias \"-move_right\" \"RightWalkingDone\"");
	SendToConsole("bind a +move_left");
	SendToConsole("bind d +move_right");
	SendToConsole("bind leftarrow +move_left");
	SendToConsole("bind rightarrow +move_right");
end
