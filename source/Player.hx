package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
  var initX:Float;
  var initY:Float;

  var lastVelocity:FlxPoint;

  var GRAVITY:Int = 800;
  var JUMP_SPEED:Int = -400;

  public var speed:Int = 200;

  public function new(X:Float=0, Y:Float=0)
  {
    super(X, Y);
    initX = X;
    initY = Y;

    lastVelocity = new FlxPoint(0, 0);

    loadGraphic(AssetPaths.catfighter__png, true, 64, 64);
    setFacingFlip(FlxObject.RIGHT, false, false);
    setFacingFlip(FlxObject.LEFT, true, false);

    setSize(17, 32);
    offset.set(23, 23);

    var r:Int = 16;
    animation.add("walk", [r+0, r+1, r+2, r+3, r+4, r+5, r+6, r+7], 24, true);

    // makeGraphic(16, 16, FlxColor.BLUE);
    solid = true;
    collisonXDrag = false;

    drag.x = 2400;

    acceleration.y = GRAVITY;
  }

  override public function update():Void
  {
    animateCollision();
    movement();
    if (alive)
    {
      if (shouldBeDead())
      {
        kill();
      }
      else
      {
        Reg.score += 1;
      }
    }
    super.update();
  }

  override public function kill():Void
  {
    this.alive = false;
  }

  override public function reset(X:Float, Y:Float):Void
  {
    super.reset(X, Y);
    velocity.set(0, 0);
    lastVelocity.copyFrom(velocity);
  }

  private function shouldBeDead():Bool
  {
    return outOfBounds();
  }

  private function movement():Void
  {
    var _up:Bool = FlxG.keys.anyPressed(["UP", "W", "SPACE"]);
    var _left:Bool = FlxG.keys.anyPressed(["LEFT", "A"]);
    var _right:Bool = FlxG.keys.anyPressed(["RIGHT", "D"]);
    var _down:Bool = FlxG.keys.anyPressed(["DOWN", "S"]);

    if (_up && isTouching(flixel.FlxObject.FLOOR))
    {
      this.velocity.y = JUMP_SPEED;
    }

    if (_left)
    {
      this.velocity.x = -this.speed;
      facing = FlxObject.LEFT;
    }
    else if (_right)
    {
      this.velocity.x = this.speed;
      facing = FlxObject.RIGHT;
    }

    lastVelocity.copyFrom(velocity);

    if (_left || _right)
    {
      animation.play("walk");
    }
    else
    {
      animation.pause();
    }
  }

  private function outOfBounds():Bool
  {
    return this.y > 800;
  }

  private function animateCollision():Void
  {
    var shakeY = Math.abs(lastVelocity.y - velocity.y)/30000;
    var shakeAmount = shakeY + Math.abs(lastVelocity.x - velocity.x)/30000;

    /* Let's disable shake for now. It's annoying! */

    // if (shakeAmount > 0.01 && justTouched(FlxObject.FLOOR))
    // {
    //   FlxG.camera.shake(shakeAmount, 0.1);
    // }
  }

  public function touchSpike(P:Player, S:Spike):Void
  {
    kill();
  }
}
