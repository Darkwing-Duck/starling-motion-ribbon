package ru.darkwingdev.motionstreak
{
    import flash.geom.Point;

    import ru.darkwingdev.motionstreak.segment.MotionStreakSegment;
    import ru.darkwingdev.ribbon.Ribbon;
    import ru.darkwingdev.ribbon.segment.RibbonSegment;

    /**
     * @history create Feb 19, 2014 2:42:47 PM
     * @author Sergey Smirnov
     */
    public class MotionStreak extends Ribbon
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

        protected var _fadeTime:Number;
        protected var _minSegmentLength:Number;

//----------------------------------------------------------------------------------------------
        //
        //  Class flags
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Constructor
        //
        //----------------------------------------------------------------------------------------------

        public function MotionStreak()
        {
            super();
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

        /**
         * @inheritDoc
         */
        override protected function init():void
        {
            super.init();

            _fadeTime = 0.5;
            _minSegmentLength = 10;
        }

        /**
         * @inheritDoc
         */
        override protected function createSegment():RibbonSegment
        {
            return new MotionStreakSegment();
        }

        /**
         * @inheritDoc
         */
        override protected function postInitialize(segment:RibbonSegment):void
        {
            MotionStreakSegment(segment).fadeTime = _fadeTime;
        }

        protected function updateSegments(time:Number):void
        {
            var segment:MotionStreakSegment;

            for each (segment in _segments)
            {
                if (segment.isFinished)
                {
                    removeSegment(segment);
                    continue;
                }

                segment.advanceTime(time);
            }
        }

        protected function checkForNewPoint(value:Point):void
        {
            var firstPosition:Point = MotionStreakSegment(_segments[_segments.length - 1]).centerPoint;
            var newPosition:Point = value;
            var distance:Number = Point.distance(firstPosition, newPosition);

            if (distance < _minSegmentLength)
            {
                return;
            }

            addPoint(newPosition);
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //----------------------------------------------------------------------------------------------

        public function moveTo(pX:Number, pY:Number):void
        {
            var globalPoint:Point = new Point(pX, pY);
            var localPoint:Point = this.globalToLocal(globalPoint);

            checkForNewPoint(localPoint);
        }

        override public function advanceTime(time:Number):void
        {
            updateSegments(time);

            super.advanceTime(time);
        }

//----------------------------------------------------------------------------------------------
        //
        //  Accessors
        //
        //----------------------------------------------------------------------------------------------

        public function get fadeTime():Number
        {
            return _fadeTime;
        }

        public function set fadeTime(value:Number):void
        {
            _fadeTime = value;
        }

        public function get minSegmentLength():Number
        {
            return _minSegmentLength;
        }

        public function set minSegmentLength(value:Number):void
        {
            _minSegmentLength = value;
        }
    }
}
