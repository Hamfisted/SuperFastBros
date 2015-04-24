package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.system.debug.LogStyle;
import map.Level;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
  private var _hud:HUD;
  private var _level:Level;

  /**
   * Function that is called up when to state is created to set it up.
   */
  override public function create():Void {
    FlxG.mouse.visible = false;

    FlxG.console.addCommand(["map", "level", "changelevel"], loadLevel, "loadLevel", 1);
    FlxG.console.addCommand(["winlevel"], winLevel, "winLevel");

    loadLevel(Reg.level);

    _hud = new HUD();
    add(_hud);

    super.create();
  }

  /**
   * Function that is called when this state is destroyed - you might want to
   * consider setting all objects this state uses to null to help garbage collection.
   */
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * Function that is called once every frame.
   */
  override public function update():Void {
    _level.update();
    FlxG.collide(_level.player, _level.levelEnd, winLevel);

    super.update();

    if (!_level.player.alive) {
      loadLevel(Reg.level);
    }
  }

  public function winLevel(?P:Player, ?W:LevelEnd):Void {
    Reg.level++;
    loadLevel(Reg.level);
  }

  public function loadLevel(i:Int):Void {
    var levelPath = Reg.levels[i];
    if (levelPath == null) {
      FlxG.log.error('Cannot load level index: ${i}');
      return;
    } else {
      FlxG.log.add('Loading level: ${levelPath}');
    }

    Reg.level = i;
    cleanupStage();

    _level = new Level(levelPath);
    add(_level.backgroundGroup);
    add(_level.levelEnd);
    add(_level.spikeGroup);
    add(_level.characterGroup);
    add(_level.foregroundGroup);
    add(_level.collisionGroup);
    FlxG.camera.bounds = _level.getBounds();
    FlxG.worldBounds.copyFrom(_level.getBounds());
  }

  private function cleanupStage():Void {
    // Remove objects from state
    if (_level != null) {
      remove(_level.backgroundGroup);
      remove(_level.levelEnd);
      remove(_level.spikeGroup);
      remove(_level.characterGroup);
      remove(_level.foregroundGroup);
      remove(_level.collisionGroup);
      _level.destroy();
      _level = null;
    }
  }

}
