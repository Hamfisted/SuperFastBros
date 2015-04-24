package map;

import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTile;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;

// Derived from https://github.com/HaxeFlixel/flixel-demos/blob/master/Platformers/FlipRotationAnimationTiles/source/map/Level.hx


class Level extends TiledMap {
  private inline static var PATH_TILESETS = "assets/maps/";

  public var backgroundGroup:FlxTypedGroup<FlxTilemapExt>;
  public var foregroundGroup:FlxTypedGroup<FlxTilemapExt>;

  public var collisionGroup:FlxTypedGroup<FlxObject>;
  public var characterGroup:FlxTypedGroup<FlxObject>;
  public var spikeGroup:FlxTypedGroup<Spike>;

  // Individual entities
  public var player:Player;
  public var levelEnd:LevelEnd;

  private var bounds:FlxRect;

  public function new(level:Dynamic, ?animFile:Dynamic) {
    super(level);

    // background and foreground groups
    backgroundGroup = new FlxTypedGroup<FlxTilemapExt>();
    foregroundGroup = new FlxTypedGroup<FlxTilemapExt>();

    // events and collision groups
    characterGroup = new FlxTypedGroup<FlxObject>();
    collisionGroup = new FlxTypedGroup<FlxObject>();
    spikeGroup = new FlxTypedGroup<Spike>();

    // The bound of the map for the camera
    bounds = FlxRect.get(0, 0, fullWidth, fullHeight);

    var tileset:TiledTileSet;
    var tilemap:FlxTilemapExt;
    var layer:TiledLayer;

    // Prepare the tile animations
    var animations = null;
    if (animFile != null) {
     animations = TileAnims.getAnimations(animFile);
    }

    for (layer in layers) {
      if (layer.properties.contains("tileset")) {
        tileset = this.getTileSet(layer.properties.get("tileset"));
      } else {
        throw "Each layer needs a tileset property with the tileset name";
      }

      if (tileset == null) {
        throw "The tileset is null";
      }

      tilemap = new FlxTilemapExt();
      // need to set the width and height in tiles because we are loading the map with an array
      tilemap.widthInTiles = layer.width;
      tilemap.heightInTiles = layer.height;

      tilemap.loadMap(
        layer.tileArray,
        PATH_TILESETS + tileset.imageSource,
        tileset.tileWidth,          // each tileset can have a different tile width or height
        tileset.tileHeight,
        FlxTilemap.OFF,             // disable auto map
        tileset.firstGID            // IMPORTANT! set the starting tile id to the first tile id of the tileset
      );

      var specialTiles:Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
      var tile:TiledTile;
      var animData;
      var specialTile:FlxTileSpecial;
      // For each tile in the layer
      for (i in 0...layer.tiles.length) {
        tile = layer.tiles[i];
        if (tile != null && isSpecialTile(tile, animations)) {
          specialTile = new FlxTileSpecial(tile.tilesetID, tile.isFlipHorizontally, tile.isFlipVertically, tile.rotate);
          // add animations if exists
          if (animations != null && animations.exists(tile.tilesetID)) {
            // Right now, a special tile only can have one animation.
            animData = animations.get(tile.tilesetID)[0];
            // add some speed randomization to the animation
            var randomize:Float = FlxRandom.floatRanged( -animData.randomizeSpeed, animData.randomizeSpeed);
            var speed:Float = animData.speed + randomize;

            specialTile.addAnimation(animData.frames, speed, animData.framesData);
          }
          specialTiles[i] = specialTile;
        } else {
          specialTiles[i] = null;
        }
      }
      // set the special tiles (flipped, rotated and/or animated tiles)
      tilemap.setSpecialTiles(specialTiles);
      // set the alpha of the layer
      tilemap.alpha = layer.opacity;


      if (layer.properties.contains("fg")) {
        foregroundGroup.add(tilemap);
      } else if (layer.properties.contains("wall")) {
        collisionGroup.add(tilemap);
      } else {
        backgroundGroup.add(tilemap);
      }
    }

    loadObjects();
  }

  public function loadObjects():Void {
    for (group in objectGroups) {
      for (obj in group.objects) {
        loadObject(obj, group);
      }
    }
  }

  private function loadObject(o:TiledObject, g:TiledObjectGroup):Void {
    var x:Int = o.x;
    var y:Int = o.y;

    switch(o.type.toLowerCase()) {
      case "player":
        // var player:Character = new Character(o.name, x, y, "images/chars/"+o.name+".json");
        player = new Player(x, y);
        // player.setBoundsMap(this.getBounds());
        // player.controllable = true;
        FlxG.camera.follow(player);
        characterGroup.add(player);

      // case "npc":
      //   var npc:Character = new Character(o.name, x, y, "images/chars/"+o.name+".json");
      //   npc.setBoundsMap(this.getBounds());
      //   characterGroup.add(npc);

      case "spike":
        spikeGroup.add(new Spike(x, y));

      case "level_end":
        levelEnd = new LevelEnd(x, y);

      case "collision":
        // unused right now
        var coll:FlxObject = new FlxObject(x, y, o.width, o.height);
        // #if !FLX_NO_DEBUG
        // coll.debugBoundingBoxColor = 0xFFFF00FF;
        // #end
        coll.immovable = true;
        collisionGroup.add(coll);
    }
  }

  public function update():Void {
    updateCollisions();
    // updateEventsOrder();
  }

  public function updateEventsOrder():Void {
    characterGroup.sort(FlxSort.byY);
  }

  public function updateCollisions():Void {
    /*
      "Always collide the map with objects, not the other way around."
      http://api.haxeflixel.com/flixel/addons/editors/ogmo/FlxOgmoLoader.html
    */
    FlxG.collide(collisionGroup, characterGroup);
    FlxG.collide(characterGroup, characterGroup);
    FlxG.collide(spikeGroup, characterGroup);
  }

  public function getBounds():FlxRect {
    return bounds;
  }

  private inline function isSpecialTile(tile:TiledTile, ?animations:Dynamic):Bool {
    return (tile.isFlipHorizontally || tile.isFlipVertically || tile.rotate != FlxTileSpecial.ROTATE_0 || animations != null && animations.exists(tile.tilesetID));
  }

  public function destroy():Void {
    FlxDestroyUtil.destroy(backgroundGroup);
    FlxDestroyUtil.destroy(foregroundGroup);
    FlxDestroyUtil.destroy(collisionGroup);
    FlxDestroyUtil.destroy(characterGroup);
    FlxDestroyUtil.destroy(spikeGroup);
    FlxDestroyUtil.destroy(levelEnd);
    FlxDestroyUtil.destroy(player);
  }
}
