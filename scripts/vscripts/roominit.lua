--房间table数据
--[[
  1 房间类型
  2 地形数组
    16*16
  3 初始单位位置数组
    16*16
  4 房间刷新flag
]]
--现有房间地形砖块数量和储存表
curroom_block_num=0;
curroom_block={}
function room_enter(room_x,room_y)
        
    if room[room_x]==nil then
    	room[room_x]={}
    end

    if room[room_x][room_y]==nil then --从未进过的处女房间
        room[room_x][room_y]={}
        room[room_x][room_y][1]=math.random(16)   --生成房间类型号
                                             --1 天使房
                                             --2 恶魔房
                                             --3 宝箱房
                                             --4 隐藏boss房
                                             --5-7 普通房1型
                                             --8-10 普通房2型
                                             --11-13 普通房3型
                                             --14-15 普通房4型
        room[room_x][room_y][2]={}
        for i=1,16,1 do
        	room[room_x][room_y][2][i]={}
        	for j=1,16,1 do
        		--随机生成地形
        		room[room_x][room_y][2][i][j]=math.random(20)
        		if room[room_x][room_y][2][i][j]>10 then
        			room[room_x][room_y][2][i][j]=1
        		else
        			room[room_x][room_y][2][i][j]=0
        		end
        	end	
        end
    end
    --重新建立房间
    room_create(room_x,room_y)
end

function room_create(room_x,room_y)
	for i=1,16,1 do
        	for j=1,16,1 do
        		--生成地形
        		if room[room_x][room_y][2][i][j]==1 then
        		  curroom_block_num=curroom_block_num+1
        		  curroom_block[curroom_block_num]=CreateUnitByName("wall", position[i][j], false, nil, nil, DOTA_TEAM_BADGUYS) --地形block进表
        		end
        	end	
        end
end

function leave_curroom()
  --破坏所有现有地形	
  for i=1,curroom_block_num,1 do
    if  curroom_block[i]:IsAlive() then 
      curroom_block[i]:SetAbsOrigin(zibao)
      curroom_block[i]:ForceKill(true)
    end  
  end
  curroom_block_num=0
end	