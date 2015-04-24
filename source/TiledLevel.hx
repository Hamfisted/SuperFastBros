package;

import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPoint;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;

class TiledLevel extends TiledMap
{
  // For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image
  // used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.


  // Array of tilemaps used for collision
  public var foregroundTiles:FlxGroup;
  public var backgroundTiles:FlxGroup;
  public var wallTiles:FlxGroup;

  //object groups

  private var collidableTileLayers:Array<FlxTilemap>;

  public function new(tiledLevel:Dynamic) {
    super(tiledLevel);

    foregroundTiles = new FlxGroup();
    backgroundTiles = new FlxGroup();
    wallTiles = new FlxGroup();

    FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

    // Load Tile Maps
    for (tileLayer in layers) {
      var tileSheetName:String = tileLayer.properties.get("tileset");

      if (tileSheetName == null)
        throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";

      var tileSet:TiledTileSet = null;
      for (ts in tilesets) {
        if (ts.name == tileSheetName) {
          tileSet = ts;
          break;
        }
      }

      if (tileSet == null) {
        throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";
      }

      var imagePath     = new Path(tileSet.imageSource);
      var processedPath = Reg.PATH_TILESHEETS + imagePath.file + "." + imagePath.ext;

      var tilemap:FlxTilemap = new FlxTilemap();
      tilemap.widthInTiles = width;
      tilemap.heightInTiles = height;
      tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, tileSet.firstGID, 1, 1);

      if (tileLayer.name == "bg") {
        backgroundTiles.add(tilemap);
      } else if (tileLayer.name == "fg") {
        foregroundTiles.add(tilemap);
      } else {
        if (collidableTileLayers == null) {
          collidableTileLayers = new Array<FlxTilemap>();
        }

        if (tileLayer.name == "wall") {
          wallTiles.add(tilemap);
        }

        collidableTileLayers.push(tilemap);
      }
    }
  }

  public function loadObjects(state:PlayState):Void {
    for (group in objectGroups) {
      for (o in group.objects) {
        loadObject(o, group, state);
      }
    }
  }

  private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState):Void {
    var x:Int = o.x;
    var y:Int = o.y;

    // objects in tiled are aligned bottom-left (top-left in flixel)
    if (o.gid != -1) {
      y -= g.map.getGidOwner(o.gid).tileHeight;
    }

    switch (o.type.toLowerCase()) {
      case "player":
        state._player.reset(x, y);

      case "level_end":
        state._levelEnd.reset(x, y);

      case "spike":
        state._grpSpikes.add(new Spike(x, y));
    }
  }
}
