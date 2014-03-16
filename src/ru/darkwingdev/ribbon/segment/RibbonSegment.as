package ru.darkwingdev.ribbon.segment
{
    import flash.geom.Point;

    /**
     * @history create Feb 23, 2014 12:59:57 AM
     * @author Sergey Smirnov
     */
    public class RibbonSegment
    {
        //----------------------------------------------------------------------------------------------
        //
        //  Class constants
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Class variables
        //
        //----------------------------------------------------------------------------------------------

        protected var _p1:Point;
        protected var _p2:Point;
        protected var _centerPoint:Point;
        protected var _alpha:Number;
        protected var _textureUCoord:Number;
        protected var _topTextureVCoord:Number;
        protected var _bottomTextureVCoord:Number;

        //----------------------------------------------------------------------------------------------
        //
        //  Class flags
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Class signals
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Constructor
        //
        //----------------------------------------------------------------------------------------------
        public function RibbonSegment()
        {
            reset();
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Protected Methods
        //
        //----------------------------------------------------------------------------------------------

        protected function reset():void
        {
            _p1 = null;
            _p2 = null;
            _centerPoint = null;
            _alpha = 1.0;
            _textureUCoord = 0;
            _topTextureVCoord = 0;
            _bottomTextureVCoord = 0;
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //----------------------------------------------------------------------------------------------

        public function init(p1:Point, p2:Point, centerPoint:Point):void
        {
            _p1 = p1;
            _p2 = p2;
            _centerPoint = centerPoint;
        }

        public function setTextCoords(u:Number, topV:Number, bottomV:Number):void
        {
            _textureUCoord = u;
            _topTextureVCoord = topV;
            _bottomTextureVCoord = bottomV;
        }

        public function dispose():void
        {
            reset();
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Accessors
        //
        //----------------------------------------------------------------------------------------------

        public function get p1():Point
        {
            return _p1;
        }

        public function get p2():Point
        {
            return _p2;
        }

        public function get centerPoint():Point
        {
            return _centerPoint;
        }

        public function get alpha():Number
        {
            return _alpha;
        }

        public function get textureUCoord():Number
        {
            return _textureUCoord;
        }

        public function set textureUCoord(value:Number):void
        {
            _textureUCoord = value;
        }

        public function get topTextureVCoord():Number
        {
            return _topTextureVCoord;
        }

        public function set topTextureVCoord(value:Number):void
        {
            _topTextureVCoord = value;
        }

        public function get bottomTextureVCoord():Number
        {
            return _bottomTextureVCoord;
        }

        public function set bottomTextureVCoord(value:Number):void
        {
            _bottomTextureVCoord = value;
        }
    }
}