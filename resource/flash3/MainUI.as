package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.System;

	import ValveLib.*;
	import scaleform.*;
	
	public class MainUI extends MovieClip{
		
		//引擎需要这3个变量 these three variables are required by the engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		//public var OpenPanelBtn:MovieClip;
		public var IsOpenPanel:Boolean;

		public var HotKeysPanelButton:MovieClip;	//游戏 操作说明
		public var HowToPlayPanelButton:MovieClip;	//如何游戏
		public var InfoPanelButton:MovieClip;		//信息
		public var MainPanelCloseButton:MovieClip;	//关闭窗口

		public var HotKeysPanel_bindWASD:MovieClip;	//重新绑定WASD按键
		
		//构造函数, 通常会用加载完函数来代替 constructor, you usually will use onLoaded() instead
		public function MainUI() : void {
		}
		
		//这个函数被调用 this function is called when the UI is loaded
		public function onLoaded() : void {			
			//使这个UI可见 make this UI visible
			visible = true;
			
			//让平台重新调节UI let the client rescale the UI
			Globals.instance.resizeManager.AddListener(this);
			
			//这一步不是必须的, 但是可以显示你的UI已经加载（需要在控制台中输入'scaleform_spew 1'） this is not needed, but it shows you your UI has loaded (needs 'scaleform_spew 1' in console)
			trace("Custom UI loaded!");

			//提醒玩家的错误信息
			this.gameAPI.SubscribeToGameEvent("custom_error_show", this.showError);
			//锁定镜头
			Globals.instance.GameInterface.SetConvar("dota_camera_lock", "1");	

			//左上角打开面板的按钮，及版本号
			this.OpenPanelBtn.buttonMode = true;
			this.OpenPanelBtn.addEventListener(MouseEvent.ROLL_OVER, this.OpenPanelOver);
			this.OpenPanelBtn.addEventListener(MouseEvent.ROLL_OUT, this.OpenPanelOverOut);
			this.OpenPanelBtn.addEventListener(MouseEvent.CLICK, this.OpenPanelToggle);
			IsOpenPanel = true;
			this.OpenPanelBtn.gotoAndStop(3);

			//第1个选项卡
			this.HotKeysPanelButton = this.replaceWithValveComponent(this.Panel.HotKeysPanelButton, "d_RadioButton_2nd", true);
			this.HotKeysPanelButton.label = "#UI_HotKeysPanelButton";
			this.HotKeysPanelButton.selected = true;	//默认已选择该选项卡
			this.HotKeysPanelButton.addEventListener(MouseEvent.CLICK, this.OpenPanelTab1);

			//第2个选项卡
			this.HowToPlayPanelButton = this.replaceWithValveComponent(this.Panel.HowToPlayPanelButton, "d_RadioButton_2nd", true);
			this.HowToPlayPanelButton.label = "#UI_HowToPlayPanelButton";
			//this.HowToPlayPanelButton.enabled = false;
			this.HowToPlayPanelButton.addEventListener(MouseEvent.CLICK, this.OpenPanelTab2);
			this.Panel.HowToPlayPanel.visible = false;

			//第3个选项卡
			this.InfoPanelButton = this.replaceWithValveComponent(this.Panel.InfoPanelButton, "d_RadioButton_2nd", true);
			this.InfoPanelButton.label = "#UI_InfoPanelButton";
			this.InfoPanelButton.addEventListener(MouseEvent.CLICK, this.OpenPanelTab3);
			this.Panel.InfoPanel.visible = false;
			this.replaceWithValveComponent(this.Panel.InfoPanel.DB4_bg.bg, "DB4_floading_panel", true);	//替换背景
			//this.Panel.InfoPanel.DB4_bg.visible = false;

			//关闭窗口按钮
			this.MainPanelCloseButton = this.replaceWithValveComponent(this.Panel.closeBtn, "s_closeBtn", true);
			this.MainPanelCloseButton.addEventListener(MouseEvent.CLICK, this.CloseMainPanel);

			//重绑WASD热键
			this.HotKeysPanel_bindWASD = this.replaceWithValveComponent(this.Panel.HotKeysPanel.bindWASD, "chrome_button_primary", true);
			this.HotKeysPanel_bindWASD.label = "#UI_HotKeysPanel_bindWASD";
			this.HotKeysPanel_bindWASD.addEventListener(MouseEvent.CLICK, this.BindHotKeys);
		}

		//无法复制文字
		public function copyText(event:MouseEvent):void
		{
			System.setClipboard(this.Panel.InfoPanel.email.text);
		}

		public function OpenPanelTab1(event:MouseEvent):void
		{
			this.Panel.HotKeysPanel.visible = true;
			this.Panel.HowToPlayPanel.visible = false;
			this.Panel.InfoPanel.visible = false;
		}
		public function OpenPanelTab2(event:MouseEvent):void
		{
			this.Panel.HotKeysPanel.visible = false;
			this.Panel.HowToPlayPanel.visible = true;
			this.Panel.InfoPanel.visible = false;
		}
		public function OpenPanelTab3(event:MouseEvent):void
		{
			this.Panel.HotKeysPanel.visible = false;
			this.Panel.HowToPlayPanel.visible = false;
			this.Panel.InfoPanel.visible = true;
		}
		public function BindHotKeys(event:MouseEvent):void
		{
			this.gameAPI.SendServerCommand("BindHotKey_WASD");
			//this.gameAPI.SendServerCommand("bind w +move_up");
			//this.gameAPI.SendServerCommand("bind s +move_down");
			//this.gameAPI.SendServerCommand("bind uparrow +move_up");
			//this.gameAPI.SendServerCommand("bind downarrow +move_down");

			//this.gameAPI.SendServerCommand("bind a +move_left");
			//this.gameAPI.SendServerCommand("bind d +move_right");
			//this.gameAPI.SendServerCommand("bind leftarrow +move_left");
			//this.gameAPI.SendServerCommand("bind rightarrow +move_right");
		}

		public function OpenPanelOver(event:MouseEvent):void
		{
			event.currentTarget.gotoAndStop(2);
		}
		public function OpenPanelOverOut(event:MouseEvent):void
		{
			if(IsOpenPanel)
			{
				event.currentTarget.gotoAndStop(3);
			}else{
				event.currentTarget.gotoAndStop(1);
			}
		}
		public function OpenPanelToggle(event:MouseEvent):void
		{
			if(IsOpenPanel)
			{
				IsOpenPanel = false;
				event.currentTarget.gotoAndStop(1);
				this.Panel.visible = false;
			}else{
				IsOpenPanel = true;
				event.currentTarget.gotoAndStop(3);
				this.Panel.visible = true;
			}
		}
		public function CloseMainPanel(event:MouseEvent):void
		{
			IsOpenPanel = false;
			this.Panel.visible = false;
			this.OpenPanelBtn.gotoAndStop(1);
		}
		
		//这个负责调节大小, 将UI的尺寸设置为你的电脑屏幕的尺寸（感谢Nullscope的建议） this handles the resizes - credits to Nullscope
		public function onResize(re:ResizeManager) : * {
			var rm = Globals.instance.resizeManager;
			var currentRatio:Number =  re.ScreenWidth / re.ScreenHeight;
			var divided:Number;
			var OpenPanelBtn_X:Number; 			//占屏幕x的比例，打开面板的按钮
			var ActionPanel_portraitX:Number;	//头像x坐标

			// 把这个调成你的舞台高度，如果你的设备不支持1024*768尺寸，你可以修改它 Set this to your stage height, however, if your assets are too big/small for 1024x768, you can change it
			// 你的原始阶段高度 Your original stage height
			var originalHeight:Number = 900;
			
			if(currentRatio < 1.5)
			{
				// 4:3
				divided = currentRatio / 1.333;
				OpenPanelBtn_X = 0.146;
				//ActionPanel_portraitX = re.ScreenWidth * 0.200
				ActionPanel_portraitX = 480;
			}
			else if(re.Is16by9()){
				// 16:9
				divided = currentRatio / 1.7778;
				OpenPanelBtn_X = 0.113;
				//ActionPanel_portraitX = re.ScreenWidth * 0.228
				ActionPanel_portraitX = 780;
			} else {
				// 16:10
				divided = currentRatio / 1.6;
				OpenPanelBtn_X = 0.125;
				//ActionPanel_portraitX = re.ScreenWidth * 0.195
				ActionPanel_portraitX = 605;
			}
			
			var correctedRatio:Number =  re.ScreenHeight / originalHeight * divided;
			//你也许想在这里把元件的尺寸也决定了，默认情况下它们保持着同样的高和宽。 You will probably want to scale your elements by here, they keep the same width and height by default.
			//即使在重新调整大小之后，引擎也会使所有元件保持同样的XY轴坐标, 所以你也可以在这里进行调整。 The engine keeps elements at the same X and Y coordinates even after resizing, you will probably want to adjust that here.
			
			//左上 打开说明面板的按钮
			if(this.OpenPanelBtn["originalXScale"] == null)
			{
				this.OpenPanelBtn["originalXScale"] = this.scaleX;
				this.OpenPanelBtn["originalYScale"] = this.scaleY;
			}
			this.OpenPanelBtn.scaleX = this.OpenPanelBtn.originalXScale * correctedRatio;
			this.OpenPanelBtn.scaleY = this.OpenPanelBtn.originalYScale * correctedRatio;
			this.OpenPanelBtn.x = re.ScreenWidth * OpenPanelBtn_X;
			//this.OpenPanelBtn.y = 5;

			//左下 小地图+头像
			if(this.ActionPanel["originalXScale"] == null)
			{
				this.ActionPanel["originalXScale"] = this.scaleX;
				this.ActionPanel["originalYScale"] = this.scaleY;
			}
			this.ActionPanel.scaleX = this.ActionPanel.originalXScale * correctedRatio * 0.47;
			this.ActionPanel.scaleY = this.ActionPanel.originalYScale * correctedRatio * 0.47;
			this.ActionPanel.x = 0;
			this.ActionPanel.y = re.ScreenHeight;
			this.ActionPanel.portrait_wide.x = ActionPanel_portraitX;

			//右下 结构图+物品栏
			if(this.EquipPanel["originalXScale"] == null)
			{
				this.EquipPanel["originalXScale"] = this.scaleX;
				this.EquipPanel["originalYScale"] = this.scaleY;
			}
			this.EquipPanel.scaleX = this.EquipPanel.originalXScale * correctedRatio * 0.47;
			this.EquipPanel.scaleY = this.EquipPanel.originalYScale * correctedRatio * 0.47;
			this.EquipPanel.x = re.ScreenWidth;
			this.EquipPanel.y = re.ScreenHeight;
			this.EquipPanel.Chart.x = -ActionPanel_portraitX;


		}

		//private
		public function replaceWithValveComponent(mc:MovieClip, type:String, keepDimensions:Boolean = false):MovieClip{
			var parent = mc.parent;
			var oldx = mc.x;
			var oldy = mc.y;
			var oldwidth = mc.width;
			var oldheight = mc.height;

			if (type == "d_RadioButton_2nd") {
				oldwidth = oldwidth +4;
				oldheight = oldheight +5;
			}

			var newObjectClass = getDefinitionByName(type);
			var newObject = new newObjectClass();
			newObject.x = oldx;
			newObject.y = oldy;
			if (keepDimensions) {
				newObject.width = oldwidth;
				newObject.height = oldheight;
			}

			parent.removeChild(mc);
			parent.addChild(newObject);

			return newObject;
		}

		public function showError( args:Object ){
			var pID:int = this.globals.Players.GetLocalPlayer();
			
			if( pID == args.player_ID ) {
				this.globals.Loader_error_msg.movieClip.setErrorMsg(args._error);
			}
		}
	}
}