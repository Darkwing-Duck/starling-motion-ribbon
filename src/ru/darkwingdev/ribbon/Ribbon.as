package ru.darkwingdev.ribbon
{
    import com.adobe.utils.AGALMiniAssembler;

    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import ru.darkwingdev.ribbon.segment.RibbonSegment;

    import starling.animation.IAnimatable;
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    import starling.textures.SubTexture;
    import starling.textures.Texture;
    import starling.utils.VertexData;

    /**
     * @history create Feb 23, 2014 12:40:43 AM
     * @author Sergey Smirnov
     */
    public class Ribbon extends DisplayObject implements IAnimatable
    {
        //----------------------------------------------------------------------------------------------
        //
        //  Class constants
        //
        //----------------------------------------------------------------------------------------------

        protected const DEFAULT_PROGRAM_NAME:String = "default_ribbon_program";
        protected const TEXTURED_PROGRAM_NAME:String = "textured_ribbon_program";
        protected const TINTED_TEXTURED_PROGRAM_NAME:String = "textured_ribbon_program_tinted";

        //----------------------------------------------------------------------------------------------
        //
        //  Class variables
        //
        //----------------------------------------------------------------------------------------------

        // data
        protected var _vertexData:VertexData;
        protected var _indexData:Vector.<uint>;
        //

        // buffers
        protected var _vertexBuffer:VertexBuffer3D;
        protected var _indexBuffer:IndexBuffer3D;
        //

        // params
        private var _thickness:Number;
        private var _tint:int;
        private var _texture:Texture;
        //

        // ribbon segments list
        protected var _segments:Vector.<RibbonSegment>;

        // pool of segments
        protected var _segmentPool:Vector.<RibbonSegment>;

        // help vectors
        protected var _alphaVector:Vector.<Number>;
        protected var _clippingVector:Vector.<Number>;
        //

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
        public function Ribbon()
        {
            init();
            initStartPoints();
            registerPrograms();
            advanceTime(0);

            Starling.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //----------------------------------------------------------------------------------------------

        private function onContextCreated(event:Event):void
        {
            registerPrograms();
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //----------------------------------------------------------------------------------------------

        private function registerPrograms():void
        {
            registerDefaultShaderProgram();

            if (texture)
            {
                registerTexturedShaderProgram();
            }
        }

        private function deletePrograms():void
        {
            var target:Starling = Starling.current;
            target.deleteProgram(DEFAULT_PROGRAM_NAME);
            target.deleteProgram(TEXTURED_PROGRAM_NAME);
            target.deleteProgram(TINTED_TEXTURED_PROGRAM_NAME);
        }

        private function registerTexturedShaderProgram():void
        {
            var target:Starling = Starling.current;
            var programName:String = tint > -1 ? TINTED_TEXTURED_PROGRAM_NAME : TEXTURED_PROGRAM_NAME;

            if (target.hasProgram(programName))
            {
                return; // already registered
            }

            var vertexProgramCode:String =
                    "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
                    "mul v0, va1, vc4 \n" + // multiply color with alpha and pass it to fragment shader
                    "add v1, va2, vc5 \n" +  // pass texture coordinates to fragment program
                    "mov v2, vc6"; // pass clipping data to fragment shader

            var clippingData:String =
                    "frc ft0.xy, v1.xy \n" + // fraction
                    "sub ft1.xy, v1.xy, ft0.xy \n" + // integer part
                    "add ft2.xy, ft1.xy, v2.xy \n" + // add subtexture offset to integer part
                    "mul ft3.xy, ft0.xy, v2.zw \n" + // multiply size with fraction part
                    "add ft4.xy, ft3.xy, ft2.xy \n"; // add current sub texture position

            var fragmentProgramCode:String = clippingData;
            fragmentProgramCode +=
                    "tex ft5, ft4.xy, fs0 <???> \n" + // sample texture
                    "mul ft5.a, ft5.a, v0.a \n";

            var fillTexture:String =
                    "mov ft5.xyz, v0.xyz \n"; // tint the texture

            fragmentProgramCode += programName == TINTED_TEXTURED_PROGRAM_NAME ? fillTexture : "";
            fragmentProgramCode += "mov oc, ft5";

            fragmentProgramCode = fragmentProgramCode.replace("<???>",
                    RenderSupport.getTextureLookupFlags(texture.format, texture.mipMapping, repeat));

            registerShaderProgram(programName, vertexProgramCode, fragmentProgramCode);
        }

        private function registerDefaultShaderProgram():void
        {
            var target:Starling = Starling.current;
            var programName:String = DEFAULT_PROGRAM_NAME;

            if (target.hasProgram(programName))
            {
                return; // already registered
            }

            var vertexProgramCode:String =
                    "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
                    "mul v0, va1, vc4 \n";  // multiply color with alpha and pass it to fragment shader

            var fragmentProgramCode:String =
                    "mov oc, v0";           // just forward incoming color

            registerShaderProgram(programName, vertexProgramCode, fragmentProgramCode);
        }

        private function registerShaderProgram(programName:String, vertexShaderCode:String, fragmentShaderCode:String):void
        {
            var target:Starling = Starling.current;

            var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexShaderCode);

            var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShaderCode);

            target.registerProgram(programName, vertexProgramAssembler.agalcode, fragmentProgramAssembler.agalcode);
        }

        private function lineNormal(p1:Point, p2:Point):Point
        {
            var result:Point = new Point();

            result.x = p2.y - p1.y;
            result.y = p1.x - p2.x;

            return result;
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Protected Methods
        //
        //----------------------------------------------------------------------------------------------

        protected function init():void
        {
            _thickness = 10;
            _tint = -1;
            _texture = null;

            _segments = new <RibbonSegment>[];
            _segmentPool = new <RibbonSegment>[];

            _alphaVector = new <Number>[1.0, 1.0, 1.0, alpha * this.alpha];
            _clippingVector = new Vector.<Number>(4);

            resetClippingData();
        }

        protected function initStartPoints():void
        {
            // push the first point
            addPoint(new Point(0, 0));
            addPoint(new Point(0, 0));
            //
        }

        protected function getRibbonLength():Number
        {
            var result:Number = 0;
            var currentSegment:RibbonSegment;
            var previousSegment:RibbonSegment;

            for (var i:int = 0; i < _segments.length; i++)
            {
                if (i > 0)
                {
                    currentSegment = _segments[i];
                    previousSegment = _segments[i - 1];
                    result += Point.distance(previousSegment.centerPoint, currentSegment.centerPoint);
                }
            }

            return result;
        }

        protected function setupVertices():void
        {
            var index:int = 0;
            var currentDistance:Number = 0.0;
            var textureUPos:Number = 0.0;
            var maxDistance:Number = getRibbonLength();
            var currentSegment:RibbonSegment;
            var previousSegment:RibbonSegment;
            var topVPos:Number = 0.0;
            var bottomVPos:Number = 1.0;

            _vertexData = new VertexData(_segments.length * 2);

            for (var i:int = 0; i < _segments.length; i++)
            {
                currentSegment = _segments[i];

                if (i > 0)
                {
                    previousSegment = _segments[i - 1];

                    // Distance in texture space for current line segment
                    currentDistance += Point.distance(previousSegment.centerPoint, currentSegment.centerPoint);

                    if (maxDistance > 0)
                    {
                        textureUPos = currentDistance / maxDistance;
                    }
                }

                currentSegment.setTextCoords(textureUPos, topVPos, bottomVPos);

                // setup top vertex
                _vertexData.setPosition(index, currentSegment.p1.x, currentSegment.p1.y);
                _vertexData.setColorAndAlpha(index, tint, currentSegment.alpha);
                _vertexData.setTexCoords(index, currentSegment.textureUCoord, currentSegment.topTextureVCoord);
                index++;
                //

                // setup bottom vertex
                _vertexData.setPosition(index, currentSegment.p2.x, currentSegment.p2.y);
                _vertexData.setColorAndAlpha(index, tint, currentSegment.alpha);
                _vertexData.setTexCoords(index, currentSegment.textureUCoord, currentSegment.bottomTextureVCoord);
                index++;
                //
            }
        }

        protected function setupIndices():void
        {
            var index:int = 0;
            _indexData = new <uint>[];

            for (var i:int = 0; i < _segments.length - 1; i++)
            {
                // Generate 2 triangles using 4 vertices
                _indexData.push(index + 0, index + 1, index + 3);
                _indexData.push(index + 0, index + 2, index + 3);

                index += 2;
            }
        }

        protected function createBuffers():void
        {
            var context:Context3D = Starling.context;
            if (context == null)
            {
                throw new MissingContextError();
            }

            if (_vertexBuffer)
            {
                _vertexBuffer.dispose();
            }
            if (_indexBuffer)
            {
                _indexBuffer.dispose();
            }

            _vertexBuffer = context.createVertexBuffer(_vertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX);
            _vertexBuffer.uploadFromVector(_vertexData.rawData, 0, _vertexData.numVertices);

            _indexBuffer = context.createIndexBuffer(_indexData.length);
            _indexBuffer.uploadFromVector(_indexData, 0, _indexData.length);
        }

        protected function getProgramName():String
        {
            var result:String = DEFAULT_PROGRAM_NAME;

            if (texture)
            {
                result = TEXTURED_PROGRAM_NAME;

                if (tint > -1)
                {
                    result = TINTED_TEXTURED_PROGRAM_NAME;
                }
            }

            return result;
        }

        protected function getSegment(p1:Point, p2:Point, centerPoint:Point):RibbonSegment
        {
            var result:RibbonSegment;

            if (_segmentPool.length > 0)
            {
                result = _segmentPool.shift();
            }
            else
            {
                result = createSegment();
            }

            result.init(p1, p2, centerPoint);

            return result;
        }

        protected function createSegment():RibbonSegment
        {
            return new RibbonSegment();
        }

        protected function postInitialize(segment:RibbonSegment):void
        {
            //
        }

        protected function resetClippingData():void
        {
            _clippingVector[0] = 0;
            _clippingVector[1] = 0;
            _clippingVector[2] = 1;
            _clippingVector[3] = 1;
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //----------------------------------------------------------------------------------------------

        /**
         * @inheritDoc
         */
        override public function render(support:RenderSupport, parentAlpha:Number):void
        {
            // always call this method when you write custom rendering code!
            // it causes all previously batched quads/images to render.
            support.finishQuadBatch(); // (1)

            // make this call to keep the statistics display in sync.
            support.raiseDrawCount(); // (2)

            // update alpha
            _alphaVector[3] = alpha * this.alpha;
            //

            var context:Context3D = Starling.context; // (3)
            if (context == null)
            {
                throw new MissingContextError();
            }

            // apply the current blendmode (4)
            support.applyBlendMode(false);

            // activate program (shader) and set the required attributes / constants (5)
            var programName:String = getProgramName();
            context.setProgram(Starling.current.getProgram(programName));
            context.setVertexBufferAt(0, _vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
            context.setVertexBufferAt(1, _vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);

            if (texture)
            {
                context.setVertexBufferAt(2, _vertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

                if (texture is SubTexture)
                {
                    _clippingVector[0] = SubTexture(_texture).clipping.x;
                    _clippingVector[1] = SubTexture(_texture).clipping.y;
                    _clippingVector[2] = SubTexture(_texture).clipping.width;
                    _clippingVector[3] = SubTexture(_texture).clipping.height;
                }
            }

            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _alphaVector, 1);
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 6, _clippingVector, 1);

            if (texture)
            {
                context.setTextureAt(0, texture.base);
            }

            // finally: draw the object! (6)
            context.drawTriangles(_indexBuffer, 0, -1);

            if (texture)
            {
                context.setTextureAt(0, null);
                context.setVertexBufferAt(2, null);
            }

            // reset buffers (7)
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }

        /**
         * @inheritDoc
         */
        override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
        {
            if (resultRect == null)
            {
                resultRect = new Rectangle();
            }
            var transformationMatrix:Matrix = getTransformationMatrix(targetSpace);

            if (!_vertexData)
            {
                return resultRect;
            }

            return _vertexData.getBounds(transformationMatrix, 0, -1, resultRect);
        }

        /**
         * @inheritDoc
         */
        public function advanceTime(time:Number):void
        {
            setupVertices();
            setupIndices();
            createBuffers();
        }

        public function addPoint(value:Point):void
        {
            var topPoint:Point;
            var centerPoint:Point;
            var bottomPoint:Point;
            var segment:RibbonSegment;

            if (_segments.length < 1)
            {
                topPoint = value;
                centerPoint = value;
                bottomPoint = value;
            }
            else
            {
                var offset:Number = _thickness / 2;
                var lastIndex:int = _segments.length - 1;
                var normal:Point = lineNormal(_segments[lastIndex].centerPoint, value);

                normal.normalize(1);

                topPoint = new Point(value.x + normal.x * offset, value.y + normal.y * offset);
                centerPoint = value;
                bottomPoint = new Point(value.x + normal.x * -offset, value.y + normal.y * -offset);
            }

            segment = getSegment(topPoint, bottomPoint, centerPoint);
            postInitialize(segment);

            _segments.push(segment);
        }

        public function removeSegment(segment:RibbonSegment):void
        {
            var index:int = _segments.indexOf(segment);

            if (index < 0 || _segments.length <= 2)
            {
                return;
            }

            _segments.splice(index, 1);
            segment.dispose();
            _segmentPool.push(segment);
        }

        /**
         * @inheritDoc
         */
        override public function dispose():void
        {
            Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            deletePrograms();

            super.dispose();

            _vertexData = null;
            _indexData = null;

            _indexBuffer.dispose();
            _indexBuffer = null;

            _vertexBuffer.dispose();
            _vertexBuffer = null;

            _segments = null;
            _texture = null;
            _segmentPool = null;
        }

        //----------------------------------------------------------------------------------------------
        //
        //  Accessors
        //
        //----------------------------------------------------------------------------------------------

        public function get thickness():Number
        {
            return _thickness;
        }

        public function set thickness(value:Number):void
        {
            _thickness = value;
        }

        public function get texture():Texture
        {
            return _texture;
        }

        public function set texture(value:Texture):void
        {
            deletePrograms();

            _texture = value;
            resetClippingData();
            registerPrograms();
        }

        public function get tint():int
        {
            return _tint;
        }

        public function set tint(value:int):void
        {
            _tint = value;
            registerPrograms();
        }

        public function get isActive():Boolean
        {
            var segment:RibbonSegment;

            for each (segment in _segments)
            {
                if (segment.alpha > 0)
                {
                    return true;
                }
            }

            return false;
        }

        protected function get repeat():Boolean
        {
            return false;
        }

        public static function get version():String
        {
            return "1.0.0";
        }
    }
}