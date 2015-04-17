package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.system.debug.LogStyle;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
  private var _hud:HUD;
  private var _player:Player;
  private var _map:FlxOgmoLoader;
  private var _mWalls:FlxTilemap;

  /**
   * Function that is called up when to state is created to set it up.
   */
  override public function create():Void
  {
    FlxG.mouse.visible = false;

    FlxG.console.addCommand(["map", "level", "changelevel"], loadLevel, "loadLevel", 1);

    _player = new Player();

    loadLevel(Reg.level);

    _hud = new HUD();
    add(_hud);

    super.create();
  }

  /**
   * Function that is called when this state is destroyed - you might want to
   * consider setting all objects this state uses to null to help garbage collection.
   */
  override public function destroy():Void
  {
    super.destroy();
  }

  /**
   * Function that is called once every frame.
   */
  override public function update():Void
  {
    super.update();
    /*
      "Always collide the map with objects, not the other way around."
      http://api.haxeflixel.com/flixel/addons/editors/ogmo/FlxOgmoLoader.html
    */
    FlxG.collide(_mWalls, _player);
  }

  public function loadLevel(i:Int):Void
  {
    var levelPath = Reg.levels[i];
    if (levelPath == null)
    {
      FlxG.log.error('Cannot load level index: ${i}');
      return;
    }
    else
    {
      FlxG.log.add('Loading level: ${levelPath}');
    }

    cleanupStage();

    _map = new FlxOgmoLoader(levelPath);
    _mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
    _mWalls.setTileProperties(1, FlxObject.NONE);
    _mWalls.setTileProperties(2, FlxObject.ANY);
    add(_mWalls);

    _map.loadEntities(placeEntities, "entities");

    add(_player);

    FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
  }

  private function cleanupStage():Void
  {
    remove(_mWalls);
    remove(_player);
  }

  private function placeEntities(entityName:String, entityData:Xml):Void
  {
    var x:Int = Std.parseInt(entityData.get("x"));
    var y:Int = Std.parseInt(entityData.get("y"));
    if (entityName == "player")
    {
      _player.x = x;
      _player.y = y;
    }
  }

}
