package {
    import flash.display.*;
    import scaleform.clik.core.*;
    import flash.text.*;

    public class BagItem extends UIComponent {

        public var cooldownLabel:TextField;
        public var activeType:MovieClip;
        public var enemyState:MovieClip;
        public var autocast:MovieClip;
        public var activePressedType:MovieClip;
        public var passiveDownType:MovieClip;
        public var cooldownEnd:MovieClip;
        public var AbilityArt:MovieClip;
        public var levelUp:MovieClip;
        public var activeCastType:MovieClip;
        public var silencedState:MovieClip;
        public var cooldownSwipe:MovieClip;
        public var unlearnedState:MovieClip;
        public var activeDownType:MovieClip;
        public var noManaState:MovieClip;
        public var passiveType:MovieClip;
        public var overState:MovieClip;
        public var autocastable:MovieClip;
        private var _slot:int;

        public function BagItem(){
            addFrameScript(0, this.frame1);
        }
        public function get slot():int{
            return (this._slot);
        }
        public function set slot(_arg1:int):void{
            this._slot = _arg1;
        }
        override protected function configUI():void{
            super.configUI();
            this.overState.visible = false;
            this.cooldownSwipe.visible = false;
            this.autocast.visible = false;
            this.silencedState.visible = false;
            this.unlearnedState.visible = false;
            this.noManaState.visible = false;
            this.silencedState.visible = false;
        }
        function frame1(){
            stop();
        }

    }
}//package 
