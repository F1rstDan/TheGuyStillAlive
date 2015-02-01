package {
	import flash.display.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;

	import ValveLib.*;
	import scaleform.gfx.*;

	import flash.utils.*;
	import __AS3__.vec.*;

	//import flash.display.MovieClip;
	//import flash.events.MouseEvent;

	//输入一些从valve的库中提取的素材 import some stuff from the valve lib
	//import ValveLib.Globals;
	//import ValveLib.ResizeManager;
	
	public class ShootingUI extends MovieClip{
		
		//引擎需要这3个变量 these three variables are required by the engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		public var timerMouseXY:Timer = new Timer(100, 0); //检测变化的时间,1000为1秒
		
		//构造函数, 通常会用加载完函数来代替 constructor, you usually will use onLoaded() instead
		public function ShootingUI() : void {
		}
		
		//这个函数被调用 this function is called when the UI is loaded
		public function onLoaded() : void {			
			//使这个UI可见 make this UI visible
			visible = true;
			
			//让平台重新调节UI let the client rescale the UI
			Globals.instance.resizeManager.AddListener(this);
			
			//这一步不是必须的, 但是可以显示你的UI已经加载（需要在控制台中输入'scaleform_spew 1'） this is not needed, but it shows you your UI has loaded (needs 'scaleform_spew 1' in console)
			trace("===Shooting Custom UI loaded!===");

			//监听鼠标移动
			stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove_SendServerCommand);
			timerMouseXY.addEventListener(TimerEvent.TIMER_COMPLETE, this.onTimer_SendServerCommand);

			this.Shooting.buttonMode = true;
			this.Shooting.addEventListener(MouseEvent.MOUSE_DOWN,	this.onMouseDown_Shooting);
			this.Shooting.addEventListener(MouseEvent.MOUSE_UP,		this.onMouseUp_Stop);
		}

		public function onMouseMove_SendServerCommand(event:MouseEvent):void
		{
			var xyz:String = globals.Game.ScreenXYToWorld(stage.mouseX, stage.mouseY)
			var xyz_array:Array = xyz.split(",");
			//trace("ScreenXYToWorld =" + xyz );
			this.gameAPI.SendServerCommand("onMouseMove " + xyz_array[0] +" " + xyz_array[1] +" " + xyz_array[2] );	//发送到lua
		}
		public function onTimer_SendServerCommand(event:TimerEvent):void
		{
			var xyz:String = globals.Game.ScreenXYToWorld(stage.mouseX, stage.mouseY)
			var xyz_array:Array = xyz.split(",");
			//trace("ScreenXYToWorld =" + xyz );
			this.gameAPI.SendServerCommand("onMouseMove " + xyz_array[0] +" " + xyz_array[1] +" " + xyz_array[2] );	//发送到lua
		}

		public function onMouseDown_Shooting(event:MouseEvent):void
		{
			//MouseEventEx:LEFT_BUTTON, RIGHT_BUTTON,MIDDLE_BUTTON
			var _loc_3:MouseEventEx = event as MouseEventEx;
			if (_loc_3.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				this.gameAPI.SendServerCommand("onMouseDown_Right");	//发送到lua
			}
			else
			{
				this.gameAPI.SendServerCommand("onMouseDown_Left");		//发送到lua
			}

			timerMouseXY.start();	//按下时发送鼠标位置
		}
		public function onMouseUp_Stop(event:MouseEvent):void
		{
			var _loc_3:MouseEventEx = event as MouseEventEx;
			if (_loc_3.buttonIdx == MouseEventEx.RIGHT_BUTTON)
			{
				this.gameAPI.SendServerCommand("onMouseUp_Right");		//发送到lua
			}
			else
			{
				this.gameAPI.SendServerCommand("onMouseUp_Left");		//发送到lua
				timerMouseXY.reset();	//松开时停止发送鼠标位置
			}
		}
		
		//这个负责调节大小, 将UI的尺寸设置为你的电脑屏幕的尺寸（感谢Nullscope的建议） this handles the resizes - credits to Nullscope
		public function onResize(re:ResizeManager) : * {
			var rm = Globals.instance.resizeManager;
			var currentRatio:Number =  re.ScreenWidth / re.ScreenHeight;
			var divided:Number;

			// 把这个调成你的舞台高度，如果你的设备不支持1024*768尺寸，你可以修改它 Set this to your stage height, however, if your assets are too big/small for 1024x768, you can change it
			// 你的原始阶段高度 Your original stage height
			var originalHeight:Number = 900;
			
			if(currentRatio < 1.5)
			{
				// 4:3
				divided = currentRatio / 1.333;
			}
			else if(re.Is16by9()){
				// 16:9
				divided = currentRatio / 1.7778;
			} else {
				// 16:10
				divided = currentRatio / 1.6;
			}
			
			var correctedRatio:Number =  re.ScreenHeight / originalHeight * divided;
			//你也许想在这里把元件的尺寸也决定了，默认情况下它们保持着同样的高和宽。 You will probably want to scale your elements by here, they keep the same width and height by default.
			//即使在重新调整大小之后，引擎也会使所有元件保持同样的XY轴坐标, 所以你也可以在这里进行调整。 The engine keeps elements at the same X and Y coordinates even after resizing, you will probably want to adjust that here.
			
			if(this.Shooting["originalXScale"] == null)
			{
				this.Shooting["originalXScale"] = this.scaleX;
				this.Shooting["originalYScale"] = this.scaleY;
			}
			this.Shooting.scaleX = this.Shooting.originalXScale * correctedRatio;
			this.Shooting.scaleY = this.Shooting.originalYScale * correctedRatio;
			this.Shooting.x = re.ScreenWidth/2;
			this.Shooting.y = re.ScreenHeight/2;
		}
	}
}