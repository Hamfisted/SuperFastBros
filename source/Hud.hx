package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{

  private var _sprBack:FlxSprite;
  private var _txtScore:FlxText;

  public function new()
  {
    super();
    _sprBack = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
    _sprBack.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);

    _txtScore = new FlxText(0, 2, 0, "0", 8);
    _txtScore.setBorderStyle(FlxText.BORDER_SHADOW, FlxColor.GRAY, 1, 1);
    _txtScore.alignment = "right";

    add(_sprBack);
    add(_txtScore);

    forEach(function(spr:FlxSprite) {
      spr.scrollFactor.set();
    });
  }

  public override function update():Void
  {
    _txtScore.text = Std.string(Reg.score);
    _txtScore.x = FlxG.width - 30;
    super.update();
  }
}
