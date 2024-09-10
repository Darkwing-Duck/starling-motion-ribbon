Starling Motion Ribbon
======================
Starling Motion Ribbon is slowly fading out ribbon. It can change the:
  - fill color;
  - texture; 
  - thickness;
  - the minimum length of the segment;
  - fading out time for each segment;


The library contains 2 classes that is essentialy a wrappers around Ribbon class.
 - Ribbon - static ribbon without fading.
 - MotionStreak - creates an effect like MotionStreak in Cocos2d framework. The Ribbon segments to more or less slowly fade out and disappear after you have drawn them. Texture is stretching the full ribbon length. You can see this effect in game Fruit Ninja.
 - MotionTrack - creates a similar effect, but the texture is repeating. It can be used to create an effect like tank tracks.

You can use textures from atlas (SubTexture) as texture for ribbon as well as the separate textures(Texture).
