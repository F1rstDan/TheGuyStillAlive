
 
function LeftStart(trigger)
    --离开现在的房间 前往左边的房间 设置触发旗帜确保传送后不会立即触发下一个门
    if stand_flag==0 then
      leave_curroom()
      room_x=room_x-1
      room_enter(room_x,room_y)
      FindClearSpaceForUnit(trigger.activator, vecright, false) 
      stand_flag=1
    end  
end

function LeftEnd(trigger)
    --离开现有触发口时旗帜清空
    stand_flag=0
end    

function RightStart(trigger)

    if stand_flag==0 then
      leave_curroom()
      room_x=room_x+1
      room_enter(room_x,room_y)
      FindClearSpaceForUnit(trigger.activator, vecleft, false) 
      stand_flag=1
    end  
end

function RightEnd(trigger)
    --离开现有触发口时旗帜清空
    stand_flag=0
end

function UpStart(trigger)

    if stand_flag==0 then
      leave_curroom()
      room_y=room_y-1
      room_enter(room_x,room_y)
      FindClearSpaceForUnit(trigger.activator, vecdown, false) 
      stand_flag=1
    end  
end

function UpEnd(trigger)
    --离开现有触发口时旗帜清空
    stand_flag=0
end 

function DownStart(trigger)

    if stand_flag==0 then
      leave_curroom()
      room_y=room_y+1
      room_enter(room_x,room_y)
      FindClearSpaceForUnit(trigger.activator, vecup, false) 
      stand_flag=1
    end  
end

function DownEnd(trigger)
    --离开现有触发口时旗帜清空
    stand_flag=0
end 