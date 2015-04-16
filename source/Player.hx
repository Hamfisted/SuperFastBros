package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.util.FlxColor;
import flixel.input.touch.FlxTouch;

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

    makeGraphic(16, 16, FlxColor.BLUE);
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
    if (outOfBounds())
    {
      this.reset(initX, initY);
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
    return outOfBounds() || isTouching(FlxObject.RIGHT);
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
    }
    else if (_right)
    {
      this.velocity.x = this.speed;
    }

    lastVelocity.copyFrom(velocity);
  }

  private function outOfBounds():Bool
  {
    return this.y > 800;
  }

  private function animateCollision():Void
  {
    var shakeY = Math.abs(lastVelocity.y - velocity.y)/30000;
    var shakeAmount = shakeY + Math.abs(lastVelocity.x - velocity.x)/30000;

    if (shakeAmount > 0.01 && justTouched(FlxObject.ANY))
    {
      FlxG.camera.shake(shakeAmount, 0.1);
    }
  }
}
