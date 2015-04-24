package;

class Utils
{
  public static function getLevelPaths():Array<String>
  {
    var arr = new Array<String>();
    for ( i in 0...99 ) {
      var s = Std.string(i);
      if (i < 10) {
        s = "00" + s;
      } else if (i < 100) {
        s = "0" + s;
      }

      var level = Reflect.field(AssetPaths, 'level${s}__tmx');
      if (level != null)
      {
        arr.push(level);
      }
      else
      {
        break;
      }
    }
    return arr;
  }
}
