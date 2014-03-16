package ru.darkwingdev.motiontrack
{
    import flash.geom.Point;

    import ru.darkwingdev.motionstreak.MotionStreak;
    import ru.darkwingdev.ribbon.segment.RibbonSegment;

    import starling.utils.VertexData;

    /**
     * @history Created on 02.03.14, 21:56.
     * @author Sergey Smirnov
     */
    public class MotionTrack extends MotionStreak
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

        protected var _lastTextureUPosition:Number;

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

        public function MotionTrack()
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

            _lastTextureUPosition = 0.0;
        }

        override protected function setupVertices():void
        {
            var index:int = 0;
            var currentSegment:RibbonSegment;

            _vertexData = new VertexData(_segments.length * 2);

            for (var i:int = 0; i < _segments.length; i++)
            {
                currentSegment = _segments[i];

                _vertexData.setPosition(index, currentSegment.p1.x, currentSegment.p1.y);
                _vertexData.setColorAndAlpha(index, tint, currentSegment.alpha);
                _vertexData.setTexCoords(index, currentSegment.textureUCoord, currentSegment.topTextureVCoord);
                index++;

                _vertexData.setPosition(index, currentSegment.p2.x, currentSegment.p2.y);
                _vertexData.setColorAndAlpha(index, tint, currentSegment.alpha);
                _vertexData.setTexCoords(index, currentSegment.textureUCoord, currentSegment.bottomTextureVCoord);
                index++;
            }
        }

        /**
         * @inheritDoc
         */
        override protected function postInitialize(segment:RibbonSegment):void
        {
            super.postInitialize(segment);

            if (!texture)
            {
                return;
            }

            if (_segments.length <= 1)
            {
                return;
            }

            var lastSegment:RibbonSegment = _segments[_segments.length - 1];

            if (!lastSegment)
            {
                return;
            }

            var textureUPos:Number = 0.0;
            var topVPos:Number = 0.0;
            var bottomVPos:Number = 1.0;

            var pos:Number = Point.distance(lastSegment.centerPoint, segment.centerPoint) / texture.width;

            _lastTextureUPosition += pos;

            if (texture)
            {
                textureUPos = _lastTextureUPosition;
            }

            segment.setTextCoords(textureUPos, topVPos, bottomVPos);
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //----------------------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override public function dispose():void
        {
            _lastTextureUPosition = 0;

            super.dispose();
        }

//----------------------------------------------------------------------------------------------
        //
        //  Accessors
        //
        //----------------------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override protected function get repeat():Boolean
        {
            return true;
        }
    }
}
