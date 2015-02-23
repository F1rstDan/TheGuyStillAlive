--玩家初始数据数组
PlayerS = {}
--房间地形网格初始数组   
position={}
function player_init() 

    local temp=Entities:FindByName(nil,"zibao") --所有单位假死沉睡的最终之地 神之居所瓦尔哈拉！
    zibao=temp:GetAbsOrigin()
    
    --初始化房间内所有网格位置
    local tempvec=(Entities:FindByName(nil,"pos1")):GetAbsOrigin()

      	for i=1,16,1 do
    		position[i]={}
        	for j=1,16,1 do
        		--生成地形
        		position[i][j]=Vector(tempvec.x+i*300-300,tempvec.y-j*300+300,tempvec.z) 
        	end	
        end
    room_x=0
    room_y=0
    room={}                    --存储房间数据
    room_enter(room_x,room_y)  --进入起始房间
    
    local temp=Entities:FindByName(nil,"leftpos")
    vecleft=temp:GetAbsOrigin()
    local temp=Entities:FindByName(nil,"rightpos")
    vecright=temp:GetAbsOrigin()
    local temp=Entities:FindByName(nil,"uppos")
    vecup=temp:GetAbsOrigin()
    local temp=Entities:FindByName(nil,"downpos")
    vecdown=temp:GetAbsOrigin()
    print("vecval")
    print(vecleft.x,vecleft.y)
    print(vecright.x,vecright.y)
end
