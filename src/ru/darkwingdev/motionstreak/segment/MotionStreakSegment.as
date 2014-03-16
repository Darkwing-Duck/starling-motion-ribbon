package ru.darkwingdev.motionstreak.segment
{
    import ru.darkwingdev.ribbon.segment.RibbonSegment;

    import starling.animation.IAnimatable;

    /**
     * @history create Feb 19, 2014 2:42:47 PM
     * @author Sergey Smirnov
     */
    public class MotionStreakSegment extends RibbonSegment implements IAnimatable
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
        protected var _elapsed:Number;

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

        public function MotionStreakSegment()
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

        private function updateAlpha():void
        {
            _alpha = remaining / _fadeTime;
        }

        /**
         * @inheritDoc
         */
        override protected function reset():void
        {
            super.reset();

            _elapsed = 0;
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Protected Methods
        //
        //----------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //----------------------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        public function advanceTime(time:Number):void
        {
            _elapsed += time;

            if (_elapsed > _fadeTime)
            {
                _elapsed = _fadeTime;
            }

            updateAlpha();
        }

        /**
         * @inheritDoc
         */
        override public function dispose():void
        {
            super.dispose();
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Accessors
        //
        //----------------------------------------------------------------------------------------------

        public function get elapsed():Number
        {
            return _elapsed;
        }

        public function get remaining():Number
        {
            return _fadeTime - _elapsed;
        }

        public function get isFinished():Boolean
        {
            return remaining <= 0;
        }

        public function get fadeTime():Number
        {
            return _fadeTime;
        }

        public function set fadeTime(value:Number):void
        {
            _fadeTime = value;
        }
    }
}