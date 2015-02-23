package {
    import flash.display.*;
    import scaleform.clik.core.*;
    import flash.text.*;

    public class BagSlot extends UIComponent {

        public var cooldownLabel:TextField;
        public var activeType:MovieClip;
        private var _slot:int;

        public function BagSlot(){
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
        }
        function frame1(){
            stop();
        }

    }
}//package 
