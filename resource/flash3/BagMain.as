package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;

	import fl.motion.ColorMatrix;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	//import flash.system.System;

	import ValveLib.*;
	import scaleform.*;
	
	public class BagMain extends MovieClip{
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		public var i:int;
		public var OverMC:MovieClip;
		public var DargMc:MovieClip;
		public var ITEMS:Array;		//保存物品信息
		public var Bag_iID:Array;	//保存背包含有什么物品
		public var Bag_pages:int;	//背包当前页


		public function onLoaded(api:Object,glob:Object) : void {
			this.gameAPI = api;
			this.globals = glob;
			this.ITEMS = new  Array();
			this.Bag_iID = new  Array();
			this.Bag_pages = 1;
			this.Bag_iID[Bag_pages] = new  Array();
			this.i = 1;
			while ( i <= 21 )
			{
				this.Bag_iID[Bag_pages][i] = -1;
				i++;
				trace("this.Bag_iID[Bag_pages][i] = ",i);
			}

			gameAPI.SubscribeToGameEvent( "Send_Item_Data", onSendItemData );

			this.addEventListener(MouseEvent.MOUSE_DOWN, this.onItemMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, this.onItemMouseUp);
			//this.addEventListener(MouseEvent.ROLL_OUT, this.onDargOut);
			this.bagslot_img.visible = false;
			this.bagslot_img.mouseEnabled = false;
			this.bagslot_img.mouseChildren = false;
			
			this.i = 1;
			while (this.i < 21) {

				this.Inventory[("bagslot" +i)]["slot"] = i;
				this.Inventory[("bagslot" +i)]["isDrag"] = false;
				this.Inventory[("bagslot" +i)]["iID"] = -1;		// -1代表没有东西
				this.Inventory[("bagslot" +i)]["where"] = "inbag";	//"inbag","equip","package"
				//this.Inventory[("bagslot" +i)]["type"] = "weapons";
				this.Inventory[("bagslot" +i)]["image"] = "invoker_empty1.png";
				this.Inventory[("bagslot" +i)]._icon.alpha = 0;
				this.Inventory[("bagslot" +i)].addEventListener(MouseEvent.ROLL_OVER, this.onBagSlotRollOver);
				this.Inventory[("bagslot" +i)].addEventListener(MouseEvent.ROLL_OUT, this.onBagSlotRollOut);
				this.i++;
			};
			this.Equip.Heavy_Weapons_Middle["slot"] = "Heavy_Weapons_Middle";
			this.Equip.Heavy_Weapons_Middle["isDrag"] = false;
			this.Equip.Heavy_Weapons_Middle["iID"] = -1;		// -1代表没有东西
			this.Equip.Heavy_Weapons_Middle["where"] = "equip";	//"inbag","equip","package"
			this.Equip.Heavy_Weapons_Middle["image"] = "invoker_empty1.png";
			this.Equip.Heavy_Weapons_Middle._icon.alpha = 0;
			Globals.instance.LoadImage("images/ui/Equip_box.png",this.Equip.Heavy_Weapons_Middle._isequip,false);	//设置图标
			this.Equip.Heavy_Weapons_Middle.addEventListener(MouseEvent.ROLL_OVER, this.onBagSlotRollOver);
			this.Equip.Heavy_Weapons_Middle.addEventListener(MouseEvent.ROLL_OUT, this.onBagSlotRollOut);
			this.Equip.Light_Weapons_Left["slot"] = "Light_Weapons_Left";
			this.Equip.Light_Weapons_Left["isDrag"] = false;
			this.Equip.Light_Weapons_Left["iID"] = -1;		// -1代表没有东西
			this.Equip.Light_Weapons_Left["where"] = "equip";	//"inbag","equip","package"
			this.Equip.Light_Weapons_Left["image"] = "invoker_empty1.png";
			this.Equip.Light_Weapons_Left._icon.alpha = 0;
			Globals.instance.LoadImage("images/ui/Equip_box.png",this.Equip.Light_Weapons_Left._isequip,false);	//设置图标
			this.Equip.Light_Weapons_Left.addEventListener(MouseEvent.ROLL_OVER, this.onBagSlotRollOver);
			this.Equip.Light_Weapons_Left.addEventListener(MouseEvent.ROLL_OUT, this.onBagSlotRollOut);
			this.Equip.Light_Weapons_Right["slot"] = "Light_Weapons_Right";
			this.Equip.Light_Weapons_Right["isDrag"] = false;
			this.Equip.Light_Weapons_Right["iID"] = -1;		// -1代表没有东西
			this.Equip.Light_Weapons_Right["where"] = "equip";	//"inbag","equip","package"
			this.Equip.Light_Weapons_Right["image"] = "invoker_empty1.png";
			this.Equip.Light_Weapons_Right._icon.alpha = 0;
			Globals.instance.LoadImage("images/ui/Equip_box.png",this.Equip.Light_Weapons_Right._isequip,false);	//设置图标
			this.Equip.Light_Weapons_Right.addEventListener(MouseEvent.ROLL_OVER, this.onBagSlotRollOver);
			this.Equip.Light_Weapons_Right.addEventListener(MouseEvent.ROLL_OUT, this.onBagSlotRollOut);


			//预设值，测试用，可删
			//this.Equip.Heavy_Weapons_Middle._icon.alpha = 1;
			//this.Equip.Heavy_Weapons_Middle.iID = 3;
			//this.Equip.Heavy_Weapons_Middle.image = "gyrocopter_homing_missile.png";
			//Globals.instance.LoadImage("images/spellicons/gyrocopter_homing_missile.png",this.Equip.Heavy_Weapons_Middle._icon,false);	//设置图标
			//this.Equip.Light_Weapons_Left._icon.alpha = 1;
			//this.Equip.Light_Weapons_Left.iID = 3;
			//this.Equip.Light_Weapons_Left.image = "gyrocopter_rocket_barrage.png";
			//Globals.instance.LoadImage("images/spellicons/gyrocopter_rocket_barrage.png",this.Equip.Light_Weapons_Left._icon,false);	//设置图标
			//this.Equip.Light_Weapons_Right._icon.alpha = 1;
			//this.Equip.Light_Weapons_Right.iID = 3;
			//this.Equip.Light_Weapons_Right.image = "gyrocopter_rocket_barrage.png";
			//Globals.instance.LoadImage("images/spellicons/gyrocopter_rocket_barrage.png",this.Equip.Light_Weapons_Right._icon,false);	//设置图标

			//this.Inventory[("bagslot" +3)]._icon.alpha = 1;
			//this.Inventory[("bagslot" +3)].iID = 6;
			//this.Inventory[("bagslot" +3)].image = "dragon_knight_breathe_fire.png";
			//Globals.instance.LoadImage("images/spellicons/dragon_knight_breathe_fire.png",this.Inventory[("bagslot" +3)]._icon,false);	//设置图标
			//this.Bag_iID[Bag_pages][3] = 6;
			//trace("Inventory[3] = ",this.Inventory[("bagslot" +3)].slot);
			//this.Inventory[("bagslot" +13)]._icon.alpha = 1;
			//this.Inventory[("bagslot" +13)].iID = 4;
			//this.Inventory[("bagslot" +13)].image = "alchemist_chemical_rage.png";
			//Globals.instance.LoadImage("images/spellicons/alchemist_chemical_rage.png",this.Inventory[("bagslot" +13)]._icon,false);	//设置图标
			//this.Bag_iID[Bag_pages][13] = 4;
			//this.Inventory[("bagslot" +8)]._icon.alpha = 1;
			//this.Inventory[("bagslot" +8)].iID = 5;
			//this.Inventory[("bagslot" +8)].image = "axe_berserkers_call_shoutmask.png";
			//Globals.instance.LoadImage("images/spellicons/axe_berserkers_call_shoutmask.png",this.Inventory[("bagslot" +8)]._icon,false);	//设置图标
			//this.Bag_iID[Bag_pages][8] = 5;
		}
		private function onBagSlotRollOver(event:MouseEvent):void{
			var mc:* = event.currentTarget as MovieClip;

			if (!mc.isDrag && mc._icon.alpha >0){
				//图标变亮
				var colorMat:ColorMatrix = new ColorMatrix();
				var colorFil:ColorMatrixFilter;
				colorMat.SetBrightnessMatrix(55);
				/* http://www.cuplayer.com/player/PlayerCodeAs/2012/0906375.html
					.SetBrightnessMatrix(100);	//设置亮度值，	值的大小是 -255--255 _,	0为中间值，向右为亮向左为暗。
					.SetContrastMatrix(255);	//设置对比度值，值的大小是 -255--255 _,	127.5为中间值，向右对比鲜明向左对比偏暗。
					.SetSaturationMatrix(0);	//设置饱和度值，值的大小是 -255--255 _,	1为中间值，0为灰度值（即黑白相片）。
					.SetHueMatrix(1);			//设置色相值，	值的大小是 -255--255 _,	0为中间值，向右向左一试便知。
				*/
				colorFil = new ColorMatrixFilter(colorMat.GetFlatArray());
				mc._icon.filters = [colorFil];
			}

			//设置全局变量
			OverMC = mc;
			trace(" ======== ");
			trace("onBagSlotRollOver.slot = ",mc.slot);
			trace("onBagSlotRollOver.iID = ",mc.iID);
			trace("onBagSlotRollOver.where = ",mc.where);
		}
		private function onBagSlotRollOut(event:MouseEvent):void{
			var mc:* = event.currentTarget as MovieClip;

			mc._icon.filters = [];//去除滤镜

			//设置全局变量
			OverMC = null;

		}

		private function onItemMouseDown(event:MouseEvent):void{

			if (OverMC.where != null && OverMC.iID >0){
				//设置全局变量
				DargMc = OverMC;

				DargMc.isDrag = true;
				//图标半透明
				DargMc._icon.alpha = 0.5;
				if (DargMc.where == "equip") DargMc._icon.alpha = 0.8;
				DargMc._icon.filters = [];//去除滤镜
				trace("onItemMouseDown.where = ",DargMc.where);

				Globals.instance.LoadImage("images/spellicons/" +DargMc.image,this.bagslot_img._icon,false);	//设置图标

				var pt:Point = new Point(DargMc.x,DargMc.y);	//DargMc的局部坐标
				pt = DargMc.parent.localToGlobal(pt);			//转成世界坐标
				pt = bagslot_img.parent.globalToLocal(pt);		//转到bagslot_img的局部坐标

				this.bagslot_img.x = pt.x;
				this.bagslot_img.y = pt.y;
				this.bagslot_img.visible = true;
				this.bagslot_img.startDrag();
			}

		}

		private function onItemMouseUp(event:MouseEvent):void{

			this.bagslot_img.visible = false;
			this.bagslot_img.stopDrag();

			if (DargMc != null){
				DargMc.isDrag = false;
				//图标不透明
				DargMc._icon.alpha = 1;

				if (OverMC != null && DargMc != OverMC){
					DargSwapItem(DargMc,OverMC)
				}
				//else{
				//	//图标不透明
				//	DargMc._icon.alpha = 1;
				//}

				trace("onItemMouseUp.slot = ",DargMc.slot);
			}
			//设置全局变量
			DargMc = null;
		}

		//private function onDargOut(event:MouseEvent):void{
		//	this.bagslot_img.visible = false;
		//	this.bagslot_img.stopDrag();
		//	if (DargMc.where != null){
		//		DargMc.isDrag = false;
		//		//图标不透明
		//		DargMc._icon.alpha = 1;
		//		trace("onDargOut.slot = ",DargMc.slot);
		//	}
		//	//设置全局变量
		//	DargMc = null;
		//}

		//鼠标拖拽交换物品，需要判断各种情况
		private function DargSwapItem(darg_mc:MovieClip,over_mc:MovieClip):void{
			//["where"] = "inbag";	//"inbag","equip","package"
			if (darg_mc.where == "inbag" && over_mc.where == "inbag"){
				if (over_mc.iID == -1){ //如果位置为空
					SwapItem(darg_mc,over_mc);
					//over_mc.iID 	= darg_mc.iID;
					//over_mc.where 	= darg_mc.where;
					//over_mc.image 	= darg_mc.image;
					//Globals.instance.LoadImage("images/spellicons/" +over_mc.image,over_mc._icon,false);	//设置图标
					//over_mc._icon.alpha 	= 1;
					////darg_mc变为空
					//darg_mc.iID 	= -1;
					//darg_mc.where 	= "inbag";
					//darg_mc.image 	= ".png";
					//Globals.instance.LoadImage("images/spellicons/invoker_empty1.png",darg_mc._icon,false);	//设置图标
					//darg_mc._icon.alpha 	= 0;
				}
				else if (over_mc.iID != -1){ //如果位置不为空
					SwapItem(darg_mc,over_mc);
					//var _iID:int 	= over_mc.iID;
					//var _where:String = over_mc.where;
					//var _image:String = over_mc.image;

					//over_mc.iID 	= darg_mc.iID;
					//over_mc.where 	= darg_mc.where;
					//over_mc.image 	= darg_mc.image;
					//Globals.instance.LoadImage("images/spellicons/" +over_mc.image,over_mc._icon,false);	//设置图标
					//over_mc._icon.alpha 	= 1;

					//darg_mc.iID 	= _iID;
					//darg_mc.where 	= _where;
					//darg_mc.image 	= _image;
					//Globals.instance.LoadImage("images/spellicons/" +darg_mc.image,darg_mc._icon,false);	//设置图标
					//darg_mc._icon.alpha 	= 1;
				}
			}
			else if (darg_mc.where == "equip" || over_mc.where == "equip"){
				if (darg_mc.where == "equip" && over_mc.where == "inbag" && over_mc.iID == -1){ //如果拖动装备到空格子，则无需判断
					SwapItem(darg_mc,over_mc);
					trace("darg_mc.where == equip && over_mc.where == inbag && over_mc.iID == -1");
				}
				else if ( over_mc.where == "equip" && over_mc.iID == -1){ //如果拖动装备到空的装备栏，则darg_mc.where == "inbag" &&
					if (over_mc.slot == "Light_Weapons_Left" || over_mc.slot == "Light_Weapons_Right"){
						if (ITEMS[darg_mc.iID].CanBeLight) SwapItem(darg_mc,over_mc);
						else {this.globals.Loader_error_msg.movieClip.setErrorMsg("#CustomError_DontMeetTheSlots");}
					}
					else if (over_mc.slot == "Heavy_Weapons_Middle"){
						if (ITEMS[darg_mc.iID].CanBeHeavy) SwapItem(darg_mc,over_mc);
						else {this.globals.Loader_error_msg.movieClip.setErrorMsg("#CustomError_DontMeetTheSlots");}
					}
				}
				else if (darg_mc.iID != -1 && over_mc.iID != -1){//如果拖动东西到装备栏，判断两个东西是否分别符合要求
					//var dargCanSwap:Boolean = false;
					//var overCanSwap:Boolean = false;
					var can_swap:Boolean = true;
					if (darg_mc.where == "equip"){
						if (darg_mc.slot == "Light_Weapons_Left" || darg_mc.slot == "Light_Weapons_Right"){
							if (!ITEMS[over_mc.iID].CanBeLight) can_swap = false;
						}
						else if (darg_mc.slot == "Heavy_Weapons_Middle"){
							if (!ITEMS[over_mc.iID].CanBeHeavy) can_swap = false;
						}
					}
					if (over_mc.where == "equip"){
						if (over_mc.slot == "Light_Weapons_Left" || over_mc.slot == "Light_Weapons_Right"){
							if (!ITEMS[darg_mc.iID].CanBeLight) can_swap = false;
						}
						else if (over_mc.slot == "Heavy_Weapons_Middle"){
							if (!ITEMS[darg_mc.iID].CanBeHeavy) can_swap = false;
						}
					}
					if (can_swap){
						SwapItem(darg_mc,over_mc);
						trace("can_swap");
					}
					else{
						this.globals.Loader_error_msg.movieClip.setErrorMsg("#CustomError_DontMeetTheSlots");
					}
				}
			}
			
		}

		//基础函数，交换两件物品，不判断可行性
		private function SwapItem(darg_mc:MovieClip,over_mc:MovieClip):void{
			var _iID:int 	= over_mc.iID;
			//var _where:String = over_mc.where;
			var _image:String = over_mc.image;

			over_mc.iID 	= darg_mc.iID;
			//over_mc.where 	= darg_mc.where;
			over_mc.image 	= darg_mc.image;
			Globals.instance.LoadImage("images/spellicons/" +over_mc.image,over_mc._icon,false);	//设置图标
			if (over_mc.iID == -1) over_mc._icon.alpha = 0;
			else over_mc._icon.alpha = 1;
			if (over_mc.where == "inbag") this.Bag_iID[Bag_pages][over_mc.slot] = over_mc.iID;
			if (over_mc.where == "equip") this.gameAPI.SendServerCommand("onSwapWeapons " + over_mc.slot +" " + over_mc.iID );	//发送到lua;
			
			darg_mc.iID 	= _iID;
			//darg_mc.where 	= _where;
			darg_mc.image 	= _image;
			Globals.instance.LoadImage("images/spellicons/" +darg_mc.image,darg_mc._icon,false);	//设置图标
			if (darg_mc.iID == -1) darg_mc._icon.alpha = 0;
			else darg_mc._icon.alpha = 1;
			if (darg_mc.where == "inbag") this.Bag_iID[Bag_pages][darg_mc.slot] = darg_mc.iID;
			if (darg_mc.where == "equip") this.gameAPI.SendServerCommand("onSwapWeapons " + darg_mc.slot +" " + darg_mc.iID );	//发送到lua;
		}

		public function onSendItemData( eventData:Object )
		{
			var pID:int = this.globals.Players.GetLocalPlayer();
			if( pID == eventData.nPlayerID )
			{
				this.ITEMS[eventData.nItemID] = new  Array();
				this.ITEMS[eventData.nItemID]["CanBeLight"] = eventData.bCanBeLight;
				this.ITEMS[eventData.nItemID]["CanBeHeavy"] = eventData.bCanBeHeavy;
				this.ITEMS[eventData.nItemID]["ItemName"] = eventData.sItemName;
				this.ITEMS[eventData.nItemID]["TextureName"] = eventData.sTextureName;

				if ( eventData.sPlaceSlot == "Light_Weapons_Left" || eventData.sPlaceSlot == "Light_Weapons_Right" || eventData.sPlaceSlot == "Heavy_Weapons_Middle" ){
					this.Equip[eventData.sPlaceSlot]._icon.alpha = 1;
					this.Equip[eventData.sPlaceSlot].iID = eventData.nItemID;
					this.Equip[eventData.sPlaceSlot].image = eventData.sTextureName;
					Globals.instance.LoadImage("images/spellicons/"+eventData.sTextureName,this.Equip[eventData.sPlaceSlot]._icon,false);	//设置图标
				}
				else if (eventData.sPlaceSlot == "inbag"){
					var _i:int = 1;
					var _empty:int = 0;

					while ( _i <= 20 && _empty == 0)
					{
						if (this.Bag_iID[Bag_pages][_i] == -1 || this.Bag_iID[Bag_pages][_i] == null){
							_empty = _i;
							trace("_empty_bag_solt = ",_empty);
						}
						_i++;
					}

					if (_empty){
						this.Inventory[("bagslot" +_empty)]._icon.alpha = 1;
						this.Inventory[("bagslot" +_empty)].iID = eventData.nItemID;
						this.Inventory[("bagslot" +_empty)].image = eventData.sTextureName;
						Globals.instance.LoadImage("images/spellicons/" +eventData.sTextureName,this.Inventory[("bagslot" +_empty)]._icon,false);	//设置图标
						this.Bag_iID[Bag_pages][_empty] = 4;
					}

				}

			}
		}


    }


}//package 