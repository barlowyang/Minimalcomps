package com.bit101.components
{
    import com.bit101.utils.Pen;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.text.TextFormat;
    
    public class TFoldPanelBase extends Component
    {
        private var FWidth:int;
        private var FHeight:int;
        private var FMask:Shape;
        protected var FTitleBar:TTitleBar;
        private var FContent:DisplayObjectContainer;
        private var FBackground:Shape;
        private var FTitle:String;
        private var FTitleHeight:int;
        private var FIsFold:Boolean;
        private var FFoldable:Boolean;
        
        private var FoldIndicate:Shape;
        
        public function TFoldPanelBase(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, title:String="Window", titleHeight:int = 30, content:DisplayObjectContainer = null)
        {
            if(content)
            {
                FContent = content;
            }
            FTitle = title;
            FTitleHeight = titleHeight;
            super(parent, xpos, ypos);
        }
        
        override protected function addChildren():void
        {
            super.addChild(FBackground = new Shape())
                
            height = 200;
            
            FTitleBar = new TTitleBar();
            FTitleBar.Title = FTitle;
            FTitleBar.height = FTitleHeight;
            FTitleBar.filters = [new GlowFilter(0x666666,1,5,5,16,1,true),new GlowFilter(0x202020,1,3,3,8,1,true)];
            FTitleBar.useHandCursor = true;
            FTitleBar.buttonMode = true;
            FTitleBar.DefaultTextFormat = new TextFormat("simsun", "16", 0xffffff, true);
            FTitleBar.Text.x = 25;
            addRawChild(FTitleBar);
            FTitleBar.addEventListener(MouseEvent.CLICK, SwitchFoldState);
            
            FTitleBar.addChild(FoldIndicate = new Shape());
            FoldIndicate.x = 15;
            FoldIndicate.y = FTitleHeight>>1;
            var p:Pen = new Pen(FoldIndicate.graphics);
            p.lineStyle(1,0,0);
            p.beginFill(0xffffff);
            p.drawRegularPolygon(0,0,3,8,90);
            if(!FContent)
            {
                FContent = new Sprite();
            }
            addRawChild(FContent);
            addRawChild(FMask = new Shape());
            FContent.mask = FMask;
            
            FBackground.filters =[getShadow(2,true)];
        }
        
        public function SwitchFoldState(e:MouseEvent = null):void
        {
            FIsFold = !FIsFold;
            if(FIsFold)
            {
                if(FContent.parent)
                {
                    FContent.parent.removeChild(FContent);
                }
                if(FMask.parent)
                {
                    FMask.parent.removeChild(FMask);
                }
                FoldIndicate.rotation = -90;
            }
            else
            {
                addRawChild(FContent);
                addRawChild(FMask);
                FContent.mask = FMask;
                FoldIndicate.rotation = 0;
            }
			
			invalidate();
        }
		
		override protected function onInvalidate(event:Event):void
		{
			super.onInvalidate(event);
			
			dispatchEvent(new Event(Event.RESIZE));
		}
        
        public function get Foldable():Boolean
        {
            return FFoldable;
        }
        
        public function set Foldable(value:Boolean):void
        {
            FFoldable = value;
        }
        
        /**
         * Overridden to add new child to content.
         */
        public override function addChild(child:DisplayObject):DisplayObject
        {
            FContent.addChild(child);
            return child;
        }
        
        override public function removeChildren(beginIndex:int=0, endIndex:int=int.MAX_VALUE):void
        {
            FContent.removeChildren(beginIndex, endIndex);
        }
        
        /**
         * Access to super.addChild
         */
        public function addRawChild(child:DisplayObject):DisplayObject
        {
            super.addChild(child);
            return child;
        }
        
        /**
         * Draws the visual ui of the component.
         */
        override public function draw():void
        {
            super.draw();
            
            FMask.graphics.clear();
            FMask.graphics.beginFill(0xff0000);
            FMask.graphics.drawRect(0, 0, _width, _height - FTitleBar.height);
            FMask.graphics.endFill();
            
            var th:int = FTitleBar.height;
            if(FContent.parent)
            {
                th+= FMask.height;
            }
            
            FBackground.graphics.clear();
            FBackground.graphics.lineStyle(1, 0, 0.1);
            FBackground.graphics.beginFill(Style.BACKGROUND);
            FBackground.graphics.drawRect(0, 0, _width, th);
            FBackground.graphics.endFill();
            
            FContent.y = FMask.y = FTitleBar.height;
            
            FTitleBar.width = _width;
        }
        
        public function get TitleBar():TTitleBar
        {
            return FTitleBar;
        }
        
        override public function get height():Number
        {
            if(FIsFold)
            {
                return FTitleBar.height;
            }
            return _height;
        }
        
        protected function get Content():*
        {
            return FContent;
        }
    }
}
import com.bit101.components.Component;

import flash.display.DisplayObjectContainer;
import flash.display.GradientType;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class TTitleBar extends Component
{
    private var FTextfield:TextField;
    
    public function TTitleBar(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0)
    {
        if(parent)
        {
            parent.addChild(this);
        }
        x = xpos;
        y = ypos;
        FTextfield = new TextField();
        FTextfield.wordWrap = false;
        FTextfield.autoSize = TextFieldAutoSize.LEFT;
        FTextfield.filters = [getShadow(2)];
        FTextfield.mouseEnabled = false;
        FTextfield.x = 10;
        
        addChild(FTextfield);
    }
    
    public function set DefaultTextFormat(v:TextFormat):void
    {
        FTextfield.defaultTextFormat = v;
        FTextfield.setTextFormat(v);
    }
    
    override public function draw():void
    {
        graphics.clear();
        
        var mat:Matrix = new Matrix();
        mat.createGradientBox(_width, _height, 90/180*Math.PI);
        graphics.beginGradientFill(GradientType.LINEAR,[0x666666, 0x202020],[1,1], [0,255], mat);
        graphics.drawRect(0,0,_width, _height);
        graphics.endFill();
        FTextfield.y = ((_height - FTextfield.textHeight)>>1)-2;
    }
    
    public function get Text():TextField
    {
        return FTextfield;
    }
    
    public function set Title(v:String):void
    {
        FTextfield.text = v;
        invalidate();
    }
}
